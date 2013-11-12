//
//  HoopQuery.m
//  hoopdb
//
//  Created by Aaron Klick on 10/7/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import "HoopQuery.h"
#import "HWhere.h"
#import "HEquals.h"
#import "../Utils/HTableHandler.h"
#import "HSort.h"
#import "../FMDB/FMDBConnector.h"
#import "../Utils/HWrapper.h"

@implementation HoopQuery
-(id) init {
    self = [super init];
    if(self) {
        self.skipCount = 0;
        self.takeCount = INT32_MAX;
        self.queries = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) reset {
    self.skipCount = 0;
    self.takeCount = INT32_MAX;
    self.queries = [NSMutableDictionary dictionary];
}

+(id) withCollection: (Class) dc {
    HoopQuery *query = [[HoopQuery alloc] init];

    [query setModel:dc];
    
    return query;
}

-(void) setModel: (Class) md {
    self.documentModel = md;
}

-(HoopQuery *) where: (NSString *) field {
    HWhere *whr = [[HWhere alloc] init];
    whr.field = field;
    whr.andOr = @"AND";
    
    if([self.queries objectForKey:@"where"]) {
        NSMutableArray *wheres = [self.queries objectForKey:@"where"];
        [wheres addObject:whr];
    }
    else {
        NSMutableArray *wheres = [NSMutableArray array];
        [wheres addObject:whr];
        [self.queries setObject:wheres forKey:@"where"];
    }
    
    return self;
}

-(HoopQuery *) equals: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }
    
    eq.type = @"=";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) whereOr: (NSString *) field {
    HWhere *whr = [[HWhere alloc] init];
    whr.field = field;
    whr.andOr = @"OR";
    
    if([self.queries objectForKey:@"where"]) {
        NSMutableArray *wheres = [self.queries objectForKey:@"where"];
        [wheres addObject:whr];
    }
    else {
        NSMutableArray *wheres = [NSMutableArray array];
        [wheres addObject:whr];
        [self.queries setObject:wheres forKey:@"where"];
    }
    
    return self;
}

-(HoopQuery *) lte: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }
    
    eq.type = @"<=";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) gte: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }
    
    eq.type = @">=";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) gt: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }
    
    eq.type = @">";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) lt: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }
    
    eq.type = @"<";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) like: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [NSString stringWithFormat:@"%%%@%%", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [NSString stringWithFormat:@"%%%@%%", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"%%data::%@%%", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [NSString stringWithFormat:@"%%%@%%", [HWrapper wrapDate:data]];
    }
    else {
        eq.value = [NSString stringWithFormat:@"%%%@%%", data];
    }
    
    eq.type = @"LIKE";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) notEquals: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentArray:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }
    
    eq.type = @"!=";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(HoopQuery *) inArray: (id) data {
    HEquals *eq = [[HEquals alloc] init];
    if([data isKindOfClass:[NSDictionary class]]) {
        eq.value = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[HWrapper wrapDocumentDictionary:data] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]]) {
        eq.value = [HWrapper wrapDocumentArray:data];
    }
    else if([data isKindOfClass:[NSData class]]) {
        eq.value = [NSString stringWithFormat:@"data::%@", [HWrapper wrapData:data]];
    }
    else if([data isKindOfClass:[NSDate class]]) {
        eq.value = [HWrapper wrapDate:data];
    }
    else {
        eq.value = data;
    }

    eq.type = @"in";
    
    if([self.queries objectForKey:@"equals"]) {
        NSMutableArray * equals = [self.queries objectForKey:@"equals"];
        
        [equals addObject:eq];
    }
    else {
        NSMutableArray * equals = [NSMutableArray array];
        
        [equals addObject:eq];
        
        [self.queries setObject:equals forKey:@"equals"];
    }
    
    return self;
}

