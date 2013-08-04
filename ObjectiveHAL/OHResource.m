//
//  OHResource.m
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import "OHResource.h"
#import "OHLink.h"
#import "CSURITemplate.h"

@interface OHResource ()
@property (nonatomic, strong) NSDictionary *links;
@property (nonatomic, strong) NSDictionary *curies;
@property (nonatomic, strong) NSDictionary *embedded;
@end

@implementation OHResource

- (id)initWithJSONData:(id)jsonData
{
    self = [super init];
    if (self) {
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = (NSDictionary *)jsonData;
            NSDictionary *linksData = [data objectForKey:@"_links"];
            NSDictionary *embeddedData = [data objectForKey:@"_embedded"];
            
            _curies = [OHResource curiesFromJSONData:[linksData objectForKey:@"curies"]];
            _links = [OHResource linksFromJSONData:linksData withCuries:_curies];
            _embedded = [OHResource embeddedFromJSONData:embeddedData withCuries:_curies];
            
        } else {
            // ERROR: Expecting an NSDictionary.
            self = nil;
        }
    }
    return self;
}

+ (NSDictionary *)embeddedFromJSONData:(id)jsonData withCuries:(NSDictionary *)curies
{
    NSMutableDictionary *embedded = [NSMutableDictionary dictionary];
    for (id embedKey in jsonData) {
        if ([embedKey isKindOfClass:[NSString class]]) {
            NSString *linkRelation = (NSString *)embedKey;
            NSString *expandedRelation = [OHResource expandRelationIfPossible:linkRelation withCuries:curies];
            id embeddedJson = [jsonData objectForKey:linkRelation];
            if ([embeddedJson isKindOfClass:[NSDictionary class]]) {
                [embedded setValue:embeddedJson forKey:expandedRelation];
            } else if ([embeddedJson isKindOfClass:[NSArray class]]) {
                NSMutableArray *embeddedArray = [NSMutableArray array];
                [embedded setValue:embeddedArray forKey:expandedRelation];
                for (id obj in embeddedJson) {
                    [embeddedArray addObject:obj];
                }
            } else {
                NSLog(@"WARNING: Type of link data not recognized");
            }
        } else {
            NSLog(@"WARNING: Link key not recognized");
        }
    }
    return embedded;
}

+ (NSDictionary *)curiesFromJSONData:(id)jsonData
{
    NSMutableDictionary *curies = [NSMutableDictionary dictionary];
    if ([jsonData isKindOfClass:[NSArray class]]) {
        for (id curieArrayElement in jsonData) {
            OHLink *curieLink = [[OHLink alloc] initWithJSONData:curieArrayElement rel:@"curies"];
            [curies setValue:curieLink forKey:[curieLink name]];
        }
    }
    return curies;
}

+ (NSDictionary *)linksFromJSONData:(id)jsonData withCuries:(NSDictionary *)curies
{
    NSMutableDictionary *links = [NSMutableDictionary dictionary];
    for (id linkKey in jsonData) {
        if ([linkKey isKindOfClass:[NSString class]]) {
            NSString *linkRelation = (NSString *)linkKey;
            if ([linkRelation isEqualToString:@"curies"] == NO) {
                NSString *expandedRelation = [OHResource expandRelationIfPossible:linkRelation withCuries:curies];
                id jsonLink = [jsonData objectForKey:linkRelation];
                if ([jsonLink isKindOfClass:[NSDictionary class]]) {
                    OHLink *link = [[OHLink alloc] initWithJSONData:jsonLink rel:expandedRelation];
                    [links setValue:link forKey:expandedRelation];
                } else if ([jsonLink isKindOfClass:[NSArray class]]) {
                    NSMutableArray *linkArray = [NSMutableArray array];
                    [links setValue:linkArray forKey:expandedRelation];
                    for (id linkArrayElement in jsonLink) {
                        OHLink *link = [[OHLink alloc] initWithJSONData:linkArrayElement rel:expandedRelation];
                        [linkArray addObject:link];
                    }
                } else {
                    NSLog(@"WARNING: Type of link data not recognized");
                }
            }
        } else {
            NSLog(@"WARNING: Link key not recognized");
        }
    }
    return links;
}

+ (NSString *)expandRelationIfPossible:(NSString *)rel withCuries:(NSDictionary *)curies
{
    NSURL *relURL = [NSURL URLWithString:rel];
    OHLink *curie = [curies objectForKey:[relURL scheme]];
    
    if (curie && [curie isTemplate]) {
        NSString *relValue = [relURL resourceSpecifier];
        CSURITemplate *template = [[CSURITemplate alloc] initWithURITemplate:[curie href]];
        rel = [template URIWithVariables:@{@"rel": relValue}];
    } else if (curie) {
        rel = [curie href];
    }
    
    return rel;
}

- (OHLink *)linkForRel:(NSString *)rel
{
    NSString *absoluteRel = [OHResource expandRelationIfPossible:rel withCuries:self.curies];
    id value = [self.links objectForKey:absoluteRel];
    if ([value isKindOfClass:[OHLink class]]) {
        return value;
    } else if ([value isKindOfClass:[NSArray class]]) {
        return [(NSArray *)value objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)linksForRel:(NSString *)rel
{
    NSString *absoluteRel = [OHResource expandRelationIfPossible:rel withCuries:self.curies];
    id value = [self.links objectForKey:absoluteRel];
    if ([value isKindOfClass:[OHLink class]]) {
        return @[value];
    } else if ([value isKindOfClass:[NSArray class]]) {
        return (NSArray *)value;
    }
    return nil;
}

- (id)embeddedJSONDataForLink:(OHLink *)link
{
    return nil;
}

@end
