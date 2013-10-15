//
//  QueryWrapper.m
//  binDB
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import "HWrapper.h"
#import "../HDocument.h"
#import "../Reflection/MARTNSObject.h"
#import "../Reflection/RTProperty.h"
#import "../Utils/QSStrings.h"
#import "../Reflection/RTMethod.h"
#import "../hoopdb.h"
static NSMutableArray *toLoad;

@implementation HWrapper
+(NSMutableDictionary *) wrapJSON:(NSString *)json {
    NSMutableDictionary * wrapped = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    return wrapped;
}

+(NSArray *) getSubObjects {
    NSArray *arr = [[NSArray alloc] initWithArray:toLoad];
    
    [toLoad removeAllObjects];
    
    return arr;
}

+(NSMutableDictionary *) wrapObject:(NSObject *)obj {
    NSMutableDictionary * wrapped = [NSMutableDictionary dictionary];
    
    NSArray *props = [[obj class] rt_properties];
    
    if([obj isKindOfClass:[HDocument class]]) {
        HDocument *dc = (HDocument *) obj;
        [wrapped setObject:dc._id forKey:@"_id"];
        [wrapped setObject:[NSNumber numberWithDouble:dc._v] forKey:@"_v"];
    }
    
    for(int i = 0; i < props.count; i++) {
        RTProperty *prop = (RTProperty *)[props objectAtIndex:i];
        
        NSString *propName = [prop name];
        
        id propValue = [obj valueForKey:propName];
        
        if(propValue == nil) {
            [wrapped setObject:[NSNull null] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSNull class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSString class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSData class]]) {
            [wrapped setObject:[HWrapper wrapData:(NSData *) propValue] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSDate class]]) {
            [wrapped setObject:[HWrapper wrapDate:(NSDate *) propValue] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSArray class]]) {
            NSArray *objArr = [HWrapper wrapArray:(NSArray *) propValue];
            [wrapped setObject:objArr forKey:propName];
        }
        else if([propValue isKindOfClass:[NSNumber class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDict = [HWrapper wrapDictionary:(NSDictionary *)propValue];
            [wrapped setObject:objDict forKey:propName];
        }
        else if([propValue isKindOfClass:[NSValue class]]) {
            //Skip it we can't do anything with this!
        }
        else if([propValue isKindOfClass:[HDocument class]]) {
            NSDictionary *objDict = [HWrapper wrapObject:(NSObject *) propValue];
            
            [wrapped setObject:objDict forKey:propName];
        }
    }
    
    return wrapped;
}


+(NSMutableDictionary *) wrapDictionary:(NSDictionary *) dict {
    NSMutableDictionary *wrapped = [NSMutableDictionary dictionary];
    
    NSArray * keys = [dict keysSortedByValueUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    for(int i = 0; i < keys.count; i++) {
        NSString *propName = [keys objectAtIndex:i];
        id propValue = [dict objectForKey:propName];
        
        if(propValue == nil) {
            [wrapped setObject:[NSNull null] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSNull class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSString class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSData class]]) {
            [wrapped setObject:[HWrapper wrapData:(NSData *) propValue] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSDate class]]) {
            [wrapped setObject:[HWrapper wrapDate:(NSDate *) propValue] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSArray class]]) {
            NSArray *objArr = [HWrapper wrapArray:(NSArray *) propValue];
            [wrapped setObject:objArr forKey:propName];
        }
        else if([propValue isKindOfClass:[NSNumber class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDict = [HWrapper wrapDictionary:(NSDictionary *)propValue];
            [wrapped setObject:objDict forKey:propName];
        }
        else if([propValue isKindOfClass:[NSValue class]]) {
            //Skip it, we can't do anything with this!
        }
        else if([propValue isKindOfClass:[HDocument class]]) {
            NSDictionary *objDict = [HWrapper wrapObject:(NSObject *) propValue];
            
            [wrapped setObject:objDict forKey:propName];
        }
    }
    
    return wrapped;
}

