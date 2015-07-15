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
@property (nonatomic) glm::mat4 projection;
@property (nonatomic) glm::mat4 modelView;
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
    
    glGetError();
    _program = new GLSLProgram();
    if (!_program->initialise() ||
        !_program->compileShader(ShaderType_Vertex, "shader.vert") ||
        !_program->compileShader(ShaderType_Fragment, "shader.frag") ||
        !_program->link())
    {
        [NSException raise:NSGenericException format:@"Failed to create GLSL program"];
    }
}

- (void)use {
    
#if 1
    float rotateX = 0.0f, rotateY = 0.0f;
    float distance = 50.0f;
    glm::vec3 dir(0.f, 0.f, 1.f);
    dir = glm::rotateX(dir, rotateX);
    dir = glm::rotateY(dir, rotateY);
    
    glm::vec3 position = dir * distance;
    glm::mat4 projection = glm::perspective(60.f, 16.f/9.f, 0.1f, 500.f);
    glm::mat4 modelview = glm::lookAt(position - dir, glm::vec3(0.f), glm::vec3(0.f, 1.f, 0.f));
#endif
    
    glUseProgram(_program->getId());
    _program->setUniform("MVP", _projection * _modelView);
    _program->setUniformInt("useUniformColour", 0);
}

@end
