//
//  HEquals.h
//  hoopdb
//
//  Created by Aaron Klick on 10/11/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWhere.h"


@interface HEquals : NSObject
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) HWhere *associatedWhere;
@end
