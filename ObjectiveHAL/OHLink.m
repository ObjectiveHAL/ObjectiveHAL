//
//  OHLink.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
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

- (id)initWithRel:(NSString *)rel href:(NSString *)href
{
    self = [super init];
    if (self) {
        _rel = [rel copy];
        _href = [href copy];
    }
    return self;
}

- (id)initWithCopyOfLink:(OHLink *)link
{
    self = [super init];
    if (self) {
        _rel = link.rel;
        _href = link.href;
        _name = link.name;
        _title = link.title;
        _hreflang = link.hreflang;
        _templated = link.templated;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.href isEqualToString:[(OHLink *)object href]];
    } else {
        return NO;
    }
}

- (NSUInteger)hash
{
    return [self.href hash];
}

- (NSString *)debugDescription
{
    NSString *dd = [NSString stringWithFormat:@"<%@: %p>{ href='%@' }", NSStringFromClass([self class]), self, self.href];
    return dd;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] initWithCopyOfLink:self];
    return copy;
}

@end
