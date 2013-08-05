//
//  OHResource+PrivateMethods.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/5/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHResource.h"

@interface OHResource (PrivateMethods)
- (OHResource *)embeddedResourceForRel:(NSString *)rel;
- (NSArray *)embeddedResourcesForRel:(NSString *)rel;
@end
