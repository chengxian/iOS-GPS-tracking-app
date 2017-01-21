//
//  NSDictionary+RemoveNullsWithStrings.h
//  CarIQ
//
//  Created by Ping Ahn on 9/12/14.
//  Copyright (c) 2014 Ping Ahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(RemoveNullsWithStrings)

- (NSDictionary *)dictionaryByReplacingNullsWithStrings;

@end
