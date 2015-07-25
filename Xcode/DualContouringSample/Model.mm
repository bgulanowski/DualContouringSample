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

#import "MeshSerialization.h"
#import "ModelSerializer.h"

#import "mesh.h"
#import "octree.h"

#import <OpenGL/gl3.h>
#import <AppKit/AppKit.h>

#import <string>

const static NSUInteger MAX_THRESHOLDS = 5;
const static CGFloat THRESHOLDS[MAX_THRESHOLDS] = { -1.f, 0.1f, 1.f, 10.f, 50.f };
// octreeSize must be a power of two!
const static int octreeSize = 64;

@interface Model ()
@property (nonatomic) Mesh *mesh;
@property (nonatomic) OctreeNode *root;

@property (nonatomic, readonly) NSString *thresholdFolder;
@property (nonatomic, readonly) CGFloat threshold;
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

- (NSString *)thresholdFolder {
    return [@(self.thresholdIndex) description];
}
- (CGFloat)threshold {
    return THRESHOLDS[_thresholdIndex % MAX_THRESHOLDS];
}

- (void)incrementThreshold {
    _thresholdIndex = (_thresholdIndex + 1) % MAX_THRESHOLDS;
}

- (void)reloadInContext:(NSOpenGLContext *)context {

    __block VertexBuffer vertices;
    __block IndexBuffer indices;
    
    [self.serializer loadVertices:vertices indices:indices folder:self.thresholdFolder];
    
    if (vertices.size() == 0 || indices.size() == 0) {
        [self generateWithVertices:vertices indices:indices];
        [self.serializer saveVertices:vertices indices:indices folder:self.thresholdFolder];
    }
    
    [context makeCurrentContext];
    [context lock];
    [self uploadVertices:vertices indices:indices];
    [context unlock];
}

- (void)uploadVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices {
    _mesh->uploadData(vertices, indices);
}

- (void)generateWithVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices
{
    LogBlockDuration(@"Generate Octree", ^{
        _root = BuildOctree(glm::ivec3(-octreeSize / 2), octreeSize, self.threshold);
    });
    LogBlockDuration(@"Generate Mesh", ^{
        GenerateMeshFromOctree(_root, vertices, indices);
    });
}

- (void)draw {
    glBindVertexArray(_mesh->vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, _mesh->numIndices_, GL_UNSIGNED_INT, (void*)0);
}

@end
