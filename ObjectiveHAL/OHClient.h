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

- (void)followLinkForPath:(NSString *)path whenFinished:(ObjectiveHALFollowHandler)followHandler;

- (void)followLinkForRel:(NSString *)rel inResource:(OHResource *)resource whenFinished:(ObjectiveHALFollowHandler)followHandler;

- (void)followLinksForRel:(NSString *)rel inResource:(OHResource *)resource forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler;

@end
