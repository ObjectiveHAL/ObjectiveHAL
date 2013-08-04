//
//  NSData+TestInfected.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "NSData+TestInfected.h"

@implementation NSData (TestInfected)

+ (NSData *)fetchTestFixtureByName:(NSString *)fixtureName fromBundle:(NSBundle *)bundle
{
    NSString *fixturePath = [bundle pathForResource:fixtureName ofType:@"json"];
    NSData *fixtureData = [NSData dataWithContentsOfFile:fixturePath];
    return fixtureData;
}


@end
