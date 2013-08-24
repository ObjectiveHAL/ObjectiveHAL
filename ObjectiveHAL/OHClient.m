//
//  OHClient.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/4/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import <Security/Security.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <AFNetworking/AFNetworking.h>

#import "OHResourceRequestOperation.h"
#import "OHClient.h"
#import "OHResource.h"
#import "OHLink.h"
#import "HTTPStatusCodes.h"

@interface OHClient ()
@end

@implementation OHClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        // Additional initialization goes here.
        [self registerHTTPOperationClass:[OHResourceRequestOperation class]];
    }
    return self;
}

- (void)fetchRootObjectFromPath:(NSString *)path
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    OHResourceRequestOperation *operation = [OHResourceRequestOperation OHResourceRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, OHResource *targetResource) {

        // TODO: Make KVO atomic with @synchronize on self.
        [self willChangeValueForKey:@"rootObjectAvailable"];
        [self willChangeValueForKey:@"rootObject"];
        
        _rootObject = targetResource;
        _rootObjectAvailable = YES;
        
        [self didChangeValueForKey:@"rootObject"];
        [self didChangeValueForKey:@"rootObjectAvailable"];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

        // TODO: Make KVO atomic with @synchronize on self.
        [self willChangeValueForKey:@"rootObjectAvailable"];
        [self willChangeValueForKey:@"rootObject"];
        
        _rootObject = nil;
        _rootObjectAvailable = NO;
        
        [self didChangeValueForKey:@"rootObject"];
        [self didChangeValueForKey:@"rootObjectAvailable"];
        
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)fetchResourceFromPath:(NSString *)path traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    OHResourceRequestOperation *operation = [OHResourceRequestOperation OHResourceRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, OHResource *targetResource) {
        handler(path, targetResource, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completion(path);
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)traverseLinks:(NSArray *)links forRel:(NSString *)rel inResource:(OHResource *)resource traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion
{
    NSMutableArray *operations = [NSMutableArray array];
    
    for (OHLink *link in links) {
        NSString *path = [link href];
        NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
        OHResourceRequestOperation *op = [OHResourceRequestOperation OHResourceRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, OHResource *targetResource) {
            
            handler(rel, targetResource, nil);
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            
            handler(rel, nil, error);
            
        }];
        [operations addObject:op];
    }
    
    [self enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %d of %d operations", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"Completed all operations");
        completion(rel);
    }];
}

@end
