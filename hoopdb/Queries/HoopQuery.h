//
//  HoopQuery.h
//  hoopdb
//
//  Created by Aaron Klick on 10/7/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../HDocument.h"

@interface HoopQuery : NSObject
+(id) withCollection: (Class) dc;
@property (nonatomic) Class documentModel;
@property (nonatomic) int skipCount;
@property (nonatomic) int takeCount;
@property (nonatomic) NSMutableDictionary *queries;
-(HoopQuery *) where: (NSString *) field;
-(HoopQuery *) equals: (id) data;
-(HoopQuery *) whereOr: (NSString *) field;
-(HoopQuery *) lte: (id) data;
-(HoopQuery *) gte: (id) data;
-(HoopQuery *) gt: (id) data;
-(HoopQuery *) lt: (id) data;
-(HoopQuery *) like: (id) data;
-(HoopQuery *) notEquals: (id) data;
-(HoopQuery *) inArray: (id) data;
-(NSArray *) find: (id) json;
-(HDocument *) findOne: (id) json;
-(HoopQuery *) take: (int) count;
-(HoopQuery *) skip: (int) count;
-(HoopQuery *) sort: (id) json;
-(int) count: (id) json;
-(BOOL) remove: (id) json;
-(BOOL) update: (id) json;
@end
