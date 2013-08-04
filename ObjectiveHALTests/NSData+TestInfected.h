//
//  NSData+TestInfected.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (TestInfected)

+ (NSData *)fetchTestFixtureByName:(NSString *)fixtureName fromBundle:(NSBundle *)bundle;

@end
