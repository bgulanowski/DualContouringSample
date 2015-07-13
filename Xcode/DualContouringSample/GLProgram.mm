//
//  GLProgram.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "GLProgram.h"

#import "glsl_program.h"

@interface GLProgram ()
@property (nonatomic) GLSLProgram *program;
@end

@implementation GLProgram

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadProgram];
    }
    return self;
}

- (void)loadProgram {
    
    _program = new GLSLProgram();
    if (!_program->initialise() ||
        !_program->compileShader(ShaderType_Vertex, "shader.vert") ||
        !_program->compileShader(ShaderType_Fragment, "shader.frag") ||
        !_program->link())
    {
        [NSException raise:NSGenericException format:@"Failed to create GLSL program"];
    }
}

@end
