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

/**
 */
typedef NSArray *(^OHLinkTraversalHandler)(OHResource *targetResource, NSError *error);

/**
 */
typedef void (^OHCompletionHandler)();

/** An operation used to perform link traversals between HAL resources.
 */
@interface OHLinkTraversalOperation : NSOperation

/** The link relation used for this traversal operation. 
 
 This will only be set when using the
 `traverseRel:inResource:withClient:TraversalHandler:completion:` 
 factory method.  It will be set to `nil` if the operation was constructed
 using a different factory method.
 */
@property (readonly, strong, nonatomic) NSString *rel;

/** The path (href) used for this traversal operation.
 
 This will only be set when using the
 `traversePath:withClient:traversalHandler:completion:`
 factory method. It will be set to `nil` if the operation was constructed
 using a different factory method.
 */
@property (readonly, strong, nonatomic) NSString *path;

/** The `AFHTTPClient` being used to manage this opeartion.
 */
@property (readonly, strong, nonatomic) AFHTTPClient *client;

/** Construct a `OHLinkTraversalOperation` to traverse a link relation.
 
 This is the workhorse of link traversal.  It enables the caller to
 easily travers all relations in a HAL application.
 
 @param rel The link relation that will be used to evaluate the `resource`.
 @param resource The HAL resource containing the links to the `rel`.
 @param client An `AFHTTPClient` used to perform the network operations.
 @param handler A `OHLinkTraversalHandler` block, called for each resource
 found to match the given `rel`.
 @param completion A `OHCompletionHandler` block, called once all traversals
 for this operation have been completed.
 
 */
+ (OHLinkTraversalOperation *)traverseRel:(NSString *)rel inResource:(OHResource *)resource withClient:(AFHTTPClient *)client traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion;

/** Construct a `OHLinkTraversalOperation` to traverse a path.
 
 Use this class method to initiate the traversal for the root resource
 of a HAL application.  Once the root resource has been fetched all 
 subsequent traversal operations can be performed by specifying link
 relations in one of the other class methods.
 
 @param path The href for a resource that will be traversed to.
 @param client An `AFHTTPClient` used to perform the network operations.
 @param handler A `OHLinkTraversalHandler` block, called for each resource
 found to match the given `rel`.
 @param completion A `OHCompletionHandler` block, called once all traversals
 for this operation have been completed.
 */
+ (OHLinkTraversalOperation *)traversePath:(NSString *)path withClient:(AFHTTPClient *)client  traversalHandler:(OHLinkTraversalHandler)handler completion:(OHCompletionHandler)completion;

@end
