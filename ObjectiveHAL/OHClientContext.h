//
//  OHClientContext.h
//  ObjectiveHAL
//
//  Created by Bennett Smith on 8/19/13.
//  Copyright (c) 2013 ObjectiveHAL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OHClient.h"

@protocol OHClientContext <NSObject>
@optional
- enqueueNextOperation;
@end
