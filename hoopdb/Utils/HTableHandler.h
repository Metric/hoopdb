//
//  HTableHandler.h
//  hoopdb
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../HDocument.h"

@interface HTableHandler : NSObject
+(BOOL) create: (Class) collection;
+(BOOL) alter:(Class) collection;
+(BOOL) remove:(HDocument *) doc;
+(BOOL) drop:(Class) collection;
+(BOOL) documentExists: (HDocument *) doc;
+(BOOL) update:(HDocument *) doc;
+(BOOL) insert:(HDocument *) doc;
+(NSArray *) all: (Class) doc;
+(HDocument *) getDocument: (HDocument *) doc;
+(NSArray *) getColumns: (NSDictionary *) dict;
@end
