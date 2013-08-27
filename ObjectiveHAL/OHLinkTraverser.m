//
//  OHLinkTraverser.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/26/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHLinkTraverser.h"
#import "OHResource.h"
#import "OHResourceRequestOperation.h"

@interface OHLinkTraverser ()
@property (readwrite, strong, nonatomic) AFHTTPClient *client;
@property (readwrite, strong, nonatomic) NSOperation *completionBlockOperation;
@property (readwrite, assign, nonatomic, getter=isCompletionOperationInQueue) BOOL completionOperationInQueue;
@end

@implementation OHLinkTraverser

+ (void)traversePath:(NSString *)path withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler {
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:path parameters:nil];
    
    OHResourceRequestOperation *op = [OHResourceRequestOperation OHResourceRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, OHResource *targetResource) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, targetResource, nil);
            });
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, nil, error);
            });
        }
    }];
    [client enqueueHTTPRequestOperation:op];
}

+ (OHLinkTraverser *)beginTraversalForRel:(NSString *)rel inResource:(OHResource *)resource withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion {
    OHLinkTraverser *traverser = [[OHLinkTraverser alloc] init];
    traverser.completionOperationInQueue = NO;
    traverser.client = client;
    traverser.completionBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(traverser);
            });
        }
    }];

    return [traverser queueTraversalForRel:rel inResource:resource withLinkTraverser:traverser traversalHandler:handler];
}

- (OHLinkTraverser *)queueTraversalForRel:(NSString *)rel inResource:(OHResource *)resource withLinkTraverser:(OHLinkTraverser *)traverser traversalHandler:(OHLinkTraversalHandler)handler {

    NSMutableArray *traversalOperations = [NSMutableArray array];
    
    NSArray *embeddedResourceLinks = [resource embeddedLinksForRel:rel];
    for (OHLink *link in embeddedResourceLinks) {
        NSOperation *operation = [self operationToTraverseEmbeddedLink:link inResource:resource traversalHandler:handler];
        [traversalOperations addObject:operation];
        [self.completionBlockOperation addDependency:operation];
    }
    
    NSArray *linkedResourceLinks = [resource externalLinksForRel:rel];
    for (OHLink *link in linkedResourceLinks) {
        NSOperation *operation = [self operationToTraverseExternalLink:link traversalHandler:handler];
        [traversalOperations addObject:operation];
        [self.completionBlockOperation addDependency:operation];
    }
    
    if (self.isCompletionOperationInQueue == NO) {
        [traversalOperations addObject:self.completionBlockOperation];
        self.completionOperationInQueue = YES;
    }
    
    [[self.client operationQueue] addOperations:traversalOperations waitUntilFinished:NO];

    return traverser;
}

- (NSOperation *)operationToTraverseEmbeddedLink:(OHLink *)link inResource:(OHResource *)resource traversalHandler:(OHLinkTraversalHandler)handler {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        OHResource *targetResource = [resource embeddedResourceForLink:link];
        
        if (targetResource) {
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(self, targetResource, nil);
                });
            }
        }
        else {
            // TODO: Add a proper error here.
            NSError *error = [NSError errorWithDomain:@"" code:1 userInfo:nil];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil, nil, error);
                });
            }
        }
        
    }];
    return op;
}

- (NSOperation *)operationToTraverseExternalLink:(OHLink *)link traversalHandler:(OHLinkTraversalHandler)handler {
    NSString *path = [link href];
    NSMutableURLRequest *request = [self.client requestWithMethod:@"GET" path:path parameters:nil];
    
    OHResourceRequestOperation *op = [OHResourceRequestOperation OHResourceRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, OHResource *targetResource) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(self, targetResource, nil);
            });
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(self, nil, error);
            });
        }
    }];
    
    return op;
}

@end
