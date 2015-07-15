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

//- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
//    self = [super initWithCoder:coder];
//    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidLoad:) name:NSApplicationDidFinishLaunchingNotification object:nil];
//    }
//    return self;
//}
//
//- (void)applicationDidLoad:(NSNotification *)note {
//    [self buildScene];
//    self.glView.needsDisplay = YES;
//}

- (void)buildScene {
    _model = [Model new];
    [_model reload];
    _program = [GLProgram new];
}

- (void)awakeFromNib {
    if (!_model) {
        [self buildScene];
        self.glView.model = self.model;
        self.glView.program = self.program;
    }
}

@end
