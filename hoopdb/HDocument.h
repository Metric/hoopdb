//
//  HDocument.h
//  hoopdb
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDocument : NSObject
@property (nonatomic, strong) NSString *_id;
@property (nonatomic) double _v;
@property (nonatomic) BOOL loaded;
-(id) initWithJSON: (NSString *) json;
-(id) initWithObject: (NSObject *) obj;
-(id) initWithJSONDictionary: (NSDictionary *) dict;
-(BOOL) save;
-(BOOL) remove;
-(BOOL) load;
-(id) query;
-(NSString *) toJSON;
@end
