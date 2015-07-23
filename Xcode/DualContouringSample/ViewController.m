//
//  ViewController.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-11.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "ViewController.h"

#import "Model.h"
#import "GLProgram.h"
#import "GLView.h"

@import OpenGL;

@interface ViewController ()
@property (nonatomic) GLProgram *program;
@property (nonatomic) Model *model;
@end

@implementation ViewController

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

- (void)awakeFromNib {
    if (!_program) {
        [self prepareShaders];
    }
    if (!_model) {
        _model = [Model new];
//        [self buildModel];
        [self dispatchBuildModel];
    }
}

@end
