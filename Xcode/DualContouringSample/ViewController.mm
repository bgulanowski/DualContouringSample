//
//  ViewController.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-11.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "ViewController.h"

#import "GLProgram.h"
#import "GLView.h"
#import "Model.h"
#import "ModelSerializer.h"
#import "MeshSerialization.h"

#import <OpenGL/gl3.h>

@interface ViewController ()<ModelSerializer>
@property (nonatomic) GLProgram *program;
@property (nonatomic) Model *model;

@property (nonatomic) NSString *vertexFileName;
@property (nonatomic) NSString *indexFileName;

@end

@implementation ViewController

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _vertexFileName = @"dual_contouring_vertices";
        _indexFileName = @"dual_contouring_indices";
    }
    return self;
}

#pragma mark - Derived Accessors

- (NSString *)vertexFilePathInSubfolder:(NSString *)subfolder {
    return [NSString pathWithComponents:@[self.saveFolder, subfolder, self.vertexFileName]];
}

- (NSString *)indexFilePathInSubfolder:(NSString *)subfolder {
    return [NSString pathWithComponents:@[self.saveFolder, subfolder, self.indexFileName]];
}

#pragma mark - ViewController

- (void)buildModel {
    [_model reloadInContext:self.glView.openGLContext];
}

- (void)dispatchBuildModel {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self buildModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.glView.model = self.model;
        });
    });
}

- (void)prepareShaders {
    if (!_program) {
        _program = [GLProgram new];
        self.glView.program = self.program;
    }
}

- (void)start {
    if (!_program) {
        [self prepareShaders];
    }
    if (!_model) {
        _model = [Model new];
        _model.serializer = self;
        [self dispatchBuildModel];
    }
}

#pragma mark - ModelSerializer

- (void)loadVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices folder:(NSString *)folder
{
    load([[self vertexFilePathInSubfolder:folder] UTF8String], vertices);
    load([[self indexFilePathInSubfolder:folder] UTF8String], indices);
}

- (void)saveVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices folder:(NSString *)folder
{
    save([[self vertexFilePathInSubfolder:folder] UTF8String], vertices);
    save([[self indexFilePathInSubfolder:folder] UTF8String], indices);
}

#pragma mark - Actions

- (void)cycle:(id)sender {
    [self dispatchBuildModel];
}

@end
