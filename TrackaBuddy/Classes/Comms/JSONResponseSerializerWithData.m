//
//  JSONResponseSerializerWithData.m
//  CarIQ
//
//  Created by Ping Ahn on 9/11/14.
//  Copyright (c) 2014 Ping Ahn. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    if (*error != nil) {
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        if (data == nil) {
            // Note: You might want to convert data to a string here too, up to you.
            //userInfo[JSONResponseSerializerWithDataKey] = @"";
            userInfo[JSONResponseSerializerWithDataKey] = @{@"messages":@[]};
        } else {
            // Note: You might want to convert data to a string here too, up to you.
            //userInfo[JSONResponseSerializerWithDataKey] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (jsonError) {
                userInfo[JSONResponseSerializerWithDataKey] = @{@"messages":@[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]};
                //userInfo[JSONResponseSerializerWithDataKey] = @{@"messages":@[]};
            } else {
                userInfo[JSONResponseSerializerWithDataKey] = json;
            }
        } 
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    
    return  (JSONObject);
}

@end
