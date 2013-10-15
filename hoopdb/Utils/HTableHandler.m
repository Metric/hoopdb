//
//  HTableHandler.m
//  hoopdb
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import "HTableHandler.h"
#import "../FMDB/FMDBConnector.h"
#import "../Reflection/MARTNSObject.h"
#import "../Reflection/RTProperty.h"
#import "../FMDB/FMDatabase.h"
#import "../FMDB/FMResultSet.h"
#import "../FMDB/FMDatabaseQueue.h"
#import "HWrapper.h"

@implementation HTableHandler
+(BOOL) create:(Class) collection {
        FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
        
    if(dba) {
        NSString *tableName = NSStringFromClass(collection);
        NSMutableString *query = [NSMutableString stringWithFormat:@"create table if not exists %@ (", tableName];
            
        BOOL __block success = NO;
        
        NSString *columns = [HTableHandler buildTableColumns:collection];
        
        if(columns && columns.length > 0) {
            
            [query appendFormat:@"%@)", columns];
            
            [dba inDatabase:^(FMDatabase *db) {
                NSString *testQuery = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'", tableName];
                
                FMResultSet *set = [db executeQuery:testQuery];
                
                if((set && ![set next]) || !set) {
                    success = [db executeUpdate:query];
                }
                
                [set close];
            }];
        }
        
        return success;
    }
    
    return NO;
}

+(BOOL) alter:(Class) collection {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSString *tableName = NSStringFromClass(collection);
        NSMutableString *query = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN ", tableName];
        
        BOOL __block success = NO;
        
        [dba inDatabase:^(FMDatabase *db) {
            NSArray *columns = [collection rt_properties];
            
            for(int i = 0; i < columns.count; i++) {
                RTProperty *column = [columns objectAtIndex:i];
                NSString *finalQuery = [query stringByAppendingString:[NSString stringWithFormat:@"%@ %@",column.name,[HTableHandler columnTypeForProperty:column]]];
                NSString *testQuery = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE 1", column.name, tableName];
                
                FMResultSet *set = [db executeQuery:testQuery];
                
                if((set && ![set next]) || !set) {
                    success = [db executeUpdate:finalQuery];
                }
                
                [set close];
            }
        }];
        
        return success;
    }

    return NO;
}

+(BOOL) insert:(HDocument *) doc {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSString *tableName = NSStringFromClass([doc class]);
        NSMutableString *query = [NSMutableString stringWithFormat:@"INSERT INTO %@ (_id,_v,", tableName];
        
        BOOL __block success = NO;
        
        [dba inDatabase:^(FMDatabase *db) {
            NSArray *properties = [[doc class] rt_properties];
            NSMutableArray *values = [NSMutableArray array];
            NSMutableString *insertValuesQuery = [NSMutableString stringWithFormat:@"('%@','%f',",doc._id,doc._v];
            
            for(int i = 0; i < properties.count; i++) {
                RTProperty * prop = [properties objectAtIndex:i];
                NSString *column = [prop name];
                [query appendFormat:@"%@,", column];
                [insertValuesQuery appendString:@"?,"];
                
                NSString * propClassName = [[[prop typeEncoding] stringByReplacingOccurrencesOfString:@"\"" withString:@""] substringFromIndex:1];
                Class propClass = NSClassFromString(propClassName);
                
                if(propClassName.length == 0) {
                    [values addObject:[doc valueForKey:column]];
                }
                else if(propClass == nil) {
                    [values addObject:[NSNull null]];
                }
                else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
                    HDocument *propDoc = [doc valueForKey:column];
                    [values addObject:[NSString stringWithFormat:@"obj::%@::%@", propClassName,  propDoc._id]];
                }
                else if(propClass == [NSData class] || [propClass isSubclassOfClass:[NSData class]]) {
                    NSData *data = [doc valueForKey:column];
                    [values addObject:[NSString stringWithFormat:@"data::%@", [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]]];
                }
                else if(propClass == [NSDate class] || [propClass isSubclassOfClass:[NSDate class]]) {
                    NSDate *date = [doc valueForKey:column];
                    [values addObject:[NSString stringWithFormat:@"date::%f", [date timeIntervalSince1970]]];
                }
                else if(propClass == [NSDictionary class] || [propClass isSubclassOfClass:[NSDictionary class]]) {
                    [values addObject:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:[doc valueForKey:column]] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
                }
                else if(propClass == [NSArray class] || [propClass isSubclassOfClass:[NSArray class]]) {
                    [values addObject:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:[doc valueForKey:column]] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
                }
                else {
                    [values addObject:[doc valueForKey:column]];
                }
            }
            
            NSString * finalValueInsert = [NSString stringWithFormat:@"%@)", [insertValuesQuery substringToIndex:insertValuesQuery.length - 1]];
            NSString *finalMainQuery = [NSString stringWithFormat:@"%@) ", [query substringToIndex:query.length - 1]];
            
            NSString *finalQuery = [NSString stringWithFormat:@"%@ VALUES %@", finalMainQuery, finalValueInsert];
            
            success = [db executeUpdate:finalQuery withArgumentsInArray:values];
        }];
        
        return success;
    }
    
    return NO;
}

