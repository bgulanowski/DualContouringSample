//
//  GLView.h
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GLProgram;
@class Model;

@interface GLView : NSOpenGLView

@property (nonatomic) GLProgram *program;
@property (nonatomic) Model *model;
@property (nonatomic) NSTimer *timer;

@end
