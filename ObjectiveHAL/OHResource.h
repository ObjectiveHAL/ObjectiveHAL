//
//  OHResource.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OHLink;

@interface OHResource : NSObject

- (id)initWithJSONData:(id)jsonData;
+ (OHResource *)resourceWithJSONData:(id)jsonData;

- (OHLink *)linkForRel:(NSString *)rel;
- (NSArray *)linksForRel:(NSString *)rel;

@end
