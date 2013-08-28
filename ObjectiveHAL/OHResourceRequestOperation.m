//
//  OHResourceRequestOperation.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/20/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFJSONRequestOperation.h>

#import "OHResourceRequestOperation.h"

#import "OHResource.h"

@interface OHResourceRequestOperation ()
@property (readwrite, nonatomic, strong) OHResource *targetResource;
@property (readwrite, nonatomic, strong) NSError *JSONError;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation OHResourceRequestOperation

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (self) {
        //
    }
    return self;
}

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    NSSet *contentTypes = [NSSet setWithObjects:@"application/hal+json", nil];
    return [contentTypes setByAddingObjectsFromSet:[super acceptableContentTypes]];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    
    return [[[request URL] pathExtension] isEqualToString:@"json"] || [super canProcessRequest:request];
}

@end
