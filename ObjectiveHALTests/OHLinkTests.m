//
//  OHLinkTests.m
//  ObjectiveHAL
//
//  Created by: Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//

    // Class under test
#import "OHLink.h"

    // Collaborators

    // Test support
#import <SenTestingKit/SenTestingKit.h>
#import "NSData+TestInfected.h"

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>


@interface OHLinkTests : SenTestCase
@property (readwrite, strong, nonatomic) NSBundle *testBundle;
@end

@implementation OHLinkTests

- (void)setUp {
    [super setUp];
    self.testBundle = [NSBundle bundleForClass:[self class]];
}

- (void)testSimpleLink {
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"simple-link" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id simpleLink = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // when
    OHLink *link = [[OHLink alloc] initWithRel:nil jsonData:simpleLink];

    // then
    assertThat(link, notNilValue());
    assertThat([link href], is(@"https://example.com/api/customer/123456?users"));
}

- (void)testCompleteLink {
    // given
    NSError *error = nil;
    NSData *data = [NSData fetchTestFixtureByName:@"complete-link" fromBundle:self.testBundle];
    assertThat(data, notNilValue());
    id completeLink = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // when
    OHLink *link = [[OHLink alloc] initWithRel:nil jsonData:completeLink];
    
    // then
    assertThat(link, notNilValue());
    assertThat([link href], is(@"https://example.com/api/customer/1234"));
    assertThat([link name], is(@"bob"));
    assertThat([link title], is(@"The Parent"));
    assertThat([link hreflang], is(@"en"));
    assertThatBool([link isTemplate], equalToBool(FALSE));
}

@end
