//
//  AppDelegate.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-11.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "Model.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, readonly) ViewController *viewController;
@end

NS_INLINE NSString *AppFolder( void ) {
    NSString *appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).lastObject;
    NSString *appFolderName = [[NSProcessInfo processInfo] processName];
    return [appSupportDir stringByAppendingPathComponent:appFolderName];
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ViewController *vc = self.viewController;
    vc.saveFolder = AppFolder();
    [vc start];
}

- (ViewController *)viewController {
    return (ViewController *)[[NSApp.windows lastObject] contentViewController];
}

@end
