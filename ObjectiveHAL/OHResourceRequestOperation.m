//
//  OHResourceRequestOperation.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/20/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHResourceRequestOperation.h"

@implementation OHResourceRequestOperation

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    NSSet *contentTypes = [NSSet setWithObjects:@"application/hal+json", nil];
    return [contentTypes setByAddingObjectsFromSet:[super acceptableContentTypes]];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    
    return [[[request URL] pathExtension] isEqualToString:@"json"] || [super canProcessRequest:request];
}

@end
