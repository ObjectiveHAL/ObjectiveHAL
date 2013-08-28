//
//  OHResource.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OHResource.h"
#import "OHLink.h"

/** A HAL Resource
 
 This class provides for easy manipulation of a HAL resource. Refer to the
 JSON Hypertext Application Language (HAL) specification on the 
 [IETF web site](http://tools.ietf.org/html/draft-kelly-json-hal).
 
 */
@interface OHResource : NSObject <NSCopying>

#pragma mark - Properties
/*******************************************************************************
 * @name Properties
 */

/** Determines whether or not embedded resources should be considered during traversal operations.
 
 The default value for useEmbeddedResources is NO. This causes ObjectiveHAL to perform
 all traversal operations by actually querying the server for the linked resources.
 
 Set useEmbeddedResources to YES if you wish to have ObjectiveHAL first check for an
 embedded resource, and use it if present.
 
 */
@property (nonatomic, assign) BOOL useEmbeddedResources;

/** The state of the resource.
 
 This is a dictionary containing the state of the resource, excluding the HAL
 "_links" and "_embedded" properties.
 
 */
@property (readonly, nonatomic, strong) NSDictionary *resourceJSON;

/** The HAL links.
 */
@property (readonly, nonatomic, strong) NSDictionary *links;

/** The HAL curies.
 */
@property (readonly, nonatomic, strong) NSDictionary *curies;

/** The HAL embedded resources.
 */
@property (readonly, nonatomic, strong) NSDictionary *embedded;

#pragma mark - Initializing an OHResource object
/*******************************************************************************
 * @name Initializing an OHResource object
 */

/** Create an OHResource with the provided JSON.
 
 @param jsonData An NSDictionary containing the JSON data retrieved from a server.

 */
+ (OHResource *)resourceWithJSONData:(id)jsonData;

/** Initialize an OHResource instance with the provided JSON.
 
 @param jsonData An NSDictionary containing the JSON data retrieved from a server.
 
 */
- (id)initWithJSONData:(id)jsonData;

/** Create an embedded OHResource with the provided JSON and curies.
 
 @param jsonData An NSDictionary containing the JSON data retrieved from a server.
 @param curies An NSDictionary containing the curies that should be used when interpreting
 link relations in this OHResource.
 
 */
+ (OHResource *)embeddedResourceWithJSONData:(id)jsonData
                                      curies:(NSDictionary *)curies;

/** Initialize an embedded OHResource instance with the provided JSON and curies.
 
 @param jsonData An NSDictionary containing the JSON data retrieved from a server.
 @param curies An NSDictionary containing the curies that should be used when interpreting
 link relations in this OHResource.
 
 */
- (id)initWithJSONData:(id)jsonData
                curies:(NSDictionary *)curies;

#pragma mark - Accessing Links for Relations
/*******************************************************************************
 * @name Accessing Links for Relations
 */

/** Get the HAL resource link for the specified relation.
 
 @param rel The link relation. Can be specified either using the full URI syntax
            or using the curies defined for the resource.
 @return The OHLink or nil if no link relation exists.
 */
- (OHLink *)linkForRel:(NSString *)rel;

/** Get HAL resource links for the specified relation.
 
 @param rel The link relation. Can be specified either using the full URI syntax
 or using the curies defined for the resource.
 @return An NSArray containing instances of OHLink, or nil if no link relations exists.
 */
- (NSArray *)linksForRel:(NSString *)rel;

- (NSArray *)embeddedLinksForRel:(NSString *)rel;
- (NSArray *)externalLinksForRel:(NSString *)rel;

#pragma mark - Accessing Embedded Resources
/*******************************************************************************
 * @name Accessing Embedded Resources
 */

/** Retrieve embedded resource for relation.
 
 @param rel     The link relation for the requested embedded resource. This 
                may be specified using a curie or as a full URI.
 @returns       An OHResource or nil if no link exists in the resource for the
                specified relation.
 */
- (OHResource *)embeddedResourceForRel:(NSString *)rel;

/** Retrieve embedded resource for relation.
 
 @param rel     The link relation for the requested embedded resource. This
                may be specified using a curie or as a full URI.
 @returns       An NSArray containing OHResource instances or nil if no links 
                exist in the resource for the specified relation.
 */
- (NSArray *)embeddedResourcesForRel:(NSString *)rel;

// TODO: Figure out where this is used. It seems like this method should be internal.
- (OHResource *)embeddedResourceForLink:(OHLink *)link;

/** Expand a rel using a set of curies.

 @param rel The link relation.
 @param curies The curies.
 
 */
+ (NSString *)expandRelationIfPossible:(NSString *)rel withCuries:(NSDictionary *)curies;

@end
