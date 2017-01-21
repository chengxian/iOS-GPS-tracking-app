//
//  NSDictionary+RemoveNullsWithStrings.m
//  CarIQ
//
//  Created by Ping Ahn on 9/12/14.
//  Copyright (c) 2014 Ping Ahn. All rights reserved.
//

#import "NSDictionary+RemoveNullsWithStrings.h"

@implementation NSDictionary(RemoveNullsWithStrings)

- (NSDictionary *)dictionaryByReplacingNullsWithStrings
{
    const NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for (NSString *key in self.allKeys) {
        const id object = [self objectForKey:key];
        if (object == nul) {
            [replaced setObject:blank forKey:key];
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            [replaced setObject:[(NSDictionary *)object dictionaryByReplacingNullsWithStrings] forKey:key];
        } else if ([object isKindOfClass:[NSArray class]]) {
            
        }
    }
    return [NSDictionary dictionaryWithDictionary:[replaced copy]];
}

@end
