//
//  ModelSerializer.h
//  DualContouringSample
//
//  Created by Brent Gulanowski on 2015-07-25.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "mesh.h"

@protocol ModelSerializer <NSObject>

- (void)loadVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices folder:(NSString *)folder;
- (void)saveVertices:(VertexBuffer&)vertices indices:(IndexBuffer&)indices folder:(NSString *)folder;

@end
