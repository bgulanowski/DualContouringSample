//
//  Model.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "Model.h"

extern "C" {
#import "Utility.h"
}

#import "mesh.h"
#import "octree.h"
#import "serialization.h"

#import <OpenGL/gl3.h>
#import <AppKit/AppKit.h>

#import <fstream>
#import <string>

const static NSUInteger MAX_THRESHOLDS = 5;
const static CGFloat THRESHOLDS[MAX_THRESHOLDS] = { -1.f, 0.1f, 1.f, 10.f, 50.f };
// octreeSize must be a power of two!
const static int octreeSize = 64;

inline static std::ostream& write(std::ostream& ostream_, glm::vec3& vertex)
{
    serialize::write(ostream_, vertex.x);
    serialize::write(ostream_, vertex.y);
    serialize::write(ostream_, vertex.z);
    return ostream_;
}

inline static std::istream& read(std::istream& istream_, glm::vec3& vertex)
{
    serialize::read(istream_, vertex.x);
    serialize::read(istream_, vertex.y);
    serialize::read(istream_, vertex.z);
    return istream_;
}

inline static std::ostream& write(std::ostream& ostream_, MeshVertex& vertex)
{
    write(ostream_, vertex.xyz);
    write(ostream_, vertex.normal);
    return ostream_;
}

inline static std::istream& read(std::istream& istream_, MeshVertex& vertex)
{
    read(istream_, vertex.xyz);
    read(istream_, vertex.normal);
    return istream_;
}

inline static std::ostream& write(std::ostream& ostream_, VertexBuffer& vertexBuffer_)
{
    for (VertexBuffer::iterator i=vertexBuffer_.begin(); i<vertexBuffer_.end(); ++i) {
        write(ostream_, *i);
    }
    
    return ostream_;
}

inline static std::istream& read(std::istream& istream_, VertexBuffer& vertexBuffer_)
{
    while (!istream_.eof()) {
        MeshVertex vertex(glm::vec3(0), glm::vec3(0));
        read(istream_, vertex);
        vertexBuffer_.push_back(vertex);
    }
    
    return istream_;
}

@interface Model ()
@property (nonatomic) Mesh *mesh;
@property (nonatomic) OctreeNode *root;
@end

@implementation Model {
    std::string _vertexFileName;
    std::string _indexFileName;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _vertexFileName = std::string("dual_contouring_vertices.dat");
        _indexFileName = std::string("dual_contouring_indices.dat");
        _mesh = new Mesh();
        _mesh->initialise();
        _thresholdIndex = -1;
    }
    return self;
}

- (void)dealloc {
    delete _mesh;
    delete _root;
}

- (void)reloadInContext:(NSOpenGLContext *)context {


    _thresholdIndex = (_thresholdIndex + 1) % MAX_THRESHOLDS;

    __block VertexBuffer vertices;
    __block IndexBuffer indices;
    [self loadVertices:vertices indices:indices];
    
    if (vertices.size() == 0 || indices.size() == 0) {
        [self generateWithVertices:vertices indices:indices];
        [self saveVertices:vertices indices:indices];
    }
    
    [context lock];
    [context makeCurrentContext];
    _mesh->uploadData((VertexBuffer&)vertices, indices);
    [context unlock];

}

- (void)generateWithVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices
{
    LogBlockDuration(@"Generate Octree", ^{
        _root = BuildOctree(glm::ivec3(-octreeSize / 2), octreeSize, THRESHOLDS[_thresholdIndex]);
    });
    LogBlockDuration(@"Generate Mesh", ^{
        GenerateMeshFromOctree(_root, vertices, indices);
    });
}

- (void)loadVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices
{
    std::ifstream vertexFile(_vertexFileName, std::ios::in | std::ios::binary);
    std::ifstream indexFile(_indexFileName, std::ios::in | std::ios::binary);
    
    if (vertexFile.good() && indexFile.good()) {
        read(vertexFile, vertices);
        
        vertexFile.close();
        
        serialize::read(indexFile, indices);
        indexFile.close();
    }
}

- (void)saveVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices
{
    std::ofstream file(_vertexFileName, std::ios::out | std::ios::binary | std::ios::trunc);
    write(file, vertices);
    file.flush();
    file.close();
    
    file = std::ofstream(_indexFileName, std::ios::out | std::ios::binary | std::ios::trunc);
    serialize::write(file, indices);
    file.flush();
    file.close();
}

- (void)rebuild {
    
}

- (void)draw {
    glBindVertexArray(_mesh->vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, _mesh->numIndices_, GL_UNSIGNED_INT, (void*)0);
}

@end
