//
//  OHResourceRequestOperation.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/20/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "OHResource.h"

@interface OHResourceRequestOperation : AFJSONRequestOperation

+ (instancetype)OHResourceRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, OHResource * targetResource))success
                                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
