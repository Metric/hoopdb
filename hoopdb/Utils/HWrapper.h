//
//  QueryWrapper.h
//  binDB
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../FMDB/FMResultSet.h"

@interface HWrapper : NSObject
+(NSMutableDictionary *) wrapJSON: (NSString *) json;
+(NSMutableDictionary *) wrapObject: (NSObject *) obj;
+(NSDictionary *) wrapDocumentDictionary: (NSDictionary *) dict;
+(NSString *) wrapDate: (NSDate *) date;
+(NSString *) wrapData: (NSData *) data;
+(NSArray *) wrapDocumentArray: (NSArray *) arr;
+(NSArray *) getSubObjects;
+(id) unwrapResults: (FMResultSet *) results collection: (Class) collection;
@end
