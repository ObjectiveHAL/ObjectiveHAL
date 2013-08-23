//
//  OHLink.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A JSON Hypertext Application Language (HAL) Link
 
 This class provides for easy manipulation of a HAL link. A Link Object represents 
 a hyperlink from the containing resource to a URI. Refer to the JSON Hypertext 
 Application Language (HAL) specification on the 
 [IETF web site](http://tools.ietf.org/html/draft-kelly-json-hal).
 
 */
@interface OHLink : NSObject <NSCopying>

#pragma mark - Properties
/*******************************************************************************
 * @name Properties
 */

/** The link relation type.
 
 Link relation types are defined by [RFC5988](http://tools.ietf.org/html/rfc5988)
 */
@property (strong, nonatomic, readonly) NSString *rel;

/** The URI used to identify the target resource.
 
 The "href" property is REQUIRED. Its value is either a URI 
 [RFC3986](http://tools.ietf.org/html/rfc3986) or a URI Template 
 [RFC6570](http://tools.ietf.org/html/rfc6570).  If the value is a URI Template 
 then the Link Object SHOULD have a "templated" attribute whose value is true.
 
 */
@property (strong, nonatomic, readonly) NSString *href;

/** Indicates if the href for this link is a URI Template.
 This is OPTIONAL, and will be FALSE if the "template" property was not included
 in the JSON used to define the link.
 */
@property (assign, nonatomic, readonly, getter=isTemplate) BOOL templated;

/** Hint to indicate the media type expected when dereferencing the target resource.
 This is OPTIONAL, and will be nil if the "type" property was not included in the
 JSON used to define the link.
 */
@property (strong, nonatomic, readonly) NSString *type;

/** Indicates that the link is to be deprecated at a future date.
 This is OPTIONAL, and will be nil if the "deprecated" property was not included in
 the JSON used to define the link.  The value is a URL that SHOULD provide further 
 information about the deprecation.
 */
@property (strong, nonatomic, readonly) NSString *deprecation;

/** A name used to describe the link.
 This is OPTIONAL, and will be nil if the "name" property was not included in
 the JSON used to define the link. The value MAY be used as a secondary key for
 selecting link objects which share the same relation type.
 
 @warning Currently not supported by ObjectiveHAL.
 */
@property (strong, nonatomic, readonly) NSString *name;

/**
 */
@property (strong, nonatomic, readonly) NSString *profile;

/**
 */
@property (strong, nonatomic, readonly) NSString *title;

/**
 */
@property (strong, nonatomic, readonly) NSString *hreflang;

#pragma mark - Initializing an OHLink object
/*******************************************************************************
 * @name Initializing an OHLink object
 */

/** Initialize an OHLink with properties from a server.
 
 The passed jsonData MUST include the REQUIRED properties and MAY include the
 OPTIONAL properties.
 
 @param rel The link relation type this OHLink defines.
 @param jsonData JSON object containing properties to define a link.
 
 The JSON for a link has the following form:
 
    {
        "href" : "https://example.com/api/customer/1234",
        "name" : "bob",
        "title" : "The Parent",
        "hreflang" : "en",
        "templated" : false
    }
 
 */
- (id)initWithRel:(NSString *)rel jsonData:(id)jsonData;

/** Initialize an OHLink with the minimal set of properties.
 
 The REQUIRED properties are specified by the caller.
 
 @param rel The link relation type this OHLink defines.
 @param href The URI used to identify a linked resource.
 
 */
- (id)initWithRel:(NSString *)rel href:(NSString *)href;

@end
