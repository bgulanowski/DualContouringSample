//
//  Model.h
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic) int thresholdIndex;

- (void)reload;
- (void)draw;

@end
