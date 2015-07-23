//
//  Utility.m
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-17.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "Utility.h"

void LogBlockDuration(NSString *description, dispatch_block_t block) {
    
    NSDate *start = [NSDate date];
    NSLog(@"Starting '%@'", description);
    if (block) {
        block();
    }
    NSLog(@"Finished '%@'; duration: %.3f", description, [[NSDate date] timeIntervalSinceDate:start]);
}
