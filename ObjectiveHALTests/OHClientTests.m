//
//  ObjectiveHAL - OHClientTests.m
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//
//  Created by: Bennett Smith
//

    // Class under test
#import "OHClient.h"

    // Collaborators
#import "OHLink.h"
#import "OHResource.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>

@interface OHClientTests : SenTestCase
@property (atomic, assign) BOOL done;
@end

@implementation OHClientTests
{
    // test fixture ivars go here
    NSURL *baseURL;
    OHClient *client;
}

- (void)setUp
{
    [super setUp];
    // TODO: Replace with a proper test web service.
    baseURL = [NSURL URLWithString:@"http://localhost:7100"];
    client = [OHClient clientWithBaseURL:baseURL];
    self.done = NO;
}

- (void)tearDown
{
    baseURL = nil;
    client = nil;
    [super tearDown];
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.done);
    
    return self.done;
}

- (void)testGetOHResource
{
    // given
    NSString *resourcePath = @"/apps/";
    
    // when
    [client getOHResource:resourcePath whenFinished:^(OHResource *targetResource, NSError *error) {
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        self.done = YES;
    }];
    
    // then
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
}

- (void)testFollowLink
{
    // given
    NSString *resourcePath = @"/apps/";
    OHResource __block *resource = nil;
    [client getOHResource:resourcePath whenFinished:^(OHResource *targetResource, NSError *error) {
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        resource = targetResource;
        self.done = YES;
    }];
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
    self.done = NO;
    
    // when
    OHLink *link = [resource linkForRel:@"r:category"];
    [client followLink:link whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
        assertThat(link, notNilValue());
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        assertThat([[targetResource linkForRel:@"self"] href], is(@"/category/1"));
        self.done = YES;
    }];
    
    // then
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
}

- (void)testFollowLinks
{
    // given
    NSString *resourcePath = @"/apps/";
    OHResource __block *resource = nil;
    [client getOHResource:resourcePath whenFinished:^(OHResource *targetResource, NSError *error) {
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        resource = targetResource;
        self.done = YES;
    }];
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
    self.done = NO;
    
    // when
    NSMutableArray __block *apps = [NSMutableArray array];
    [client followLinksInResource:resource forRel:@"r:app" forEach:^(OHLink *link, OHResource *targetResource, NSError *error) {
        assertThat(link, notNilValue());
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        [apps addObject:targetResource];
        NSLog(@"%@", [targetResource debugDescription]);
    } whenFinished:^{
        assertThatUnsignedInteger([apps count], is(equalToUnsignedInteger(3)));
    }];
    
    // then
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
}

@end
