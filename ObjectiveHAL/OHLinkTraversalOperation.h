//
//  OHLinkTraversalOperation
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/26/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OHLinkTraversalOperation;
@class OHResource;

typedef NSArray *(^OHLinkTraversalHandler)(OHResource *targetResource, NSError *error);
typedef void (^OHCompletionHandler)();

@interface OHLinkTraversalOperation : NSOperation
@property (readonly, strong, nonatomic) NSString *rel;
@property (readonly, strong, nonatomic) NSString *path;
@property (readonly, strong, nonatomic) AFHTTPClient *client;
+ (OHLinkTraversalOperation *)traverseRel:(NSString *)rel inResource:(OHResource *)resource withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion;
+ (OHLinkTraversalOperation *)traversePath:(NSString *)path withClient:(AFHTTPClient *)client  traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion;
@end
