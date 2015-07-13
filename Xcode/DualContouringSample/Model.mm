//
//  Model.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "Model.h"

#import "mesh.h"
#import "octree.h"

#import <OpenGL/gl3.h>

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
        _thresholdIndex = -1;
    }
    return self;
}

- (void)dealloc {
    delete _mesh;
    delete _root;
}

- (void)reload {
    
    _thresholdIndex = (_thresholdIndex + 1) % MAX_THRESHOLDS;
    
    VertexBuffer vertices;
    IndexBuffer indices;
    
    _root = BuildOctree(glm::ivec3(-octreeSize / 2), octreeSize, THRESHOLDS[_thresholdIndex]);
    GenerateMeshFromOctree(_root, vertices, indices);
    _mesh->uploadData(vertices, indices);
}

- (void)draw {
    glBindVertexArray(_mesh->vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, _mesh->numIndices_, GL_UNSIGNED_INT, (void*)0);
}

@end