+(NSArray *) wrapDocumentArray: (NSArray *) arr {
    NSMutableArray *wrapped = [NSMutableArray array];
    
    for(int i = 0; i < arr.count; i++) {
        id propValue =  [arr objectAtIndex:i];
        
        if(propValue == nil) {
            [wrapped addObject:[NSNull null]];
        }
        else if([propValue isKindOfClass:[NSNull class]]) {
            [wrapped addObject:propValue];
        }
        else if([propValue isKindOfClass:[NSString class]]) {
            [wrapped addObject:propValue];
        }
        else if([propValue isKindOfClass:[NSData class]]) {
            [wrapped addObject:[NSString stringWithFormat:@"data::%@", [HWrapper wrapData:(NSData *) propValue]]];
        }
        else if([propValue isKindOfClass:[NSDate class]]) {
            NSDate * dt = (NSDate *) propValue;
            [wrapped addObject:[HWrapper wrapDate:dt]];
        }
        else if([propValue isKindOfClass:[NSArray class]]) {
            NSArray *objArr = [HWrapper wrapDocumentArray:(NSArray *) propValue];
            [wrapped addObject:objArr];
        }
        else if([propValue isKindOfClass:[NSNumber class]]) {
            [wrapped addObject:propValue];
        }
        else if([propValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDict = [HWrapper wrapDocumentDictionary:(NSDictionary *)propValue];
            [wrapped addObject:objDict];
        }
        else if([propValue isKindOfClass:[NSValue class]]) {
            //Skip it, we can't do anything with this!
        }
        else if([propValue isKindOfClass:[HDocument class]]) {
            HDocument *doc = (HDocument *) propValue;
            NSString *className = NSStringFromClass([doc class]);
            
            [wrapped addObject:[NSString stringWithFormat:@"obj::%@::%@",className,doc._id]];
        }
    }
    
    return wrapped;
}

+(NSDictionary *) wrapDocumentDictionary: (NSDictionary *) dict {
    NSMutableDictionary *wrapped = [NSMutableDictionary dictionary];
    
    NSArray * keys = [dict keysSortedByValueUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    for(int i = 0; i < keys.count; i++) {
        NSString *propName = [keys objectAtIndex:i];
        id propValue = [dict objectForKey:propName];
        
        if(propValue == nil) {
            [wrapped setObject:[NSNull null] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSNull class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSString class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSData class]]) {
            [wrapped setObject:[NSString stringWithFormat:@"data::%@", [HWrapper wrapData:(NSData *) propValue]] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSDate class]]) {
            NSDate *dt = (NSDate *) propValue;
            [wrapped setObject:[HWrapper wrapDate:dt] forKey:propName];
        }
        else if([propValue isKindOfClass:[NSArray class]]) {
            NSArray *objArr = [HWrapper wrapDocumentArray:(NSArray *) propValue];
            [wrapped setObject:objArr forKey:propName];
        }
        else if([propValue isKindOfClass:[NSNumber class]]) {
            [wrapped setObject:propValue forKey:propName];
        }
        else if([propValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDict = [HWrapper wrapDocumentDictionary:(NSDictionary *)propValue];
            [wrapped setObject:objDict forKey:propName];
        }
        else if([propValue isKindOfClass:[NSValue class]]) {
            //Skip it, we can't do anything with this!
        }
        else if([propValue isKindOfClass:[HDocument class]]) {
            HDocument *doc = (HDocument *) propValue;
            NSString *className = NSStringFromClass([doc class]);
            
            [wrapped setObject:[NSString stringWithFormat:@"obj::%@::%@",className,doc._id] forKey:propName];
        }
    }
    
    return wrapped;
}

+(id) unwrapResults: (FMResultSet *) results collection: (Class) collection {
    NSArray *properties = [collection rt_properties];
    HDocument *doc = [[collection alloc] init];
    
    if(toLoad == nil) {
        toLoad = [NSMutableArray array];
    }
    
    doc._id = [results stringForColumn:@"_id"];
    doc._v = [results doubleForColumn:@"_v"];
    
    for(int i = 0; i < properties.count; i++) {
        RTProperty *prop = [properties objectAtIndex:i];
        
        NSString *propName = [prop name];
        NSString *propType = [[[prop typeEncoding] stringByReplacingOccurrencesOfString:@"\"" withString:@""] substringFromIndex:1];
        Class propClass = NSClassFromString(propType);
        
        if(propType.length == 0) {
            [doc setValue:[NSNumber numberWithDouble:[results doubleForColumn:propName]] forKey:propName];
        }
        else if(propClass == nil) {
            [doc setValue:[NSNull null] forKey:propName];
        }
        else if(propClass == [NSNull class] || [propClass isSubclassOfClass:[NSNull class]]) {
            [doc setValue:[NSNull null] forKey:propName];
        }
        else if(propClass == [NSString class] || [propClass isSubclassOfClass:[NSString class]]) {
            [doc setValue:[results stringForColumn:propName] forKey:propName];
        }
        else if(propClass == [NSData class]) {
            [doc setValue:[QSStrings decodeBase64WithString:[results stringForColumn:propName]] forKey:propName];
        }
        else if(propClass == [NSDate class]) {
            [doc setValue:[HWrapper unwrapDate:[results stringForColumn:propName]] forKey:propName];
        }
        else if(propClass == [NSArray class] || [propClass isSubclassOfClass:[NSArray class]]) {
            NSString *arrayString = [results stringForColumn:propName];
            
            if(arrayString.length > 0) {
                if(propClass == [NSMutableArray class]) {
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[self unwrapArray:[NSJSONSerialization JSONObjectWithData:[arrayString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]]];
                    [doc setValue:arr forKey:propName];
                }
                else {
                    [doc setValue:[self unwrapArray:[NSJSONSerialization JSONObjectWithData:[arrayString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]] forKey:propName];
                }
            }
        }
        else if(propClass == [NSNumber class] || [propClass isSubclassOfClass:[NSNumber class]]) {
            [doc setValue:[NSNumber numberWithDouble:[results doubleForColumn:propName]] forKey:propName];
        }
        else if(propClass == [NSDictionary class] || [propClass isSubclassOfClass:[NSDictionary class]]) {
            NSString *dictString = [results stringForColumn:propName];
            
            if(dictString.length > 0) {
                if(propClass == [NSMutableDictionary class]) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[self unwrapDictionary:[NSJSONSerialization JSONObjectWithData:[dictString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]]];
                    [doc setValue:dic forKey:propName];
                }
                else {
                    [doc setValue:[self unwrapDictionary:[NSJSONSerialization JSONObjectWithData:[dictString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]] forKey:propName];
                }
            }
        }
        else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
            NSString *objID = [[results stringForColumn:propName] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"obj::%@::", propType] withString:@""];
            
            if(![objID isEqualToString:@"(null)"]) {
                HDocument *dc = [[propClass alloc] init];
                dc._id = objID;
                
                [toLoad addObject:dc];
                
                [doc setValue:dc forKey:propName];
            }
        }
    }
    
    return doc;
}

