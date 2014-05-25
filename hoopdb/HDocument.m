//
//  HDocument.m
//  hoopdb
//
//  Created by Aaron Klick on 10/6/13.
//  Copyright (c) 2013 Vantage Technic. All rights reserved.
//

#import "HDocument.h"
#import "Utils/HWrapper.h"
#import "Reflection/MARTNSObject.h"
#import "Queries/HoopQuery.h"
#import "Reflection/RTProperty.h"
#import "Utils/HTableHandler.h"
#import "Utils/QSStrings.h"
#import "hoopdb.h"

@implementation HDocument

-(id) init {
    self = [super init];
    if(self) {
        [self initializeDefaults];
    }
    return self;
}

-(id) query {
    return [HoopQuery withCollection:[self class]];
}

- (id) initWithJSONData: (NSData *) data {
    
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    if(json) {
        return [self initWithJSONDictionary:json];
    }
    
    return nil;
}

-(id) initWithJSON: (NSString *) json {
    self = [super init];
    if(self) {
        NSMutableDictionary *wrapped  = [HWrapper wrapJSON:json];
        NSArray *props = [[self class] rt_properties];
        
        for(int i = 0; i < props.count; i++) {
            RTProperty *prop = [props objectAtIndex:i];
            NSString *propName = prop.name;
            Class propClass = NSClassFromString([[[prop.attributes objectForKey:@"T"] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""]);
            
            if(![[wrapped objectForKey:propName] isKindOfClass:[NSNull class]]) {
                if(propClass == [NSNull class] || [propClass isSubclassOfClass:[NSNull class]]) {
                    [self setValue:[NSNull null] forKey:propName];
                }
                else if(propClass == [NSData class] || [propClass isSubclassOfClass:[NSData class]]) {
                    [self setValue:[QSStrings decodeBase64WithString:[wrapped objectForKey:propName]] forKey:propName];
                }
                else if(propClass == [NSDate class] || [propClass isSubclassOfClass:[NSDate class]]) {
                    [self setValue:[NSDate dateWithTimeIntervalSince1970:((NSNumber *)[wrapped objectForKey:propName]).doubleValue] forKey:propName];
                }
                else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
                    HDocument *doc = [[propClass alloc] initWithJSONDictionary:[wrapped objectForKey:propName]];
                    [self setValue:doc forKey:propName];
                }
                else {
                    id value = [wrapped objectForKey:propName];
                    
                    [self setValue:value forKey:propName];
                }
            }
        }
        
        Class superClass = [self superclass];
        
        while(superClass != [NSObject class]) {
            props = [superClass rt_properties];
            
            for(int i = 0; i < props.count; i++) {
                RTProperty *prop = [props objectAtIndex:i];
                NSString *propName = prop.name;
                Class propClass = NSClassFromString([[[prop.attributes objectForKey:@"T"] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""]);
                
                if(![[wrapped objectForKey:propName] isKindOfClass:[NSNull class]]) {
                    if(propClass == [NSNull class] || [propClass isSubclassOfClass:[NSNull class]]) {
                        [self setValue:[NSNull null] forKey:propName];
                    }
                    else if(propClass == [NSData class] || [propClass isSubclassOfClass:[NSData class]]) {
                        [self setValue:[QSStrings decodeBase64WithString:[wrapped objectForKey:propName]] forKey:propName];
                    }
                    else if(propClass == [NSDate class] || [propClass isSubclassOfClass:[NSDate class]]) {
                        [self setValue:[NSDate dateWithTimeIntervalSince1970:((NSNumber *)[wrapped objectForKey:propName]).doubleValue] forKey:propName];
                    }
                    else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
                        HDocument *doc = [[propClass alloc] initWithJSONDictionary:[wrapped objectForKey:propName]];
                        [self setValue:doc forKey:propName];
                    }
                    else {
                        id value = [wrapped objectForKey:propName];
                        
                        [self setValue:value forKey:propName];
                    }
                }
            }
            
            superClass = [superClass superclass];
        }
        
        [self initializeDefaults];
    }
    
    return self;
}

-(id) initWithObject: (NSObject *) obj {
    self = [super init];
    if(self) {
        NSArray *props = [[self class] rt_properties];
        
        for(int i = 0; i < props.count; i++) {
            RTProperty *prop = [props objectAtIndex:i];
            NSString *propName = prop.name;
            
            [self setValue:[obj valueForKey:propName] forKey:propName];
        }
        
        Class superClass = [self superclass];
        
        while(superClass != [NSObject class]) {
            props = [superClass rt_properties];
            
            for(int i = 0; i < props.count; i++) {
                RTProperty *prop = [props objectAtIndex:i];
                NSString *propName = prop.name;
                
                [self setValue:[obj valueForKey:propName] forKey:propName];
            }
            
            superClass = [superClass superclass];
        }
        
        [self initializeDefaults];
    }
    return self;
}

