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

@import OpenGL;

@interface ViewController ()
@property (nonatomic) GLProgram *program;
@property (nonatomic) Model *model;
@end

@implementation ViewController

- (void)buildScene {
    _program = [GLProgram new];
    _model = [Model new];
}

- (void)viewDidLoad {
    [self buildScene];
}

@end
