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
@protocol OHClientContext;

typedef void (^OHLinkTraversalHandler)(OHResource *targetResource, NSError *error, id<OHClientContext> traversalContext);
typedef void (^OHCompletionHandler)(id traversalContext);

@interface OHClient : AFHTTPClient

@property (nonatomic, strong) OHResource *rootObject;

- (void)traverseLinkForPath:(NSString *)path traversalContext:(id<OHClientContext>)context traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion;

- (void)traverseLinkForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id<OHClientContext>)context traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion;

- (void)traverseLinksForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id<OHClientContext>)context traversalHandler:(OHLinkTraversalHandler)handler completionHandler:(OHCompletionHandler)completion;

- (void)enqueueRequestOperations:(NSArray *)operations traversalContext:context completionHandler:(OHCompletionHandler)completion;

- (NSOperation *)operationToTraverseLinkForPath:(NSString *)path traversalContext:(id<OHClientContext>)context traversalHandler:(OHLinkTraversalHandler)handler;

- (NSOperation *)operationToTraverseLinkForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id<OHClientContext>)context traversalHandler:(OHLinkTraversalHandler)handler;

- (NSArray *)operationsToTraverseLinksForRel:(NSString *)rel inResource:(OHResource *)resource traversalContext:(id<OHClientContext>)context traversalHandler:(OHLinkTraversalHandler)handler;

@end