+(BOOL) remove:(HDocument *) doc {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSString *tableName = NSStringFromClass([doc class]);
        
        BOOL __block success = NO;
        
        [dba inDatabase:^(FMDatabase *db) {
            NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE _id = ?", tableName];
            success = [db executeUpdate:query, doc._id];
        }];
        
        return success;
    }
    
    return NO;
}

+(BOOL) drop:(Class) collection {
    if(collection) {
        FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
        
        if(dba) {
            NSString *tableName = NSStringFromClass(collection);
            
            BOOL __block success = NO;
            
            [dba inDatabase:^(FMDatabase *db) {
                NSString *query  = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
                success = [db executeUpdate:query];
            }];
            
            return success;
        }
    }
    
    return NO;
}

+(BOOL) documentExists: (HDocument *) doc {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSString *tableName = NSStringFromClass([doc class]);
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE _id = ?", tableName];
        BOOL __block success = NO;
        
        [dba inDatabase:^(FMDatabase *db) {
            FMResultSet *results = [db executeQuery:selectQuery, doc._id];
            
            if(results) {
                success = YES;
            }
            
            [results close];
        }];
        
        return success;
    }
    
    return YES;
}

+(BOOL) update:(HDocument *) doc {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSString *tableName = NSStringFromClass([doc class]);
        NSMutableString *query = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", tableName];
        
        NSString *_id = doc._id;
        
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE _id = ?", tableName];
        
        BOOL __block success = NO;
        
        [dba inDatabase:^(FMDatabase *db) {
            BOOL selectSuccess = NO;
            
            FMResultSet *results = [db executeQuery:selectQuery, _id];
            
            if(results) {
                if([results next]) {
                    double _version = [results doubleForColumn:@"_v"];
                    double currentVersion = doc._v;
                    
                    if(currentVersion > _version) {
                        selectSuccess = YES;
                    }
                }
            }
            
            [results close];
            
            if(selectSuccess) {
                NSArray *properties = [[doc class] rt_properties];
                NSMutableArray *values = [NSMutableArray array];
                
                [query appendFormat:@"_v = ?, "];
                [values addObject:[NSNumber numberWithDouble:doc._v]];
                
                for(int i = 0; i < properties.count; i++) {
                    RTProperty * prop = [properties objectAtIndex:i];
                    NSString *column = [prop name];
                    
                    [query appendFormat:@"%@ = ?, ", column];
                
                    NSString * propClassName = [[[prop typeEncoding] stringByReplacingOccurrencesOfString:@"\"" withString:@""] substringFromIndex:1];
                    Class propClass = NSClassFromString(propClassName);
                    
                    if(propClassName.length == 0) {
                        [values addObject:[doc valueForKey:column]];
                    }
                    else if(propClass == nil) {
                        [values addObject:[NSNull null]];
                    }
                    else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
                        HDocument *propDoc = [doc valueForKey:column];
                        [values addObject:[NSString stringWithFormat:@"obj::%@::%@", propClassName,  propDoc._id]];
                    }
                    else if(propClass == [NSData class] || [propClass isSubclassOfClass:[NSData class]]) {
                        NSData *data = [doc valueForKey:column];
                        [values addObject:[NSString stringWithFormat:@"data::%@", [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]]];
                    }
                    else if(propClass == [NSDate class] || [propClass isSubclassOfClass:[NSDate class]]) {
                        NSDate *date = [doc valueForKey:column];
                        [values addObject:[NSString stringWithFormat:@"date::%f", [date timeIntervalSince1970]]];
                    }
                    else if(propClass == [NSDictionary class] || [propClass isSubclassOfClass:[NSDictionary class]]) {
                        [values addObject:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:[doc valueForKey:column]] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
                    }
                    else if(propClass == [NSArray class] || [propClass isSubclassOfClass:[NSArray class]]) {
                        [values addObject:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:[doc valueForKey:column]] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
                    }
                    else {
                        [values addObject:[doc valueForKey:column]];
                    }
                }
                
                NSString *semiQuery = [query substringToIndex:query.length - 2];
                NSString *finalQuery = [NSString stringWithFormat:@"%@ WHERE _id = '%@'", semiQuery, _id];
                
                success = [db executeUpdate:finalQuery withArgumentsInArray:values];
            }
        }];
        
        return success;
    }
    
    return NO;
}

