//
//  OHLinkTraverser.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/26/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OHLinkTraverser;
@class OHResource;

typedef void (^OHLinkTraversalHandler)(OHLinkTraverser *traverser, OHResource *targetResource, NSError *error);
typedef void (^OHCompletionHandler)(OHLinkTraverser *traverser);

@interface OHLinkTraverser : NSObject

@property (readonly, strong, nonatomic) AFHTTPClient *client;
@property (readwrite, strong, nonatomic) id traversalContext;

+ (void)traversePath:(NSString *)path withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler;

+ (OHLinkTraverser *)beginTraversalForRel:(NSString *)rel inResource:(OHResource *)resource withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion;

- (OHLinkTraverser *)queueTraversalForRel:(NSString *)rel inResource:(OHResource *)resource withLinkTraverser:(OHLinkTraverser *)context traversalHandler:(OHLinkTraversalHandler)handler;

@end
