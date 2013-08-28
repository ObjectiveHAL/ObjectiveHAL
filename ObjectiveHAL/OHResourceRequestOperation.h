//
//  OHResourceRequestOperation.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/20/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "OHResource.h"

/**
 A subclass of `AFJSONRequestOperation` that is capabile of processing
 requests for the content type 'application/hal+json' in addition to
 the default 'application/json' conten type.
 */
@interface OHResourceRequestOperation : AFJSONRequestOperation

/**
 Initializes and returns a newly allocated operation object with a url connection configured with the specified url request.
 
 This is the designated initializer.
 
 @param urlRequest The request object to be used by the operation connection.
 */
- (id)initWithRequest:(NSURLRequest *)urlRequest;

@end
