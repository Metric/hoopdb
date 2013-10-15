//
//  binDB.m
//  binDB
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import "hoopdb.h"
#import "Utils/HTableHandler.h"

@implementation hoopdb
+(BOOL) open: (NSString *) database {
    return !![FMDBConnector open:database];
}

+(void) close {
    [FMDBConnector close];
}

+(HoopQuery *) registerDocumentModel:(Class)model {
    if(![HTableHandler create:model]) {
        [HTableHandler alter:model];
    }
    
    return [HoopQuery withCollection:model];
}
@end
