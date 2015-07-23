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
#import "SerializableVertex.hpp"

#import <OpenGL/gl3.h>
#import <AppKit/AppKit.h>

#import <fstream>
#import <string>

const static NSUInteger MAX_THRESHOLDS = 5;
const static CGFloat THRESHOLDS[MAX_THRESHOLDS] = { -1.f, 0.1f, 1.f, 10.f, 50.f };
// octreeSize must be a power of two!
const static int octreeSize = 64;

@interface Model ()
@property (nonatomic) Mesh *mesh;
@property (nonatomic) OctreeNode *root;
@end

@implementation Model

- (instancetype)init {
    self = [super init];
    if (self) {
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

#if 0
    // Trying to subclass to mix in serializable but not working!
    __block std::vector<SerializableVertex> vertices;
    __block IndexBuffer indices;
    
    std::string vertexFileName("dual_contouring_vertices.dat");
    std::string indexFileName("dual_countouring_indices.dat");
    
    std::ifstream vertexFile(vertexFileName, std::ios::in | std::ios::binary);
    
    std::ifstream indexFile(indexFileName, std::ios::in | std::ios::binary);
    
    if (vertexFile.good() && indexFile.good()) {
        serialize::read(vertexFile, vertices);
        vertexFile.close();
        
        serialize::read(indexFile, indices);
        indexFile.close();
    }
    
    if (vertices.size() == 0 || indices.size() == 0) {
        
        LogBlockDuration(@"Generate Model", ^{
            _root = BuildOctree(glm::ivec3(-octreeSize / 2), octreeSize, THRESHOLDS[_thresholdIndex]);
            GenerateMeshFromOctree(_root, vertices, indices);
            GenerateMeshFromOctree(_root, (VertexBuffer&)vertices, indices);
        });
        
        std::ofstream file(vertexFileName, std::ios::out | std::ios::binary | std::ios::trunc);
        serialize::write(file, vertices);
        file.flush();
        file.close();
        
        file = std::ofstream(indexFileName, std::ios::out | std::ios::binary | std::ios::trunc);
        serialize::write(file, indices);
        file.flush();
        file.close();
    }

#else
    __block VertexBuffer vertices;
    __block IndexBuffer indices;
    
    LogBlockDuration(@"Generate Model", ^{
        _root = BuildOctree(glm::ivec3(-octreeSize / 2), octreeSize, THRESHOLDS[_thresholdIndex]);
        GenerateMeshFromOctree(_root, vertices, indices);
        GenerateMeshFromOctree(_root, (VertexBuffer&)vertices, indices);
    });
#endif
    
    [context lock];
    [context makeCurrentContext];
    _mesh->uploadData((VertexBuffer&)vertices, indices);
    [context unlock];

}

- (void)rebuild {
    
}

- (void)draw {
    glBindVertexArray(_mesh->vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, _mesh->numIndices_, GL_UNSIGNED_INT, (void*)0);
}

@end
