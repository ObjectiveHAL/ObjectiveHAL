//
//  OHResourceTests.m
//  ObjectiveHAL
//
//  Created by: Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//
    // Class under test
#import "OHResource.h"

    // Collaborators
#import "OHResource+PrivateMethods.h"
#import "OHLink.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>
#import "NSData+TestInfected.h"

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>


@interface OHResourceTests : SenTestCase
@property (readwrite, strong, nonatomic) NSBundle *testBundle;
@end

@implementation OHResourceTests

- (void)setUp
{
    [super setUp];
    self.testBundle = [NSBundle bundleForClass:[self class]];
}

- (void)testSimpleResource
{
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"simple-resource" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id simpleResource = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());

    // when
    OHResource *resource = [[OHResource alloc] initWithJSONData:simpleResource];
    OHLink *selfLink = [resource linkForRel:@"self"];
    
    // then
    assertThat(resource, notNilValue());
    assertThat(selfLink, notNilValue());
    assertThat([selfLink href], is(@"https://example.com/api/customer/123456"));
}

- (void)testResolveCuries
{
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"curies-resource" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id curiesResource = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    
    // when
    OHResource *resource = [[OHResource alloc] initWithJSONData:curiesResource];
    OHLink *curiedParentLink = [resource linkForRel:@"ns:parent"];
    OHLink *absoluteParentLink = [resource linkForRel:@"https://example.com/apidocs/ns/parent"];
    
    // then
    assertThat(resource, notNilValue());
    assertThat([curiedParentLink href], is(@"https://example.com/api/customer/1234"));
    assertThat([absoluteParentLink href], is(@"https://example.com/api/customer/1234"));
}

- (void)testEmbeds
{
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"resource-with-embeds" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id embedsResource = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    
    // when
    OHResource *resource = [[OHResource alloc] initWithJSONData:embedsResource];
    NSArray *appLinks = [resource linksForRel:@"r:app"];
    OHLink *embeddedResourceLink = [appLinks objectAtIndex:0];
    OHResource *embeddedResource = [resource embeddedResourceForRel:[embeddedResourceLink rel]];
    
    // then
    assertThat(embeddedResource, notNilValue());
    assertThat([embeddedResource linkForRel:@"self"], is(embeddedResourceLink));
}

- (void)testEmbeddedResourceCurieHandling
{
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"apps" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id appsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    OHResource *appsResource = [OHResource resourceWithJSONData:appsJSON];
    
    // when
    NSMutableArray *icons = [NSMutableArray array];
    NSArray *apps = [appsResource embeddedResourcesForRel:@"r:app"];
    for (OHResource *app in apps) {
        OHLink *icon = [app linkForRel:@"app:icon"];
        [icons addObject:icon];
    }
    
    // then
    assertThatInteger([icons count], equalToInteger(2));
}

- (void)testAllLinksForRel {
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"apps" fromBundle:self.self.testBundle];
    assertThat(data, notNilValue());
    id appsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    OHResource *appsResource = [OHResource resourceWithJSONData:appsJSON];
    
    // when
    NSArray *allLinks = [appsResource linksForRel:@"r:app"];
    
    // then
    assertThat(allLinks, hasCountOf(3));
}

- (void)testEmbeddedLinksForRel {
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"apps" fromBundle:self.self.testBundle];
    assertThat(data, notNilValue());
    id appsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    OHResource *appsResource = [OHResource resourceWithJSONData:appsJSON];
    
    // when
    NSArray *embeddedLinks = [appsResource embeddedLinksForRel:@"r:app"];
    
    // then
    assertThat(embeddedLinks, hasCountOf(2));
}

- (void)testExternalLinksForRel {
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"apps" fromBundle:self.self.testBundle];
    assertThat(data, notNilValue());
    id appsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assertThat(error, nilValue());
    OHResource *appsResource = [OHResource resourceWithJSONData:appsJSON];
    
    // when
    NSArray *externalLinks = [appsResource externalLinksForRel:@"r:app"];
    
    // then
    assertThat(externalLinks, hasCountOf(1));
}

- (void)testFetchingResourceJSON
{
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"contact" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id contact = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    OHResource *resource = [[OHResource alloc] initWithJSONData:contact];
    assertThat(resource, notNilValue());

    // when
    id json = [resource resourceJSON];
    
    // then
    assertThatBool([json isKindOfClass:[NSDictionary class]], is(equalToBool(YES)));
}

@end