-(void) initializeDefaults {
    self._id = [HDocument getGuid];
    self._v = [NSNumber numberWithDouble:0.0];
}

-(id) initWithJSONDictionary: (NSDictionary *) dict {
    self = [super init];
    if(self) {
        NSArray *props = [[self class] rt_properties];
        
        for(int i = 0; i < props.count; i++) {
            RTProperty *prop = [props objectAtIndex:i];
            NSString *propName = prop.name;
            Class propClass = NSClassFromString([[[prop.attributes objectForKey:@"T"] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""]);
            
            if(![[dict objectForKey:propName] isKindOfClass:[NSNull class]]) {
                if(propClass == [NSData class] || [propClass isSubclassOfClass:[NSData class]]) {
                    [self setValue:[QSStrings decodeBase64WithString:[dict objectForKey:propName]] forKey:propName];
                }
                else if(propClass == [NSDate class] || [propClass isSubclassOfClass:[NSDate class]]) {
                    [self setValue:[NSDate dateWithTimeIntervalSince1970:((NSNumber *)[dict objectForKey:propName]).doubleValue] forKey:propName];
                }
                else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
                    HDocument *doc = [[propClass alloc] initWithJSONDictionary:[dict objectForKey:propName]];
                    [self setValue:doc forKey:propName];
                }
                else {
                    id value = [dict objectForKey:propName];
                    
                    [self setValue:value forKey:propName];
                }
            }
        }
        
        Class superClass = [self superclass];
        
        while(superClass != [NSObject class]) {
            props = [superClass rt_properties];
            
            for(int i = 0; i < props.count; i++) {
                RTProperty *prop = [props objectAtIndex:i];
                NSString *propName = prop.name;
                Class propClass = NSClassFromString([[[prop.attributes objectForKey:@"T"] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""]);
                
                if(![[dict objectForKey:propName] isKindOfClass:[NSNull class]]) {
                    if(propClass == [NSData class] || [propClass isSubclassOfClass:[NSData class]]) {
                        [self setValue:[QSStrings decodeBase64WithString:[dict objectForKey:propName]] forKey:propName];
                    }
                    else if(propClass == [NSDate class] || [propClass isSubclassOfClass:[NSDate class]]) {
                        [self setValue:[NSDate dateWithTimeIntervalSince1970:((NSNumber *)[dict objectForKey:propName]).doubleValue] forKey:propName];
                    }
                    else if(propClass == [HDocument class] || [propClass isSubclassOfClass:[HDocument class]]) {
                        HDocument *doc = [[propClass alloc] initWithJSONDictionary:[dict objectForKey:propName]];
                        [self setValue:doc forKey:propName];
                    }
                    else {
                        id value = [dict objectForKey:propName];
                        
                        [self setValue:value forKey:propName];
                    }
                }
            }
            
            superClass = [superClass superclass];
        }
        
        [self initializeDefaults];
    }
    return self;
}

- (NSString *) toJSON {
    NSData * json = [NSJSONSerialization dataWithJSONObject:[HWrapper wrapObject:self] options:NSJSONWritingPrettyPrinted error:nil];
    
    if(json) {
        NSString *finalJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        return finalJson;
    }
    
    return nil;
}

- (NSMutableDictionary *) toJSONDictionary {
    return [HWrapper wrapObject:self];
}

-(BOOL) save {
    self._v = [NSNumber numberWithDouble:self._v.doubleValue + 0.01];
    
    if([HTableHandler documentExists:self]) {
        return [HTableHandler update:self];
    }
    else {
        return [HTableHandler insert:self];
    }
}
/** Literally drops all documents / table for this class **/
/** Only use if you want to remove all documents of this class type! **/
/** Otherwise to remove the document just use remove **/
+(BOOL) removeAll {
    return [HTableHandler drop:[self class]];
}

+(NSArray *) getAllDocuments {
    return [HTableHandler all:[self class]];
}

-(BOOL) remove {
    return [HTableHandler remove:self];
}

-(BOOL) load {
    
    HDocument *doc = [HTableHandler getDocument:self];
    
    NSArray *props = [[self class] rt_properties];
    
    if(doc) {
        for(int i = 0; i < props.count; i++) {
            RTProperty *prop = [props objectAtIndex:i];
            
            [self setValue:[doc valueForKey:prop.name] forKey:prop.name];
        }
        
        self._v = doc._v;
        self._id = doc._id;
        return YES;
    }
    
    return NO;
}

+ (NSString *) getGuid
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}
@end
