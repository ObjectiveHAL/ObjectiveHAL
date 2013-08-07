//
//  OHResource.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OHLink;

@interface OHResource : NSObject <NSCopying>

@property (nonatomic, assign) BOOL useEmbeddedResources;
@property (nonatomic, strong, readonly) NSDictionary *json;

- (id)initWithJSONData:(id)jsonData;
+ (OHResource *)resourceWithJSONData:(id)jsonData;

- (OHLink *)linkForRel:(NSString *)rel;
- (NSArray *)linksForRel:(NSString *)rel;

- (OHResource *)embeddedResourceForRel:(NSString *)rel;
- (NSArray *)embeddedResourcesForRel:(NSString *)rel;

- (OHResource *)embeddedResourceForLink:(OHLink *)link;

@end
