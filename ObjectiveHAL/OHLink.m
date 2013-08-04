//
//  OHLink.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHLink.h"

@implementation OHLink

- (id)initWithJSONData:(id)jsonData rel:(NSString *)rel
{
    self = [super init];
    if (self) {
        _rel = [rel copy];
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = (NSDictionary *)jsonData;
            _href = [[data objectForKey:@"href"] copy];
            _name = [[data objectForKey:@"name"] copy];
            _title = [[data objectForKey:@"title"] copy];
            _hreflang = [[data objectForKey:@"hreflang"] copy];
            _templated = [(NSNumber *)[data objectForKey:@"templated"] boolValue];
        } else {
            // ERROR: Expecting an NSDictionary.
            self = nil;
        }
    }
    return self;
}

@end
