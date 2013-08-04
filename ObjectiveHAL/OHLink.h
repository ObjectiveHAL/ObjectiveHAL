//
//  OHLink.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 7/30/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OHLink : NSObject

// Required Properties
@property (strong, nonatomic, readonly) NSString *rel;
@property (strong, nonatomic, readonly) NSString *href;

// Optional Properties
@property (assign, nonatomic, readonly, getter=isTemplate) BOOL templated;
@property (strong, nonatomic, readonly) NSString *type;
@property (strong, nonatomic, readonly) NSString *deprecation;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *profile;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *hreflang;

- (id)initWithJSONData:(id)jsonData rel:(NSString *)rel;

@end
