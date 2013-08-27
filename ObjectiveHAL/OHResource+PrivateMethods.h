//
//  OHResource+PrivateMethods.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/5/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHResource.h"

// These are only here to aide with writing unit tests. No one should
// use these in normal opeartions.
@interface OHResource (PrivateMethods)
- (OHResource *)embeddedResourceForRel:(NSString *)rel;
- (NSArray *)embeddedResourcesForRel:(NSString *)rel;
- (AFHTTPClient *)client;
- (NSDictionary *)links;
- (NSDictionary *)curies;
- (NSDictionary *)embedded;
- (NSDictionary *)resourceJSON;
@end
