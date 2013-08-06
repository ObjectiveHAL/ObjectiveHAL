//
//  OHClient.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/4/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

#import "OHClient.h"
#import "OHResource.h"
#import "OHLink.h"
#import "HTTPStatusCodes.h"

@interface OHClient ()
@end

@implementation OHClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        // Additional initialization goes here.
    }
    return self;
}

// *****************************************************************************
#pragma mark -                                       HAL Resource Access Methods
// *****************************************************************************

- (void)followLinkForPath:(NSString *)path whenFinished:(ObjectiveHALFollowHandler)followHandler;
{
    OHLink *synthesizedLink = [[OHLink alloc] initWithRel:@"http://tempuri.org/rel/unknown" href:path];
    [self getPath:path parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self processHALResourceResponse:responseObject forLink:synthesizedLink followHandler:followHandler];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              followHandler(synthesizedLink, nil, error);
          }
     ];
}

- (void)followLinkForRel:(NSString *)rel inResource:(OHResource *)resource whenFinished:(ObjectiveHALFollowHandler)followHandler
{
    OHLink *link = [resource linkForRel:rel];
    
    OHResource *embeddedResource = [resource embeddedResourceForRel:rel];
    if (embeddedResource) {
        followHandler(link, embeddedResource, nil);
    } else {
        AFHTTPRequestOperation *operation = [self constructOperationToFollowLink:link];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self processHALResourceResponse:responseObject forLink:link followHandler:followHandler];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            followHandler(link, nil, error);
        }];
        [self enqueueHTTPRequestOperation:operation];
    }
}

- (void)followLinksForRel:(NSString *)rel inResource:(OHResource *)resource forEach:(ObjectiveHALFollowHandler)followHandler whenFinished:(ObjectiveHALCompletionHandler)completionHandler
{
    NSArray *links = [resource linksForRel:rel];
    NSMutableArray *followRequests = [NSMutableArray array];
    NSMutableDictionary *followRequestLinkMap = [NSMutableDictionary dictionary];
    [self prepareFollowRequests:followRequests withLinkMap:followRequestLinkMap usingLinks:links];
    
    [self enqueueBatchOfHTTPRequestOperationsWithRequests:followRequests progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        // DO NOTHING HERE
    } completionBlock:^(NSArray *operations) {
        [self processOperations:operations usingFollowRequestLinkMap:followRequestLinkMap visiting:followHandler];
        completionHandler();
    }];
}

// *****************************************************************************
#pragma mark -                                           Internal Helper Methods
// *****************************************************************************

- (void)processHALResourceResponse:(id)responseObject resourceHandler:(ObjectiveHALResourceHandler)resourceHandler
{
    NSError *error = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
    if (!error) {
        OHResource *resource = [[OHResource alloc] initWithJSONData:jsonData];
        resourceHandler(resource, error);
    } else {
        resourceHandler(nil, error);
    }
}

- (void)prepareFollowRequests:(NSMutableArray *)followRequests withLinkMap:(NSMutableDictionary *)followRequestLinkMap usingLinks:(NSArray *)links
{
    for (OHLink *link in links) {
        NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[link href] parameters:nil];
        [followRequests addObject:request];
        [followRequestLinkMap setObject:link forKey:request];
    }
}

- (void)processOperation:(AFHTTPRequestOperation *)operation usingFollowRequestLinkMap:(NSDictionary *)followRequestLinkMap visiting:(ObjectiveHALFollowHandler)followHandler
{
    if ([[operation response] statusCode] == kHTTPStatusCodeOK) {
        id responseObject = [operation responseData];
        OHLink *link = [followRequestLinkMap objectForKey:[operation request]];
        [self processHALResourceResponse:responseObject forLink:link followHandler:followHandler];
    }
}

- (void)processOperations:(NSArray *)operations usingFollowRequestLinkMap:(NSDictionary *)followRequestLinkMap visiting:(ObjectiveHALFollowHandler)followHandler
{
    for (AFHTTPRequestOperation *operation in operations) {
        [self processOperation:operation usingFollowRequestLinkMap:followRequestLinkMap visiting:followHandler];
    }
}

- (AFHTTPRequestOperation *)constructOperationToFollowLink:(OHLink *)link
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[link href] parameters:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // DO NOTHING HERE
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // DO NOTHING HERE
    }];
    return operation;
}

- (void)processHALResourceResponse:(id)responseObject forLink:(OHLink *)link followHandler:(ObjectiveHALFollowHandler)followHandler
{
    NSError *error = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
    if (!error) {
        OHResource *resource = [[OHResource alloc] initWithJSONData:jsonData];
        followHandler(link, resource, error);
    } else {
        followHandler(link, nil, error);
    }
}

@end
