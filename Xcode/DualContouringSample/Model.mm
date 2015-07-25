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
    [self generateWithVertices:vertices indices:indices];
    
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

- (void)rebuild {
    
}

- (void)draw {
    glBindVertexArray(_mesh->vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, _mesh->numIndices_, GL_UNSIGNED_INT, (void*)0);
}

@end