-(int) count: (id) json {
    FMDatabaseQueue * dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        if(json) {
            NSDictionary *wrapped = nil;
            
            if([json isKindOfClass:[NSString class]]) {
                wrapped = [HWrapper wrapJSON:json];
            }
            else if([json isKindOfClass:[NSDictionary class]]) {
                wrapped = [HWrapper wrapDocumentDictionary:json];
            }
            
            if(wrapped) {
                NSArray * columns = [HTableHandler getColumns:wrapped];
                NSString *tableName = NSStringFromClass(self.documentModel);
                
                NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT COUNT(*) as count FROM %@", tableName];
                
                NSString * whereQuery = [self buildWhereQueryFromJSON:wrapped];
                
                if(whereQuery) {
                    NSMutableArray *values = [NSMutableArray array];
                    
                    for(int i = 0; i < columns.count; i++) {
                        [values addObject:[wrapped objectForKey:[columns objectAtIndex:i]]];
                    }
                    
                    int __block count = 0;
                    
                    NSString * finalQuery = [NSString stringWithFormat:@"%@ %@",query, whereQuery];
                    
                    [dba inDatabase:^(FMDatabase *db) {
                        FMResultSet * results = [db executeQuery:finalQuery withArgumentsInArray:values];
                        
                        if([results next]) {
                            count = [results intForColumn:@"count"];
                        }
                        
                        [results close];
                    }];
                    
                    [self reset];
                    
                    return count;
                }
            }
        }
        else {
            NSString *whereQuery = [self buildWhereQuery];
            
            if(whereQuery != nil) {
                NSMutableArray *values = [NSMutableArray array];
                NSArray *equals = [self.queries objectForKey:@"equals"];
                
                for(int i = 0; i < equals.count; i++) {
                    HEquals *equal = [equals objectAtIndex:i];
                    
                    if([equal.type isEqualToString:@"in"] && ![equal.value isKindOfClass:[NSArray class]]) {
                        [values addObject:[NSString stringWithFormat:@"%%%@%%", equal.value]];
                    }
                    else if(![equal.type isEqualToString:@"in"]) {
                        [values addObject:equal.value];
                    }
                }
                
                NSString *tableName = NSStringFromClass(self.documentModel);
                
                NSString * query = [NSMutableString stringWithFormat:@"SELECT COUNT(*) as count FROM %@", tableName];
                NSString *finalQuery = [NSString stringWithFormat:@"%@ %@", query, whereQuery];
                
                int __block count = 0;
                
                [dba inDatabase:^(FMDatabase *db) {
                    FMResultSet * results = [db executeQuery:finalQuery withArgumentsInArray:values];
                    
                    if([results next]) {
                        count = [results intForColumn:@"count"];
                    }
                    
                    [results close];
                }];
                
                [self reset];
                
                return count;
            }
        }
    }
    
    [self reset];
    
    return 0;
}

