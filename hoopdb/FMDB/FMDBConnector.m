//
//  FMDBConnector.m
//  binDB
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import "FMDBConnector.h"
static FMDatabaseQueue *db;
static NSString *dbPath;
@implementation FMDBConnector
+(FMDatabaseQueue *) sharedDatabase {
    return db;
}
+(void) setSharedDatabase: (FMDatabaseQueue *) database {
    db = database;
}
+(FMDatabaseQueue *) open:(NSString *)name {
    NSString *documentDirectory = [FMDBConnector applicationDocumentsDirectory];
    
    if(documentDirectory) {
        NSString *path = [documentDirectory stringByAppendingPathComponent:name];
        
        FMDatabaseQueue *datab = [FMDatabaseQueue databaseQueueWithPath:path];
        
        if(datab) {
            [FMDBConnector setSharedDatabase:datab];
            dbPath = path;
            return datab;
        }
        else {
            return nil;
        }
    }
    
    return nil;
}

/*+(FMDatabase *) database {
    return [[FMDatabase alloc] initWithPath:dbPath];
}*/

+(void) close {
    [db close];
    db = nil;
}

+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
@end
