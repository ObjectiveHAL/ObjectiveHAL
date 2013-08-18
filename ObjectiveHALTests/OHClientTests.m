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
#import "NSData+TestInfected.h"

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>

@interface OHClientTests : SenTestCase
@property (nonatomic, assign) BOOL done;
@end

@implementation OHClientTests
{
    // test fixture ivars go here
    NSURL *baseURL;
    OHClient *client;
    NSTimeInterval timeout;
}

- (void)setUp
{
    [super setUp];
    // TODO: Replace with a proper test web service.
    timeout = 30.0;
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

// assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    
    NSTimeInterval partialTimeoutSecs = timeoutSecs / 30;
    
    NSDate *partialTimeoutDate = [NSDate dateWithTimeIntervalSinceNow:partialTimeoutSecs];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:partialTimeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.done);
    
    return self.done;
}

- (void)testFollowLinkForPathWhenFinished
{
    // given
    NSString *resourcePath = @"/apps/";
    
    // when
    [client followLinkForPath:resourcePath whenFinished:^(OHResource *targetResource, NSError *error) {
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        self.done = YES;
    }];
    
    // then
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
}

- (void)testFollowLink
{
    // given
    OHResource __block *categoryResource = nil;
    
    // when
    NSString *resourcePath = @"/apps/";
    [client followLinkForPath:resourcePath whenFinished:^(OHResource *targetResource, NSError *error) {
        assertThat(error, nilValue());
        if (!error) {
            [client followLinkForRel:@"r:category" inResource:targetResource whenFinished:^(OHResource *targetResource, NSError *error) {
                assertThat(targetResource, notNilValue());
                assertThat(error, nilValue());
                categoryResource = targetResource;
                self.done = YES;
            }];
        }
    }];
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    self.done = NO;
    
    // then
    assertThat([[categoryResource linkForRel:@"self"] href], is(@"/category/1"));
}

- (void)testFollowLinks
{
    // given
    NSMutableArray __block *apps = [NSMutableArray array];
    
    // when
    [client followLinkForPath:@"/apps/" whenFinished:^(OHResource *targetResource, NSError *error) {
        if (!error) {
            NSLog(@"*** RECEIVED APPS RESOURCE ***");
            [client followLinksForRel:@"r:app" inResource:targetResource forEach:^(OHResource *targetResource, NSError *error) {
                if (!error && targetResource) {
                    NSLog(@"*** ADDING APP RESOURCE ***");
                    [apps addObject:targetResource];
                }
            } whenFinished:^{
                NSLog(@"*** FINISHED ***");
                self.done = YES;
            }];
        }
    }];
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    self.done = NO;
    
    // then
    assertThatUnsignedInteger([apps count], is(equalToUnsignedInteger(3)));
}

- (void)testFollowLinkToRelForEmbeddedResource
{
    // given
    OHResource __block *homeAddress = nil;
    OHResource *resource = [self loadResourceWithName:@"contact"];
    resource.useEmbeddedResources = YES;
    
    // when
    [client followLinkForRel:@"addr:home" inResource:resource whenFinished:^(OHResource *targetResource, NSError *error) {
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        homeAddress = [targetResource copy];
        self.done = YES;
    }];
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // then
    assertThat([[homeAddress linkForRel:@"self"] href], is(@"http://tempuri.org/address/827"));
}

- (OHResource *)loadResourceWithName:(NSString *)resourceName
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:resourceName fromBundle:testBundle];
    assertThat(data, notNilValue());
    id resourceJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    OHResource *resource = [OHResource resourceWithJSONData:resourceJSON];
    assertThat(resource, notNilValue());
    return resource;
}

- (void)testFollowLinksToRelForSomeEmbeddedResources
{
    // given
    NSMutableArray __block *apps = [NSMutableArray array];
    
    // when
    [client followLinkForPath:@"/apps/" whenFinished:^(OHResource *targetResource, NSError *error) {
        if (!error) {
            targetResource.useEmbeddedResources = YES;
            [client followLinksForRel:@"r:app" inResource:targetResource forEach:^(OHResource *targetResource, NSError *error) {
                if (!error) {
                    [apps addObject:targetResource];
                }
            } whenFinished:^{
                self.done = YES;
            }];
        }
    }];
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    self.done = NO;
    
    // then
    assertThatUnsignedInteger([apps count], is(equalToUnsignedInteger(3)));
}

@end
