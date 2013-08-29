//
//  OHLinkTraversalOperation
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/26/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFJSONRequestOperation.h>

#import "OHLinkTraversalOperation.h"
#import "OHResource.h"
#import "OHResourceRequestOperation.h"

@interface OHLinkTraversalOperation ()
@property (readwrite, strong, nonatomic) NSString *rel;
@property (readwrite, strong, nonatomic) NSString *path;

@property (readwrite, strong, nonatomic) OHResource *resource;
@property (readwrite, strong, nonatomic) OHLinkTraversalHandler traversalHandler;
@property (readwrite, strong, nonatomic) OHCompletionHandler completionHandler;

@property (readwrite, strong, nonatomic) NSOperationQueue *operationQueue;
@property (readwrite, strong, nonatomic) NSArray *embeddedOperations;
@property (readwrite, strong, nonatomic) NSArray *externalOperations;
@property (readwrite, strong, nonatomic) NSArray *nestedOperations;

@property (readwrite, strong, nonatomic) NSMutableArray *resources;

@property (readwrite, strong, nonatomic) AFHTTPClient *client;
@end

@implementation OHLinkTraversalOperation

+ (OHLinkTraversalOperation *)traverseRel:(NSString *)rel inResource:(OHResource *)resource withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion {
    
    OHLinkTraversalOperation *op = [[OHLinkTraversalOperation alloc] init];
    op.operationQueue = [[NSOperationQueue alloc] init];
    op.rel = rel;
    op.path = nil;
    op.traversalHandler = handler;
    op.completionHandler = completion;
    op.client = client;
    op.resource = resource;
    op.resources = [NSMutableArray array];
    
    OHLinkTraversalOperation * __weak weakOperation = op;
    op.completionBlock = ^{
        [weakOperation queueNestedOperations];
        [weakOperation.operationQueue waitUntilAllOperationsAreFinished];
        [weakOperation callCompletionHandler];
    };
    
    return op;
}

+ (OHLinkTraversalOperation *)traversePath:(NSString *)path withClient:(AFHTTPClient *)client  traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion {
    
    OHLinkTraversalOperation *op = [[OHLinkTraversalOperation alloc] init];
    op.operationQueue = [[NSOperationQueue alloc] init];
    op.path = path;
    op.rel = nil;
    op.traversalHandler = handler;
    op.completionHandler = completion;
    op.client = client;
    op.resource = nil;
    op.resources = [NSMutableArray array];
    
    OHLinkTraversalOperation * __weak weakOperation = op;
    op.completionBlock = ^{
        [weakOperation queueNestedOperations];
        [weakOperation.operationQueue waitUntilAllOperationsAreFinished];
        [weakOperation callCompletionHandler];
    };
    
    return op;
}

- (void)main {
    [self composeTraversalOperations];
    [self queueTraversalOperations];
    
    [self.operationQueue waitUntilAllOperationsAreFinished];
    
    [self processExternalOperations];
    [self callTraversalHandlers];
}

- (void)callTraversalHandlers {
    NSMutableArray *nestedOperations = [NSMutableArray array];
    for (OHResource *resource in self.resources) {
        if (self.traversalHandler) {
            NSArray *ops = self.traversalHandler(resource, nil);
            [nestedOperations addObjectsFromArray:ops];
        }
    }
    self.nestedOperations = [NSArray arrayWithArray:nestedOperations];
}

- (void)callCompletionHandler {
    if (self.completionHandler) {
        self.completionHandler(self);
    }
}

- (void)processExternalOperations {
    for (OHResourceRequestOperation *operation in self.externalOperations) {
        id resourceJSON = [operation responseJSON];
        if (resourceJSON) {
            OHResource *resource = [OHResource resourceWithJSONData:resourceJSON];
            if (resource) {
                [self.resources addObject:resource];
            }
        }
    }
}

- (void)cancel {
    [super cancel];
    for (NSOperation *op in self.externalOperations) {
        [op cancel];
    }
    for (NSOperation *op in self.embeddedOperations) {
        [op cancel];
    }
}

- (void)queueTraversalOperations {
    for (NSOperation *operation in self.embeddedOperations) {
        [self.operationQueue addOperation:operation];
    }
    for (NSOperation *operation in self.externalOperations) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)queueNestedOperations {
    for (NSOperation *operation in self.nestedOperations) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)composeTraversalOperations {
    if (self.path && !self.rel) {
        self.externalOperations = @[ [self operationToTraversePath:self.path] ];
    }
    else if (self.rel && !self.path) {
        self.embeddedOperations = [self composeEmbeddedTraversalOperations];
        self.externalOperations = [self composeExternalTraversalOperations];
    }
}

- (NSArray *)composeExternalTraversalOperations {
    
    NSMutableArray *externalTraversalOperations = [NSMutableArray array];
    NSArray *linkedResourceLinks = [self.resource externalLinksForRel:self.rel];
    
    for (OHLink *link in linkedResourceLinks) {
        NSString *path = [link href];
        NSOperation *operation = [self operationToTraversePath:path];
        [externalTraversalOperations addObject:operation];
    }
    
    return externalTraversalOperations;
}

- (NSArray *)composeEmbeddedTraversalOperations {
    
    NSMutableArray *embeddedTraversalOperations = [NSMutableArray array];
    NSArray *embeddedResourceLinks = [self.resource embeddedLinksForRel:self.rel];
    
    for (OHLink *link in embeddedResourceLinks) {
        NSOperation *operation = [self operationToTraverseEmbeddedLink:link inResource:self.resource];
        [embeddedTraversalOperations addObject:operation];
    }
    
    return embeddedTraversalOperations;
}
- (NSOperation *)operationToTraverseEmbeddedLink:(OHLink *)link inResource:(OHResource *)resource {
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        OHResource *targetResource = [resource embeddedResourceForLink:link];
        if (targetResource) {
            [self.resources addObject:targetResource];
        }
        else {
            // TODO: Create and pass back an NSError indicating that
            // the resource we expected to find embedded was not there.
            // (Or, should we try to traverse to the external link on
            // a failure?)
        }
        
    }];
    
    return op;
}

- (NSOperation *)operationToTraversePath:(NSString *)path {
    NSMutableURLRequest *request = [self.client requestWithMethod:@"GET" path:path parameters:nil];
    
    // TODO: Look into proper way to handle cached responses so we can re-enable the default cache policy.
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    OHResourceRequestOperation *op = [[OHResourceRequestOperation alloc] initWithRequest:request];
    return op;
}

@end
