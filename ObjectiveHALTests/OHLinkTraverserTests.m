//
//  ObjectiveHAL - OHLinkTraverserTests.m
//  Copyright 2013 ObjectiveHAL. All rights reserved.
//
//  Created by: Bennett Smith
//

    // Class under test
#import "OHLinkTraverser.h"

    // Collaborators
#import "OHLink.h"
#import "OHResource.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

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
@property (readwrite, strong, nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation OHLinkTraverserTests

- (void)setUp {
    self.baseURL = [NSURL URLWithString:@"http://localhost:7100"];
    self.client = [AFHTTPClient clientWithBaseURL:self.baseURL];
    self.timeout = 30;
    self.semaphore = dispatch_semaphore_create(0);
}

- (void)tearDown {
    // dispatch_release(self.semaphore);
}

- (void)signalBlockCompletion {
    dispatch_semaphore_signal(self.semaphore);
}

- (BOOL)waitForBlockCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
    BOOL successfulCompletion = YES;
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        if([timeoutDate timeIntervalSinceNow] < 0.0) {
            successfulCompletion = NO;
            [self signalBlockCompletion];
            break;
        }
    }
    return successfulCompletion;
}

- (void)testTraversePathWithClientHandler {
    // given
    NSString *rootObjectPath = @"apps";
    
    // when
    OHResource * __block rootResource = nil;
    [OHLinkTraverser traversePath:rootObjectPath withClient:self.client traversalHandler:^(OHLinkTraverser *traverser, OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        rootResource = targetResource;
        [self signalBlockCompletion];
    }];
    assertThatBool([self waitForBlockCompletion:self.timeout], is(equalToBool(YES)));
    
    // then
    assertThat(rootResource, notNilValue());
    assertThat(rootResource.links, hasCountOf(3));
    assertThat(rootResource.embedded, hasCountOf(2));
    assertThat(rootResource.curies, hasCountOf(2));
}

- (void)testBeginTraversalForRel {
    // given
    NSString *rootObjectPath = @"apps";
    
    OHResource * __block rootResource = nil;
    [OHLinkTraverser traversePath:rootObjectPath withClient:self.client traversalHandler:^(OHLinkTraverser *traverser, OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        rootResource = targetResource;
        [self signalBlockCompletion];
    }];
    assertThatBool([self waitForBlockCompletion:self.timeout], is(equalToBool(YES)));
    
    // when
    NSMutableArray * __block applications = [NSMutableArray array];
    [OHLinkTraverser beginTraversalForRel:@"r:app" inResource:rootResource withClient:self.client traversalHandler:^(OHLinkTraverser *traverser, OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        assertThat(targetResource, notNilValue());
        [applications addObject:targetResource];
        NSLog(@"added application %@", targetResource);
    } completion:^(OHLinkTraverser *traverser) {
        NSLog(@"completed traversal!");
        [self signalBlockCompletion];
    }];
    assertThatBool([self waitForBlockCompletion:self.timeout], is(equalToBool(YES)));
    
    // then
    assertThat(applications, hasCountOf(3));
}
@end
