//
//  GLProgram.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "GLProgram.h"

#import "glsl_program.h"
#import <glm/gtx/transform.inl>

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
    
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vert"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"frag"];
    
    _program = new GLSLProgram();
    if (!_program->initialise() ||
        !_program->compileShader(ShaderType_Vertex, [vertexShaderPath UTF8String]) ||
        !_program->compileShader(ShaderType_Fragment, [fragmentShaderPath UTF8String]) ||
        !_program->link())
    {
        [NSException raise:NSGenericException format:@"Failed to create GLSL program"];
    }
}

- (void)use {
    
    static float rotate = 270.0f;

    rotate += 1.0f;
    if (rotate > 360.0f) {
        rotate = 0.0f;
    }

    float distance = 40.0f;
    glm::vec3 dir(0, 0, 1.f);
    dir = glm::rotateY(dir, glm::radians(rotate));
    
    glm::vec3 position = dir * distance;
//    glm::vec3 position = glm::vec3(0, 0, 50.f);
    glm::mat4 model = glm::rotate(glm::radians(90.0f), glm::vec3(0.0, 0.0, 1.0));
    glm::mat4 modelview = glm::lookAt(position, glm::vec3(0.f), glm::vec3(0.f, 1.f, 0.f)) * model;
    
    glm::mat4 projection = glm::perspective(60.f, 16.f/9.f, 0.1f, 500.f);
    glm::mat4 transform = projection * modelview;
    
    glUseProgram(_program->getId());
    _program->setUniform("MVP", transform);
    _program->setUniformInt("useUniformColour", 0);
}

@end
