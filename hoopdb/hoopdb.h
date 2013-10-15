//
//  hoopdb.h
//  hoopdb
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB/FMDBConnector.h"
#import "HDocument.h"
#import "Queries/HoopQuery.h"

@interface hoopdb : NSObject
+(BOOL) open: (NSString *) database;
+(HoopQuery *) registerDocumentModel: (Class) model;
+(void) close;
@end
