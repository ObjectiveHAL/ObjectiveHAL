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

- (void)enqueueRequestOperations:(NSArray *)operations traversalContext:context completionHandler:(OHCompletionHandler)completion;

- (NSOperation *)operationToTraverseLinkForPath:(NSString *)path traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler;

- (NSOperation *)operationToTraverseLinkForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler;

- (NSArray *)operationsToTraverseLinksForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler;

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

- (void)traverseLinkForPath:(NSString *)path traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion
{
    NSOperation *op = [self operationToTraverseLinkForPath:path traversalContext:context traversalHandler:handler];
    [self enqueueRequestOperations:@[op] traversalContext:context completionHandler:completion];
}

- (void)traverseLinkForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion
{
    NSOperation *op = [self operationToTraverseLinkForRel:rel inResource:resource traversalContext:context traversalHandler:handler];
    [self enqueueRequestOperations:@[op] traversalContext:context completionHandler:completion];
}

- (void)traverseLinksForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion
{
    NSArray *ops = [self operationsToTraverseLinksForRel:rel inResource:resource traversalContext:context traversalHandler:handler];
    [self enqueueRequestOperations:ops traversalContext:context completionHandler:completion];
}

// *****************************************************************************
#pragma mark -                               Internal NSOperation Helper Methods
// *****************************************************************************

- (void)enqueueRequestOperations:(NSArray *)operations traversalContext:context completionHandler:(OHCompletionHandler)completion
{
    NSOperation *completionOp = [NSBlockOperation blockOperationWithBlock:^{
        completion(context);
    }];
    
    for (id genericOperation in operations) {
        
        [completionOp addDependency:genericOperation];
        
        if ([genericOperation isKindOfClass:[AFHTTPRequestOperation class]]) {
            [self enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)genericOperation];
        } else {
            [self.embeddedResourceOperationQueue addOperation:(NSOperation *)genericOperation];
        }
    }

    [[NSOperationQueue mainQueue] addOperation:completionOp];
}

- (NSOperation *)operationToTraverseLinkForPath:(NSString *)path traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            OHResource *resource = [[OHResource alloc] initWithJSONData:jsonData];
            handler(resource, nil, context);
        } else {
            handler(nil, error, context);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(nil, error, context);
    }];
    return op;
}

- (NSOperation *)operationToTraverseLinkForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler
{
    OHLink *link = [resource linkForRel:rel];

    if (resource.useEmbeddedResources == YES) {
        OHResource *embeddedResource = [resource embeddedResourceForRel:rel];
        if (embeddedResource) {
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                handler(embeddedResource, nil, context);
            }];
            return op;
        }
    }
    
    return [self operationToTraverseLinkForPath:[link href] traversalContext:context traversalHandler:handler];
}

- (NSArray *)operationsToTraverseLinksForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id)context traversalHandler:(OHLinkTraversalHandler)handler
{
    NSMutableArray *operations = [NSMutableArray array];
    NSMutableArray *links = [NSMutableArray arrayWithArray:[resource linksForRel:rel]];

    // Processs embedded resources...
    if (resource.useEmbeddedResources == YES) {
        NSArray *embeddedResources = [resource embeddedResourcesForRel:rel];
        for (OHResource *embeddedResource in embeddedResources) {
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                handler(embeddedResource, nil, context);
            }];
            [operations addObject:op];
            
            OHLink *resourceLink = [[OHLink alloc] initWithRel:rel href:[[embeddedResource linkForRel:@"self"] href]];
            [links removeObject:resourceLink];
        }
    }
    
    // Fetch remaining resources...
    for (OHLink *link in links) {
        NSOperation *op = [self operationToTraverseLinkForPath:[link href] traversalContext:context traversalHandler:handler];
        [operations addObject:op];
    }
    
    return operations;
}

@end
