//
//  FMDBConnector.h
//  binDB
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface FMDBConnector : NSObject
+(FMDatabaseQueue *) sharedDatabase;
+(void) setSharedDatabase: (FMDatabaseQueue *) database;
/*+(FMDatabase *) database;*/
+(FMDatabaseQueue *) open: (NSString *) name;
+(void) close;
@end
