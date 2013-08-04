//
//  OHResource.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OHLink;

@interface OHResource : NSObject

- (id)initWithJSONData:(id)jsonData;

- (OHLink *)linkForRel:(NSString *)rel;
- (NSArray *)linksForRel:(NSString *)rel;

- (id)embeddedJSONDataForLink:(OHLink *)link;

@end