+(NSDictionary *) unwrapDictionary: (NSDictionary *) dict {
    NSMutableDictionary * unwrapped = [NSMutableDictionary dictionary];
    
    NSArray *keys = [HWrapper getColumns:dict];
    
    for(int i = 0; i < keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        
        id item = [dict objectForKey:key];
        
        if([item isKindOfClass:[NSArray class]]) {
            [unwrapped setObject:[HWrapper unwrapArray:item] forKey:key];
        }
        else if([item isKindOfClass:[NSDictionary class]]) {
            [unwrapped setObject:[HWrapper unwrapDictionary:item] forKey:key];
        }
        else if([item isKindOfClass:[NSString class]]) {
            NSString * sitem = (NSString *) item;
            
            if([sitem hasPrefix:@"obj::"]) {
                sitem = [sitem stringByReplacingOccurrencesOfString:@"obj::" withString:@""];
                NSString *classType = [sitem substringToIndex:[sitem rangeOfString:@"::"].location];
                classType = [classType stringByReplacingOccurrencesOfString:@"::" withString:@""];
                sitem = [sitem stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@::", classType] withString:@""];
                
                Class objClass = NSClassFromString(classType);
                
                if(objClass) {
                    if(![sitem isEqualToString:@"(null)"]) {
                        HDocument *doc = [[objClass alloc] init];
                        doc._id = sitem;
                        [toLoad addObject:doc];
                        
                        [unwrapped setObject:doc forKey:key];
                    }
                }
            }
            else if([sitem hasPrefix:@"data::"]) {
                sitem = [sitem stringByReplacingOccurrencesOfString:@"data::" withString:@""];
                NSData *data = [QSStrings decodeBase64WithString:sitem];
                [unwrapped setObject:data forKey:key];
            }
            else {
                NSDate *isDate = [HWrapper unwrapDate:item];
                
                if(isDate) {
                    [unwrapped setObject:isDate forKey: key];
                }
                else {
                    [unwrapped setObject:item forKey: key];
                }
            }
        }
        else {
            [unwrapped setObject:item forKey:key];
        }
    }
    
    return unwrapped;
}

+(NSArray *) unwrapArray: (NSArray *) arr {
    NSMutableArray *unwrapped = [NSMutableArray array];
    
    for(int i = 0; i < arr.count; i++) {
        id item = [arr objectAtIndex:i];
        
        if([item isKindOfClass:[NSArray class]]) {
            [unwrapped addObject:[HWrapper unwrapArray:item]];
        }
        else if([item isKindOfClass:[NSDictionary class]]) {
            [unwrapped addObject:[HWrapper unwrapDictionary:item]];
        }
        else if([item isKindOfClass:[NSString class]]) {
            NSString * sitem = (NSString *) item;
            
            if([sitem hasPrefix:@"obj::"]) {
                sitem = [sitem stringByReplacingOccurrencesOfString:@"obj::" withString:@""];
                NSString *classType = [sitem substringToIndex:[sitem rangeOfString:@"::"].location];
                classType = [classType stringByReplacingOccurrencesOfString:@"::" withString:@""];
                sitem = [sitem stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@::", classType] withString:@""];
                
                Class objClass = NSClassFromString(classType);
                
                if(objClass) {
                    if(![sitem isEqualToString:@"(null)"]) {
                        HDocument *doc = [[objClass alloc] init];
                        doc._id = sitem;
                        [toLoad addObject:doc];
                        
                        [unwrapped addObject:doc];
                    }
                }
            }
            else if([sitem hasPrefix:@"data::"]) {
                sitem = [sitem stringByReplacingOccurrencesOfString:@"data::" withString:@""];
                NSData *data = [QSStrings decodeBase64WithString:sitem];
                [unwrapped addObject:data];
            }
            else {
                NSDate *isDate = [HWrapper unwrapDate:item];
                
                if(isDate) {
                    [unwrapped addObject:isDate];
                }
                else {
                    [unwrapped addObject:item];
                }
            }
        }
        else {
            [unwrapped addObject:item];
        }
    }
    
    return unwrapped;
}

+(NSArray *) wrapArray: (NSArray *) arr {
    NSMutableArray *wrapped = [NSMutableArray array];
    
    for(int i = 0; i < arr.count; i++) {
        id propValue =  [arr objectAtIndex:i];
        
        if(propValue == nil) {
            [wrapped addObject:[NSNull null]];
        }
        else if([propValue isKindOfClass:[NSNull class]]) {
            [wrapped addObject:propValue];
        }
        else if([propValue isKindOfClass:[NSString class]]) {
            [wrapped addObject:propValue];
        }
        else if([propValue isKindOfClass:[NSData class]]) {
            [wrapped addObject:[HWrapper wrapData:(NSData *) propValue]];
        }
        else if([propValue isKindOfClass:[NSDate class]]) {
            [wrapped addObject:[HWrapper wrapDate:(NSDate *) propValue]];
        }
        else if([propValue isKindOfClass:[NSArray class]]) {
            NSArray *objArr = [HWrapper wrapArray:(NSArray *) propValue];
            [wrapped addObject:objArr];
        }
        else if([propValue isKindOfClass:[NSNumber class]]) {
            [wrapped addObject:propValue];
        }
        else if([propValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDict = [HWrapper wrapDictionary:(NSDictionary *)propValue];
            [wrapped addObject:objDict];
        }
        else if([propValue isKindOfClass:[NSValue class]]) {
            //Skip it, we can't do anything with this!
        }
        else if([propValue isKindOfClass:[HDocument class]]) {
            NSDictionary *objDict = [HWrapper wrapObject:(NSObject *) propValue];
            
            [wrapped addObject:objDict];
        }
    }
    
    return wrapped;
}

+(NSDate *) unwrapDate: (NSString *) date {
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [rfc3339DateFormatter dateFromString:date];
}

+(NSString *) wrapDate: (NSDate *) date {
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
   
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [rfc3339DateFormatter stringFromDate:date];
}

+(NSString *) wrapData: (NSData *) data {
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+(NSArray *) getColumns: (NSDictionary *) dict {
    NSArray *columns = [dict keysSortedByValueUsingComparator:^NSComparisonResult(NSString *item1, NSString *item2) {
        return [item1 compare:item2];
    }];
    
    return columns;
}

@end
