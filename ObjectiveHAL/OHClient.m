//
//  OHClient.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/4/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import "OHClient.h"
#import "OHResource.h"
#import "OHLink.h"

@implementation OHClient

- (void)getOHResource:(NSString *)resourcePath whenFinished:(ObjectiveHALResourceHandler)resourceHandler
{
    [self getPath:resourcePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            OHResource *resource = [[OHResource alloc] initWithJSONData:jsonData];
            resourceHandler(resource, error);
        } else {
            resourceHandler(nil, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        resourceHandler(nil, error);
    }];
}

- (void)followLink:(OHLink *)link whenFinished:(ObjectiveHALFollowHandler)followHandler
{
    [self getPath:[link href] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            OHResource *resource = [[OHResource alloc] initWithJSONData:jsonData];
            followHandler(link, resource, error);
        } else {
            followHandler(link, nil, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        followHandler(link, nil, error);
    }];
}

- (void)followLinksInResource:(OHResource *)resource forRel:(NSString *)rel forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler
{
    NSArray *links = [resource linksForRel:rel];
    for (OHLink *link in links) {
        [self followLink:link whenFinished:followHandler];
    }
    // TODO: Figure out how to wait on operations of followLink:...
    // before we call the completion handler.  It is supposed to signal
    // to the caller that all followLink:... operations had completed.
    completionHandler();
}

@end
