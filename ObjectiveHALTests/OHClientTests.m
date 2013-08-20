//
//  ObjectiveHAL - OHClientTests.m
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//
//  Created by: Bennett Smith
//

    // Class under test
#import "OHClient.h"

    // Collaborators
#import "OHClientContext.h"
#import "OHLink.h"
#import "OHResource.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>
#import "NSData+TestInfected.h"

#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_WARN; // LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>

@interface OHClientTests : SenTestCase <OHClientContext>
@property (nonatomic, assign) BOOL done;
@end

@implementation OHClientTests
{
    // test fixture ivars go here
    NSURL *baseURL;
    OHClient *client;
    NSTimeInterval timeout;
}

+ (void)setUp
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogInfo(@"*** BEGINNING A TEST RUN ***");
}

+ (void)tearDown
{
    DDLogInfo(@"*** ENDING A TEST RUN ***");
}

- (void)setUp
{
    [super setUp];
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
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.done);
    
    return self.done;
}

- (void)testFollowLink
{
    // given
    OHResource * __block apps = nil;
    
    // when
    [client traverseLinkForPath:@"apps" traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        apps = targetResource;
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // then
    assertThat(apps, notNilValue());
}

- (void)testFollowLinkFromAppsToCategory
{
    // given
    OHResource * __block apps = nil;
    self.done = NO;
    
    [client traverseLinkForPath:@"apps" traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        apps = targetResource;
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];
    
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // when
    OHResource * __block category = nil;
    self.done = NO;

    [client traverseLinkForRel:@"r:category" inResource:apps traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING CATEGORY TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        category = targetResource;
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING CATEGORY COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];

    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // then
    assertThat([[category linkForRel:@"self"] href], is(@"/category/1"));
}

- (void)testFollowLinks
{
    // given
    OHResource * __block apps = nil;
    self.done = NO;
    
    [client traverseLinkForPath:@"apps" traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        apps = targetResource;
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];
    
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // when
    NSMutableArray * __block appArray = [NSMutableArray array];
    self.done = NO;
    
    [client traverseLinksForRel:@"r:app" inResource:apps traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING APP TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        [appArray addObject:targetResource];
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING APP COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];

    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // then
    assertThat(appArray, hasCountOf(3));
}

- (void)testFollowLinkToRelForEmbeddedResource
{
    // given
    //  .. a contact resource with embedded addr:home resource
    OHResource *contact = [self loadResourceWithName:@"contact"];
    
    // when
    [contact setUseEmbeddedResources:YES];
    OHResource * __block home = nil;
    
    self.done = NO;
    [client traverseLinkForRel:@"addr:home" inResource:contact traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        home = targetResource;
    } completionHandler:^(id traversalContext) {
        self.done = YES;
    }];
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // then
    assertThat([[home linkForRel:@"self"] href], is(@"http://tempuri.org/address/827"));
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
    OHResource * __block apps = nil;
    self.done = NO;
    
    [client traverseLinkForPath:@"apps" traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        apps = targetResource;
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING APPS COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];
    
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // when
    NSMutableArray * __block appArray = [NSMutableArray array];
    self.done = NO;
    
    [apps setUseEmbeddedResources:YES];
    [client traverseLinksForRel:@"r:app" inResource:apps traversalContext:self traversalHandler:^(OHResource *targetResource, NSError *error, id traversalContext) {
        DDLogInfo(@"*** ENTERING APP TRAVERSAL HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        [appArray addObject:targetResource];
    } completionHandler:^(id traversalContext) {
        DDLogInfo(@"*** ENTERING APP COMPLETION HANDLER ***");
        DDLogInfo(@"    traversalContext = '%@'", traversalContext);
        self.done = YES;
    }];
    
    assertThatBool([self waitForCompletion:timeout], is(equalToBool(YES)));
    
    // then
    assertThat(appArray, hasCountOf(3));
}

@end
