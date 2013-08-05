//
//  OHClient.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/4/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import "AFHTTPClient.h"

@class OHLink;
@class OHResource;

typedef void (^ObjectiveHALResourceHandler)(OHResource *targetResource, NSError *error);
typedef void (^ObjectiveHALFollowHandler)(OHLink *link, OHResource *targetResource, NSError *error);
typedef void (^ObjectiveHALCompletionHandler)(void);

@interface OHClient : AFHTTPClient

// Used to "prime the pump" and get the first resource from a service.
- (void)getOHResource:(NSString *)resourcePath whenFinished:(ObjectiveHALResourceHandler)resourceHandler;

// Follow a link 
- (void)followLink:(OHLink *)link whenFinished:(ObjectiveHALFollowHandler)followHandler;

// Follow all links matching a given rel.
- (void)followLinksInResource:(OHResource *)resource forRel:(NSString *)rel forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler;

@end