+(NSArray *) all: (Class) collection {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
     NSMutableArray __block *items = [NSMutableArray array];
    
    if(dba) {
        NSString *tableName = NSStringFromClass(collection);
        
        [dba inDatabase:^(FMDatabase *db) {
            NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE 1", tableName];
            
            FMResultSet *results = [db executeQuery:selectQuery];
            
            if(results) {
                while([results next]) {
                    [items addObject:[HWrapper unwrapResults:results collection:collection]];
                }
            }
            
            [results close];
        }];
        
        NSArray *subObjects = [HWrapper getSubObjects];
        
        for(int i = 0; i < subObjects.count; i++) {
            HDocument *subObject = [subObjects objectAtIndex:i];
            [subObject load];
        }
    }

    return items;
}

+(HDocument *) getDocument: (HDocument *) doc {
    FMDatabaseQueue *dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSString *tableName = NSStringFromClass([doc class]);
        
        HDocument __block *result = nil;
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE _id = ?", tableName];
        
        [dba inDatabase:^(FMDatabase *db) {
            FMResultSet *results = [db executeQuery:selectQuery withArgumentsInArray:[NSArray arrayWithObject:doc._id]];
            
            if(results) {
                if([results next]) {
                    result = [HWrapper unwrapResults:results collection:[doc class]];
                }
            }
            
            [results close];
        }];
        
        NSArray *subObjects = [HWrapper getSubObjects];
        
        for(int i = 0; i < subObjects.count; i++) {
            HDocument *subObject = [subObjects objectAtIndex:i];
            [subObject load];
        }
        
        return result;
    }
    
    return nil;
}

+(NSArray *) getColumns: (NSDictionary *) dict {
    NSArray *columns = [dict keysSortedByValueUsingComparator:^NSComparisonResult(NSString *item1, NSString *item2) {
        return [item1 compare:item2];
    }];
    
    return columns;
}

+(NSString *) buildTableColumns: (Class) collection {
    NSMutableString *columnString = [NSMutableString stringWithString:@""];
    
    NSArray * columns = [collection rt_properties];
    
    [columnString appendString:@"_id TEXT PRIMARY KEY UNIQUE, "];
    [columnString appendString:@"_v REAL, "];
    
    for(int i = 0; i < columns.count; i++) {
        RTProperty *column = [columns objectAtIndex:i];
        
        [columnString appendFormat:@"%@ %@, ", column.name, [HTableHandler columnTypeForProperty:column]];
    }
    
    if(columnString.length > 0)
        return [columnString substringToIndex:columnString.length - 2];
    else
        return nil;
}

+(NSString *) columnTypeForProperty: (RTProperty *) prop {
    NSString *propClassName = [[prop.typeEncoding stringByReplacingOccurrencesOfString:@"\"" withString:@""] substringFromIndex:1];
    Class propClass = NSClassFromString(propClassName);
    
    if(propClass) {
        if(propClass == [NSNumber class] || [propClass isSubclassOfClass:[NSNumber class]]) {
            return @"REAL";
        }
        else {
            return @"TEXT";
        }
    }
    else if(propClassName.length == 0) {
        return @"REAL";
    }
    
    return @"TEXT";
}

+(NSString *) columnType: (id) obj {
    if([obj isKindOfClass:[NSNumber class]]) {
        return @"REAL";
    }
    else {
        return @"TEXT";
    }
}
@end