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

#import "OHClient.h"
#import "OHResource.h"
#import "OHLink.h"
#import "HTTPStatusCodes.h"

@interface OHClient ()

/**
 The operation queue which manages operations enqueued to process resources
 embedded in a HAL resource.
 */
@property (readonly, nonatomic, strong) NSOperationQueue *embeddedResourceOperationQueue;

- (NSOperation *)operationToFollowLinkForPath:(NSString *)path whenFinished:(ObjectiveHALFollowHandler)followHandler;
- (NSOperation *)operationToFollowLinkForRel:(NSString *)rel inResource:(OHResource *)resource whenFinished:(ObjectiveHALFollowHandler)followHandler;
- (NSArray *)operationsToFollowLinksForRel:(NSString *)rel inResource:(OHResource *)resource forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler;
- (void)enqueueRequestOperations:(NSArray *)operations;

@end

@implementation OHClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        // Additional initialization goes here.
        _embeddedResourceOperationQueue = [[NSOperationQueue alloc] init];
        [_embeddedResourceOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return self;
}

// *****************************************************************************
#pragma mark -                                       HAL Resource Access Methods
// *****************************************************************************

- (void)followLinkForPath:(NSString *)path whenFinished:(ObjectiveHALFollowHandler)followHandler
{
    NSOperation *op = [self operationToFollowLinkForPath:path whenFinished:followHandler];
    [self enqueueRequestOperations:@[op]];
}

- (void)followLinkForRel:(NSString *)rel inResource:(OHResource *)resource whenFinished:(ObjectiveHALFollowHandler)followHandler
{
    NSOperation *op = [self operationToFollowLinkForRel:rel inResource:resource whenFinished:followHandler];
    [self enqueueRequestOperations:@[op]];
}

- (void)followLinksForRel:(NSString *)rel inResource:(OHResource *)resource forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler
{
    NSArray *ops = [self operationsToFollowLinksForRel:rel inResource:resource forEach:followHandler whenFinished:completionHandler];
    [self enqueueRequestOperations:ops];
}

// *****************************************************************************
#pragma mark -                               Internal NSOperation Helper Methods
// *****************************************************************************

- (void)enqueueRequestOperations:(NSArray *)operations
{
    for (id genericOperation in operations) {
        if ([genericOperation isKindOfClass:[AFHTTPRequestOperation class]]) {
            [self enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)genericOperation];
        } else {
            [self.embeddedResourceOperationQueue addOperation:(NSOperation *)genericOperation];
        }
    }
}

- (NSOperation *)operationToFollowLinkForPath:(NSString *)path whenFinished:(ObjectiveHALFollowHandler)followHandler
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            OHResource *resource = [[OHResource alloc] initWithJSONData:jsonData];
            followHandler(resource, error);
        } else {
            followHandler(nil, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        followHandler(nil, error);
    }];
    return op;
}

- (NSOperation *)operationToFollowLinkForRel:(NSString *)rel inResource:(OHResource *)resource whenFinished:(ObjectiveHALFollowHandler)followHandler
{
    OHLink *link = [resource linkForRel:rel];
    
    if (resource.useEmbeddedResources == YES) {
        OHResource *embeddedResource = [resource embeddedResourceForRel:rel];
        if (embeddedResource) {
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                followHandler(embeddedResource, nil);
            }];
            return op;
        }
    }
    
    return [self operationToFollowLinkForPath:link.href whenFinished:followHandler]; 
}

- (NSArray *)operationsToFollowLinksForRel:(NSString *)rel inResource:(OHResource *)resource forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler
{
    NSOperation *completionOp = [NSBlockOperation blockOperationWithBlock:^{
        completionHandler();
    }];
    
    NSMutableArray *operations = [NSMutableArray array];
    NSArray *links = [resource linksForRel:rel];
    
    for (OHLink *link in links) {
        NSOperation *op = [self operationToFollowLinkForPath:link.href whenFinished:followHandler];
        [completionOp addDependency:op];
        [operations addObject:op];
    }

    [operations addObject:completionOp];
    
    return operations;    
}

@end
