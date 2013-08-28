//
//  OHResourceRequestOperation.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/20/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHResourceRequestOperation.h"

#import "OHResource.h"

@interface OHResourceRequestOperation ()
@property (readwrite, nonatomic, strong) OHResource *targetResource;
@property (readwrite, nonatomic, strong) NSError *JSONError;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation OHResourceRequestOperation

+ (instancetype)OHResourceRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, OHResource *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure
{
    OHResourceRequestOperation *requestOperation = [(OHResourceRequestOperation *)[self alloc] initWithRequest:urlRequest];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            OHResource *targetResource = [OHResource resourceWithJSONData:responseObject];
            success(operation.request, operation.response, targetResource);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(operation.request, operation.response, error, [(OHResourceRequestOperation *)operation responseJSON]);
        }
        
    }];
    
    return requestOperation;
}

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    NSSet *contentTypes = [NSSet setWithObjects:@"application/hal+json", nil];
    return [contentTypes setByAddingObjectsFromSet:[super acceptableContentTypes]];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    
    return [[[request URL] pathExtension] isEqualToString:@"json"] || [super canProcessRequest:request];
}

@end
