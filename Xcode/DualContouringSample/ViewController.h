//
//  ViewController.h
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-11.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GLView;

@interface ViewController : NSViewController

@property (weak) IBOutlet GLView *glView;
@property (nonatomic) NSString *saveFolder;

- (void)start;

@end

