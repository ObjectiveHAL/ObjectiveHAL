//
//  ObjectiveHAL - OHLinkTraverserTests.m
//  Copyright 2013 ObjectiveHAL. All rights reserved.
//
//  Created by: Bennett Smith
//

    // Class under test
#import "OHLinkTraversalOperation.h"

    // Collaborators
#import "OHLink.h"
#import "OHResource.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFJSONRequestOperation.h>

    // Test support
#import <SenTestingKit/SenTestingKit.h>
#import <FSClassExtensions/SenTestCase+FSClassExtensions.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import "NSData+TestInfected.h"

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>


@interface OHLinkTraverserTests : SenTestCase
@property (readwrite, strong, nonatomic) NSURL *baseURL;
@property (readwrite, strong, nonatomic) AFHTTPClient *client;
@property (readwrite, assign, nonatomic) NSTimeInterval timeout;
@end

@implementation OHLinkTraverserTests

- (void)setUp {
    self.baseURL = [NSURL URLWithString:@"http://localhost:7100"];
    self.client = [AFHTTPClient clientWithBaseURL:self.baseURL];
    self.timeout = 30;
    NSLog(@"vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv");
}

- (void)tearDown {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
}

- (OHResource *)fetchRootResourceFromPath:(NSString *)rootObjectPath {
    
    OHResource * __block rootResource = nil;
    
    OHLinkTraversalOperation *rootOp = [OHLinkTraversalOperation traversePath:rootObjectPath withClient:self.client traversalHandler:^NSArray *(OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        assertThat(targetResource, notNilValue());
        rootResource = targetResource;
        NSLog(@"==> rootResource = %@", rootResource);
        return @[];
    } completion:^{
        [self signalAsyncTestCompleted];
    }];
    
    [[self.client operationQueue] addOperation:rootOp];
    assertThatBool([self waitForAsyncTestCompletion:self.timeout], is(equalToBool(YES)));
    
    return rootResource;
}

- (void)testTraversePathWithClientHandler {
    // given
    NSString *rootObjectPath = @"apps";
    
    // when
    OHResource *rootResource = [self fetchRootResourceFromPath:rootObjectPath];
    
    // then
    assertThat(rootResource, notNilValue());
    assertThat(rootResource.links, hasCountOf(3));
    assertThat(rootResource.embedded, hasCountOf(2));
    assertThat(rootResource.curies, hasCountOf(2));
}

- (void)testBeginTraversalForRel {
    // given
    NSString *rootObjectPath = @"apps";
    OHResource *rootResource = [self fetchRootResourceFromPath:rootObjectPath];
    NSMutableArray * __block applications = [NSMutableArray array];
    
    // when
    OHLinkTraversalOperation *appsOp = [OHLinkTraversalOperation traverseRel:@"r:app" inResource:rootResource withClient:self.client traversalHandler:^NSArray *(OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        assertThat(targetResource, notNilValue());
        OHResource *application = targetResource;
        NSLog(@"==> application = %@", application);
        [applications addObject:application];
        return @[];
    } completion:^{
        [self signalAsyncTestCompleted];
    }];
        
    [[self.client operationQueue] addOperation:appsOp];
    assertThatBool([self waitForAsyncTestCompletion:self.timeout], is(equalToBool(YES)));
        
    // then
    assertThat(applications, hasCountOf(3));
}

- (void)testMultiLevelTraversal {
    // given
    NSString *rootObjectPath = @"apps";
    OHResource *rootResource = [self fetchRootResourceFromPath:rootObjectPath];
    NSMutableArray * __block applications = [NSMutableArray array];
    NSMutableArray * __block icons = [NSMutableArray array];
    
    // when
    OHLinkTraversalOperation *appsOp = [OHLinkTraversalOperation traverseRel:@"r:app" inResource:rootResource withClient:self.client traversalHandler:^NSArray *(OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        assertThat(targetResource, notNilValue());
        
        NSLog(@"==> application = %@", targetResource);
        
        [applications addObject:targetResource];
        
        OHLinkTraversalOperation *iconOp = [OHLinkTraversalOperation traverseRel:@"app:icon" inResource:targetResource withClient:self.client traversalHandler:^NSArray *(OHResource *targetResource, NSError *error) {
            assertThat(error, nilValue());
            assertThat(targetResource, notNilValue());
            
            NSLog(@"  ==> icon = %@", targetResource);
            
            [icons addObject:targetResource];
            
            return @[];
        } completion:^{
            NSLog(@"icon traversal completed");
        }];
        
        return @[ iconOp ];
    } completion:^{
        NSLog(@"app traversal completed");
        [self signalAsyncTestCompleted];
    }];
    
    [[self.client operationQueue] addOperation:appsOp];
    assertThatBool([self waitForAsyncTestCompletion:self.timeout], is(equalToBool(YES)));
    
    // then
    assertThat(applications, hasCountOf(3));
    assertThat(icons, hasCountOf(3));
}

- (void)testManyMultiLevelTraversals {
    for (int counter = 0; counter < 5; counter++) {
        [self testMultiLevelTraversal];
    }
}

@end
