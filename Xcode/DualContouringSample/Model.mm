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
#import "MeshSerialization.h"

#import <OpenGL/gl3.h>
#import <AppKit/AppKit.h>

#import <string>

const static NSUInteger MAX_THRESHOLDS = 5;
const static CGFloat THRESHOLDS[MAX_THRESHOLDS] = { -1.f, 0.1f, 1.f, 10.f, 50.f };
// octreeSize must be a power of two!
const static int octreeSize = 64;

NS_INLINE NSString *AppFolder( void ) {
    NSString *appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).lastObject;
    NSString *appFolderName = [[NSProcessInfo processInfo] processName];
    return [appSupportDir stringByAppendingPathComponent:appFolderName];
}

NS_INLINE NSString *DataFolder( NSString *directory, int subfolder ) {
    return [directory stringByAppendingPathComponent:[@(subfolder) stringValue]];
}

@interface Model ()
@property (nonatomic) Mesh *mesh;
@property (nonatomic) OctreeNode *root;
@property (nonatomic) NSString *vertexFileName;
@property (nonatomic) NSString *indexFileName;

@property (nonatomic, readonly) NSString *vertexFilePath;
@property (nonatomic, readonly) NSString *indexFilePath;
@property (nonatomic, readonly) NSString *thresholdFolder;
@property (nonatomic, readonly) CGFloat threshold;
@end

@implementation Model

- (instancetype)init {
    self = [super init];
    if (self) {
        _vertexFileName = @"dual_contouring_vertices";
        _indexFileName = @"dual_contouring_indices";
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

- (NSString *)vertexFilePath {
    return [self.thresholdFolder stringByAppendingPathComponent:self.vertexFileName];
}

- (NSString *)indexFilePath {
    return [self.thresholdFolder stringByAppendingPathComponent:self.indexFileName];
}

- (NSString *)thresholdFolder {
    return DataFolder(AppFolder(), self.thresholdIndex);
}

- (CGFloat)threshold
{
    return THRESHOLDS[_thresholdIndex % MAX_THRESHOLDS];
}

- (void)incrementThreshold
{
    _thresholdIndex = (_thresholdIndex + 1) % MAX_THRESHOLDS;
}

- (void)reloadInContext:(NSOpenGLContext *)context {

    __block VertexBuffer vertices;
    __block IndexBuffer indices;
    
    [self loadVertices:vertices indices:indices];
    
    if (vertices.size() == 0 || indices.size() == 0) {
        [self generateWithVertices:vertices indices:indices];
        [self saveVertices:vertices indices:indices];
        NSLog(@"Saved files to %@", self.thresholdFolder);
    }
    else {
        NSLog(@"Loaded files from %@", self.thresholdFolder);
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

- (void)loadVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices
{
    load([[self vertexFilePath] UTF8String], vertices);
    load([[self indexFilePath] UTF8String], indices);
}

- (void)saveVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices
{
    [[NSFileManager defaultManager] createDirectoryAtPath:self.thresholdFolder withIntermediateDirectories:YES attributes:nil error:NULL];

    save([[self vertexFilePath] UTF8String], vertices);
    save([[self indexFilePath] UTF8String], indices);
}

- (void)draw {
    glBindVertexArray(_mesh->vertexArrayObj_);
    glDrawElements(GL_TRIANGLES, _mesh->numIndices_, GL_UNSIGNED_INT, (void*)0);
}

@end