-(NSArray *) find: (id) json {
    NSMutableArray __block * arr = [NSMutableArray array];
    FMDatabaseQueue * dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        if(json) {
            NSDictionary *wrapped = nil;
            
            if([json isKindOfClass:[NSString class]]) {
                wrapped = [HWrapper wrapJSON:json];
            }
            else if([json isKindOfClass:[NSDictionary class]]) {
                wrapped = [HWrapper wrapDocumentDictionary:json];
            }
            
            NSString *whereQuery = [self buildWhereQueryFromJSON:wrapped];
            NSString *tableName = NSStringFromClass(self.documentModel);
            if(whereQuery) {
                NSString *finalQuery = [NSString stringWithFormat:@"SELECT * FROM %@ %@", tableName, whereQuery];
                
                NSMutableArray *values = [NSMutableArray array];
                NSArray *columns = [HTableHandler getColumns:wrapped];
                
                for(int i = 0; i < columns.count; i++) {
                    [values addObject:[wrapped objectForKey:[columns objectAtIndex:i]]];
                }
                
                [dba inDatabase:^(FMDatabase *db) {
                    FMResultSet *results = [db executeQuery:finalQuery withArgumentsInArray:values];
                    
                    if(results) {
                        while([results next]) {
                            [arr addObject:[HWrapper unwrapResults:results collection:self.documentModel]];
                        }
                    }
                    
                    [results close];
                }];
            }
        }
        else {
            NSMutableArray * inArrays = [NSMutableArray array];
            
            NSArray *equals = [self.queries objectForKey:@"equals"];
            NSMutableArray *values = [NSMutableArray array];
            
            if(equals) {
                for(int i = 0; i < equals.count; i++) {
                    HEquals *eq = [equals objectAtIndex:i];
                    
                    if([eq.type isEqualToString:@"in"] && [eq.value isKindOfClass:[NSArray class]]) {
                        [inArrays addObject:eq];
                    }
                    else if([eq.type isEqualToString:@"in"] && ![eq.value isKindOfClass:[NSArray class]]) {
                        [values addObject:[NSString stringWithFormat:@"%%%@%%", eq.value]];
                    }
                    else {
                        [values addObject:eq.value];
                    }
                }
                
                if(inArrays.count > 0) {
                    NSString *query = [self buildQuery];
                    
                    if(query) {
                        [dba inDatabase:^(FMDatabase *db) {
                            FMResultSet *results = [db executeQuery:query withArgumentsInArray:values];
                            BOOL FOUND = NO;
                            
                            if(results) {
                                while([results next] && !FOUND) {
                                    HDocument *doc = [HWrapper unwrapResults:results collection:self.documentModel];
                                    
                                    if(doc) {
                                        for(int i = 0; i < inArrays.count; i++) {
                                            HEquals *eq = [inArrays objectAtIndex:i];
                                            HWhere *eqWhere = eq.associatedWhere;
                                            
                                            if(eqWhere) {
                                                id value = [doc valueForKey:eqWhere.field];
                                                
                                                if(value) {
                                                    NSArray *isValues = eq.value;
                                                    
                                                    if([isValues containsObject:value]) {
                                                        [arr addObject:doc];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            [results close];
                        }];
                    }
                }
                else {
                    NSString *query = [self buildQuery];
                    [dba inDatabase:^(FMDatabase *db) {
                        FMResultSet *results = [db executeQuery:query withArgumentsInArray:values];
                        
                        if(results) {
                            while([results next]) {
                                [arr addObject:[HWrapper unwrapResults:results collection:self.documentModel]];
                            }
                        }
                        
                        [results close];
                    }];
                    
                }
            }
        }
    }
    
    NSArray *subObjects = [HWrapper getSubObjects];
    
    for(int i = 0; i < subObjects.count; i++) {
        HDocument *subObject = [subObjects objectAtIndex:i];
        [subObject load];
    }
    
    [self reset];
    
    return arr;
}

-(HDocument *) findOne: (id) json {
    FMDatabaseQueue * dba = [FMDBConnector sharedDatabase];
    HDocument __block *returnDoc = nil;
    
    if(dba) {
        if(json) {
            NSDictionary *wrapped = nil;
            
            if([json isKindOfClass:[NSString class]]) {
                wrapped = [HWrapper wrapJSON:json];
            }
            else if([json isKindOfClass:[NSDictionary class]]) {
                wrapped = [HWrapper wrapDocumentDictionary:json];
            }
            
            NSString *whereQuery = [self buildWhereQueryFromJSON:wrapped];
            NSString *tableName = NSStringFromClass(self.documentModel);
            if(whereQuery) {
                NSString *finalQuery = [NSString stringWithFormat:@"SELECT * FROM %@ %@", tableName, whereQuery];
                
                NSMutableArray *values = [NSMutableArray array];
                NSArray *columns = [HTableHandler getColumns:wrapped];
                
                for(int i = 0; i < columns.count; i++) {
                    [values addObject:[wrapped objectForKey:[columns objectAtIndex:i]]];
                }
                
                [dba inDatabase:^(FMDatabase *db) {
                    FMResultSet *results = [db executeQuery:finalQuery withArgumentsInArray:values];
                    
                    if(results) {
                        if([results next]) {
                            returnDoc = [HWrapper unwrapResults:results collection:self.documentModel];
                        }
                    }
                    
                    [results close];
                }];
            }
        }
        else {
            NSMutableArray * inArrays = [NSMutableArray array];
            
            NSArray *equals = [self.queries objectForKey:@"equals"];
            NSMutableArray *values = [NSMutableArray array];
            
            if(equals) {
                for(int i = 0; i < equals.count; i++) {
                    HEquals *eq = [equals objectAtIndex:i];
                    
                    if([eq.type isEqualToString:@"in"] && [eq.value isKindOfClass:[NSArray class]]) {
                        [inArrays addObject:eq];
                    }
                    else if([eq.type isEqualToString:@"in"] && ![eq.value isKindOfClass:[NSArray class]]) {
                        [values addObject:[NSString stringWithFormat:@"%%%@%%", eq.value]];
                    }
                    else {
                        [values addObject:eq.value];
                    }
                }
                
                if(inArrays.count > 0) {
                    NSString *query = [self buildQuery];
                    
                    if(query) {
                        [dba inDatabase:^(FMDatabase *db) {
                            FMResultSet *results = [db executeQuery:query withArgumentsInArray:values];
                            BOOL FOUND = NO;
                            
                            if(results) {
                                while([results next] && !FOUND) {
                                    HDocument *doc = [HWrapper unwrapResults:results collection:self.documentModel];
                                    
                                    if(doc) {
                                        for(int i = 0; i < inArrays.count; i++) {
                                            HEquals *eq = [inArrays objectAtIndex:i];
                                            HWhere *eqWhere = eq.associatedWhere;
                                            
                                            if(eqWhere) {
                                                id value = [doc valueForKey:eqWhere.field];
                                                
                                                if(value) {
                                                    NSArray *isValues = eq.value;
                                                    
                                                    if([isValues containsObject:value]) {
                                                        returnDoc = doc;
                                                        FOUND = YES;
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            [results close];
                        }];
                    }
                }
                else {
                    NSString *query = [self buildQuery];
                    [dba inDatabase:^(FMDatabase *db) {
                        FMResultSet *results = [db executeQuery:query withArgumentsInArray:values];
                        
                        if(results) {
                            if([results next]) {
                                returnDoc = [HWrapper unwrapResults:results collection:self.documentModel];
                            }
                        }
                        
                        [results close];
                    }];
                    
                }
            }
        }
    }
    
    NSArray *subObjects = [HWrapper getSubObjects];
    
    for(int i = 0; i < subObjects.count; i++) {
        HDocument *subObject = [subObjects objectAtIndex:i];
        [subObject load];
    }
    
    [self reset];

    return returnDoc;
}

-(HoopQuery *) take: (int) count {
    self.takeCount = count;
    return self;
}

-(HoopQuery *) skip: (int) count {
    self.skipCount = count;
    return self;
}

-(HoopQuery *) sort: (id) query {
    NSDictionary *wrapped = nil;
    
    if([query isKindOfClass:[NSString class]]) {
        wrapped = [HWrapper wrapJSON:query];
    }
    else if([query isKindOfClass:[NSDictionary class]]) {
        wrapped = [HWrapper wrapDocumentDictionary:query];
    }
    
    if(wrapped) {
        NSArray *columns = [HTableHandler getColumns:wrapped];
        
        for(int i = 0; i < columns.count; i++) {
            HSort *sortObject = [[HSort alloc] init];
            NSString *column = [columns objectAtIndex:i];
            
            id type = [wrapped objectForKey:column];
            
            if([type isKindOfClass:[NSNumber class]]) {
                NSNumber *num = (NSNumber *) type;
                
                if(num.intValue < 0) {
                    sortObject.field = column;
                    sortObject.direction = @"DESC";
                }
                else {
                    sortObject.field = column;
                    sortObject.direction = @"ASC";
                }
            }
            else if([type isKindOfClass:[NSString class]]) {
                sortObject.field = column;
                sortObject.direction = (NSString *)type;
            }
            
            if(sortObject.field && sortObject.direction) {
                NSMutableArray *sorts = [self.queries objectForKey:@"sorts"];
                
                if(sorts) {
                    [sorts addObject:sortObject];
                }
                else {
                    sorts = [NSMutableArray array];
                    [sorts addObject:sortObject];
                    [self.queries setObject:sorts forKey:@"sorts"];
                }
            }
        }
    }
    
    return self;
}

-(BOOL) remove: (id) json {
    FMDatabaseQueue * dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        if(json) {
            NSDictionary *wrapped = nil;
            
            if([json isKindOfClass:[NSString class]]) {
                wrapped = [HWrapper wrapJSON:json];
            }
            else if([json isKindOfClass:[NSDictionary class]]) {
                wrapped = [HWrapper wrapDocumentDictionary:json];
            }
            
            if(wrapped) {
                NSArray * columns = [HTableHandler getColumns:wrapped];
                NSString *whereQuery = [self buildWhereQueryFromJSON:wrapped];
                NSMutableArray *values = [NSMutableArray array];
                NSString *tableName = NSStringFromClass(self.documentModel);
                
                for(int i = 0; i < columns.count; i++) {
                    [values addObject:[wrapped objectForKey:[columns objectAtIndex:i]]];
                }
                
                NSString *finalQuery = [NSString stringWithFormat:@"DELETE FROM %@ %@", tableName, whereQuery];
                BOOL __block success = NO;
                
                [dba inDatabase:^(FMDatabase *db) {
                    success = [db executeUpdate:finalQuery withArgumentsInArray:values];
                }];
                
                [self reset];
                
                return success;
            }
        }
        else {
            NSMutableArray * inArrays = [NSMutableArray array];
            
            NSArray *equals = [self.queries objectForKey:@"equals"];
            NSMutableArray *values = [NSMutableArray array];
            NSString *tableName = NSStringFromClass(self.documentModel);
            
                if(equals) {
                    for(int i = 0; i < equals.count; i++) {
                        HEquals *eq = [equals objectAtIndex:i];
                        
                        if([eq.type isEqualToString:@"in"] && [eq.value isKindOfClass:[NSArray class]]) {
                            [inArrays addObject:eq];
                        }
                        else if([eq.type isEqualToString:@"in"] && ![eq.value isKindOfClass:[NSArray class]]) {
                            [values addObject:[NSString stringWithFormat:@"%%%@%%", eq.value]];
                        }
                        else {
                            [values addObject:eq.value];
                        }
                    }
                
                    if(inArrays.count > 0) {
                        NSString *query = [self buildQuery];
                        NSMutableArray __block *itemsToRemove = [NSMutableArray array];
                        
                        if(query) {
                            [dba inDatabase:^(FMDatabase *db) {
                                FMResultSet *results = [db executeQuery:query withArgumentsInArray:values];
                                
                                if(results) {
                                    while([results next]) {
                                        HDocument *doc = [HWrapper unwrapResults:results collection:self.documentModel];
                                        
                                        if(doc) {
                                            for(int i = 0; i < inArrays.count; i++) {
                                                HEquals *eq = [inArrays objectAtIndex:i];
                                                HWhere *eqWhere = eq.associatedWhere;
                                                
                                                if(eqWhere) {
                                                    id value = [doc valueForKey:eqWhere.field];
                                                    
                                                    if(value) {
                                                        NSArray *isValues = eq.value;
                                                        
                                                        if([isValues containsObject:value]) {
                                                            [itemsToRemove addObject:doc];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                [results close];
                            }];
                        }
                
                        if(itemsToRemove.count > 0) {
                            for(int i = 0; i < itemsToRemove.count; i++) {
                                HDocument *dc = [itemsToRemove objectAtIndex:i];
                                [dc remove];
                            }
                            
                            [self reset];
                            return YES;
                        }
                    }
                    else {
                        NSString *whereQuery = [self buildWhereQuery];
                        if(whereQuery) {
                            NSString *finalQuery = [NSString stringWithFormat:@"DELETE FROM %@ %@", tableName, whereQuery];
                            BOOL __block success = NO;
                            
                            [dba inDatabase:^(FMDatabase *db) {
                                success = [db executeUpdate:finalQuery withArgumentsInArray:values];
                            }];
                            
                            [self reset];
                            
                            return success;
                        }
                    }
                }
            }
    }
    
    [self reset];
    
    return NO;
}

//For Large Updates
-(BOOL) update: (id) json {
    FMDatabaseQueue * dba = [FMDBConnector sharedDatabase];
    
    if(dba) {
        NSDictionary *wrapped = nil;
        
        if([json isKindOfClass:[NSString class]]) {
            wrapped = [HWrapper wrapJSON:json];
        }
        else if([json isKindOfClass:[NSDictionary class]]) {
            wrapped = [HWrapper wrapDocumentDictionary:json];
        }
        
        if(json) {
            NSMutableArray * inArrays = [NSMutableArray array];
            
            NSArray *equals = [self.queries objectForKey:@"equals"];
            NSMutableArray *values = [NSMutableArray array];
            
            if(equals) {
                for(int i = 0; i < equals.count; i++) {
                    HEquals *eq = [equals objectAtIndex:i];
                    
                    if([eq.type isEqualToString:@"in"] && [eq.value isKindOfClass:[NSArray class]]) {
                        [inArrays addObject:eq];
                    }
                    else if([eq.type isEqualToString:@"in"] && ![eq.value isKindOfClass:[NSArray class]]) {
                        [values addObject:[NSString stringWithFormat:@"%%%@%%", eq.value]];
                    }
                    else {
                        [values addObject:eq.value];
                    }
                }
                
                if(inArrays.count > 0) {
                    NSString *query = [self buildQuery];
                    NSMutableArray __block *itemsToUpdate = [NSMutableArray array];
                    
                    if(query) {
                        [dba inDatabase:^(FMDatabase *db) {
                            FMResultSet *results = [db executeQuery:query withArgumentsInArray:values];
                            
                            if(results) {
                                while([results next]) {
                                    HDocument *doc = [HWrapper unwrapResults:results collection:self.documentModel];
                                    
                                    if(doc) {
                                        for(int i = 0; i < inArrays.count; i++) {
                                            HEquals *eq = [inArrays objectAtIndex:i];
                                            HWhere *eqWhere = eq.associatedWhere;
                                            
                                            if(eqWhere) {
                                                id value = [doc valueForKey:eqWhere.field];
                                                
                                                if(value) {
                                                    NSArray *isValues = eq.value;
                                                    
                                                    if([isValues containsObject:value]) {
                                                        [itemsToUpdate addObject:doc];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            [results close];
                        }];
                    }
                    
                    NSArray *columns = [HTableHandler getColumns:wrapped];
                    
                    if(itemsToUpdate.count > 0) {
                        for(int i = 0; i < itemsToUpdate.count; i++) {
                            HDocument *dc = [itemsToUpdate objectAtIndex:i];
                            
                            for(int j = 0; j < columns.count; j++) {
                                NSString *column = [columns objectAtIndex:j];
                                [dc setValue:[wrapped objectForKey:column] forKey:column];
                            }
                            
                            [dc save];
                        }
                        
                        [self reset];
                        
                        return YES;
                    }
                }
                else {
                    NSString *updateQuery = [self buildUpdateQuery:wrapped];
                    
                    if(updateQuery) {
                        NSString *whereQuery = [self buildWhereQuery];
                        if(whereQuery) {
                            NSString *finalQuery = [NSString stringWithFormat:@"%@ %@", updateQuery, whereQuery];
                            BOOL __block success = NO;
                            
                            NSMutableArray *finalValues = [NSMutableArray array];
                            
                            NSArray *columns = [HTableHandler getColumns:wrapped];
                            
                            for(int i = 0; i < columns.count; i++) {
                                [finalValues addObject:[wrapped objectForKey:[columns objectAtIndex:i]]];
                            }
                            
                            [finalValues addObjectsFromArray:values];
                            
                            [dba inDatabase:^(FMDatabase *db) {
                                success = [db executeUpdate:finalQuery withArgumentsInArray:finalValues];
                            }];
                            
                            [self reset];
                            
                            return success;
                        }
                    }
                }
            }
        }
    }
    
    [self reset];
    
    return NO;
}

-(NSString *) buildQuery {
    NSString *tableName = NSStringFromClass(self.documentModel);
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", tableName];
    NSString *whereQuery = [self buildWhereQuery];
    
    if(whereQuery) {
        [query appendString:whereQuery];
        
        NSString *sortQuery = [self buildSortQuery];
        
        if(sortQuery) {
            [query appendFormat:@" %@", sortQuery];
        }
        
        [query appendString:[NSString stringWithFormat:@" LIMIT %d,%d",self.skipCount,self.takeCount]];
        
        return query;
    }
    
    
    return nil;
}

-(NSString *) buildWhereQuery {
    NSArray *wheres = [self.queries objectForKey:@"where"];
    NSArray *equals = [self.queries objectForKey:@"equals"];
    
    NSMutableString *query = [NSMutableString stringWithFormat:@""];
    
    if(wheres.count == equals.count) {
        HWhere *previous = nil;
        for(int i = 0; i < wheres.count; i++) {
            HWhere *where = [wheres objectAtIndex:i];
            HEquals *equal = [equals objectAtIndex:i];
            equal.associatedWhere = where;
            
            if(previous == nil) {
                if([equal.type isEqualToString:@"in"] && wheres.count == 1) {
                    if([equal.value isKindOfClass:[NSArray class]]) {
                        [query appendString:@"WHERE 1"];
                    }
                    else {
                        id vl = nil;
                        
                        if([equal.value isKindOfClass:[HDocument class]]) {
                            HDocument *dc = (HDocument *) equal.value;
                            
                            vl = dc._id;
                        }
                        else {
                            vl = equal.value;
                        }
                        
                        [query appendFormat:@"WHERE %@ LIKE ?", [self escape:where.field]];
                    }
                }
                else if(![equal.type isEqualToString:@"in"]) {
                    [query appendFormat:@"WHERE %@ %@ ?", [self escape:where.field], equal.type];
                }
                else {
                    if(![equal.value isKindOfClass:[NSArray class]]) {
                        id vl = nil;
                        
                        if([equal.value isKindOfClass:[HDocument class]]) {
                            HDocument *dc = (HDocument *) equal.value;
                            
                            vl = dc._id;
                        }
                        else {
                            vl = equal.value;
                        }
                        
                        [query appendFormat:@"WHERE %@ LIKE ?", [self escape:where.field]];
                    }
                }
            }
            else {
                if(![equal.type isEqualToString:@"in"]) {
                    [query appendFormat:@" %@ %@ %@ ?", where.andOr, [self escape:where.field], equal.type];
                }
                else {
                    if(![equal.value isKindOfClass:[NSArray class]]) {
                        id vl = nil;
                        
                        if([equal.value isKindOfClass:[HDocument class]]) {
                            HDocument *dc = (HDocument *) equal.value;
                            
                            vl = dc._id;
                        }
                        else {
                            vl = equal.value;
                        }
                        
                        [query appendFormat:@" %@ %@ LIKE '?", where.andOr, [self escape:where.field]];
                    }
                }
            }
            
            previous = where;
        }
                     
        return query;
    }
    
    return nil;
}

-(NSString *) buildWhereQueryFromJSON: (NSDictionary *) json {
    NSDictionary *wrapped = json;
    
    if(wrapped) {
        NSArray * columns = [HTableHandler getColumns:wrapped];
    
        NSMutableString * whereQuery = [NSMutableString stringWithString:@""];
        
        for(int i = 0; i < columns.count; i++) {
            if(i == 0) {
                [whereQuery appendFormat:@"WHERE %@ = ?", [self escape:[columns objectAtIndex:i]]];
            }
            else {
                [whereQuery appendFormat:@" AND WHERE %@ = ?", [self escape:[columns objectAtIndex:i]]];
            }
        }
        
        return whereQuery;
    }
    
    return nil;
}

-(NSString *) buildSortQuery {
    NSMutableString *query = [NSMutableString stringWithString:@"ORDER BY "];
    
    NSArray *sorts = [self.queries objectForKey:@"sorts"];
    
    if(sorts) {
        for(int i = 0; i < sorts.count; i++) {
            HSort *sort = [sorts objectAtIndex:i];
            [query appendFormat:@"%@ %@, ",[self escape:sort.field],sort.direction];
        }
        
        return [query substringToIndex:query.length - 2];
    }
    
    return nil;
}

-(NSString *) buildUpdateQuery: (NSDictionary *) dict {
    NSString *tableName = NSStringFromClass(self.documentModel);
    NSMutableString *update = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", tableName];
    
    NSArray *columns = [HTableHandler getColumns:dict];
    
    if(columns.count > 0) {
        for(int i = 0; i < columns.count; i++) {
            NSString *column = [columns objectAtIndex:i];
            
            [update appendFormat:@"%@ = ?,", [self escape:column]];
        }
        
        return [update substringToIndex:update.length - 1];
    }
    
    return nil;
}

-(NSString *) escape: (NSString *) column {
    return [NSString stringWithFormat:@"`%@`", column];
}

@end
