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

- (void)testFollowLinkForPathwhenFinished
{
    // given
    NSString *resourcePath = @"/apps/";
    
    // when
    [client followLinkForPath:resourcePath whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
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
    OHResource __block *categoryResource = nil;
    
    // when
    NSString *resourcePath = @"/apps/";
    [client followLinkForPath:resourcePath whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
        if (!error) {
            [client followLinkForRel:@"r:category" inResource:targetResource whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
                assertThat(link, notNilValue());
                assertThat(targetResource, notNilValue());
                assertThat(error, nilValue());
                categoryResource = targetResource;
                self.done = YES;
            }];
        }
    }];
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
    self.done = NO;
    
    // then
    assertThat([[categoryResource linkForRel:@"self"] href], is(@"/category/1"));
}

- (void)testFollowLinks
{
    // given
    NSMutableArray __block *apps = [NSMutableArray array];
    
    // when
    [client followLinkForPath:@"/apps/" whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
        if (!error) {
            [client followLinksForRel:@"r:app" inResource:targetResource forEach:^(OHLink *link, OHResource *targetResource, NSError *error) {
                if (!error) {
                    [apps addObject:targetResource];
                }
            } whenFinished:^{
                self.done = YES;
            }];
        }
    }];
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
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
    [client followLinkForRel:@"addr:home" inResource:resource whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
        assertThat(link, notNilValue());
        assertThat(targetResource, notNilValue());
        assertThat(error, nilValue());
        homeAddress = [targetResource copy];
        self.done = YES;
    }];
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
    
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
    [client followLinkForPath:@"/apps/" whenFinished:^(OHLink *link, OHResource *targetResource, NSError *error) {
        if (!error) {
            targetResource.useEmbeddedResources = YES;
            [client followLinksForRel:@"r:app" inResource:targetResource forEach:^(OHLink *link, OHResource *targetResource, NSError *error) {
                if (!error) {
                    [apps addObject:targetResource];
                }
            } whenFinished:^{
                self.done = YES;
            }];
        }
    }];
    assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
    self.done = NO;
    
    // then
    assertThatUnsignedInteger([apps count], is(equalToUnsignedInteger(3)));
}

@end
