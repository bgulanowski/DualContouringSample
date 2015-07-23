//
//  GLView.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "GLView.h"

#import "GLProgram.h"
#import "Model.h"

#import <OpenGL/gl3.h>

@interface NSOpenGLPixelFormat (GLView)

@property (nonatomic, readonly) GLint profile;

+ (instancetype)glViewFormat;

@end


@implementation GLView

- (void)awakeFromNib {
    if ([self pixelFormat].profile == NSOpenGLProfileVersionLegacy) {
        [self setOpenGLContext:[[NSOpenGLContext alloc] initWithFormat:[NSOpenGLPixelFormat glViewFormat] shareContext:nil]];
        _timer =  [NSTimer scheduledTimerWithTimeInterval:1./30. target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    }
}

- (void)setNeedsDisplay { self.needsDisplay = YES; }

- (void)drawRect:(NSRect)dirtyRect {

    glClearColor(0.f, 0.f, 0.f, 0.f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);

    [self.program use];
    [self.model draw];
    
    [self.openGLContext flushBuffer];
}

- (void)reshape {
    NSSize size = [self bounds].size;
    glViewport( 0, 0, size.width, size.height );
}

@end


@implementation NSOpenGLPixelFormat (GLView)

+ (instancetype)glViewFormat {
    
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 32,
        0
    };
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}

- (GLint)profile {
    GLint profile;
    [self getValues:&profile forAttribute:NSOpenGLPFAOpenGLProfile forVirtualScreen:0];
    return profile;
}

@end
