//
//  AFNetClient.h
//  MyApp
//
//  Created by Ping Ahn on 4/24/14.
//  Copyright (c) 2014 SoftAIC. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "JSONResponseSerializerWithData.h"
//#import "AFHTTPRequestOperationManager.h"

/**
 *  A constant describing the AFNetworking Request and Response Serializer type. 
    This sets the AFNetworking Request and Response Serializer.
 */
typedef NS_ENUM(NSUInteger, AFNetClientRequestSerializerType) {
    AFNetClientRequestSerializerTypeJSON,
    AFNetClientRequestSerializerTypePLIST
};
typedef NS_ENUM(NSUInteger, AFNetClientResponseSerializerType) {
    AFNetClientResponseSerializerTypeJSON,
    AFNetClientResponseSerializerTypeXML,
    AFNetClientResponseSerializerTypePLIST
};
typedef NS_ENUM(NSUInteger, AFNetClientType) {
    AFNetClientTypeGET,
    AFNetClientTypePOST,
    AFNetClientTypePUT
};


@protocol AFNetClientDelegate;

@interface AFNetClient : AFHTTPSessionManager
@property (nonatomic, weak) id<AFNetClientDelegate>delegate;

+ (AFNetClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)presetClient;
- (void)setRequestSerializer:(NSUInteger)requestSerializerType ResponseSerializer:(NSUInteger)responseSerializerType;

- (void)setRequestAuthHeaderWithUsername:(NSString *)username Password:(NSString *)password;
- (void)getResponseFromServerWithClientType:(NSUInteger)type URL:(NSString *)urlString Params:(NSDictionary *)params ActionCode:(NSUInteger)actionCode;
@end


@protocol AFNetClientDelegate <NSObject>
@optional
- (void)afnetClient:(AFNetClient *)client didSuccessWithResponse:(id)response ActionCode:(NSUInteger)actionCode;
- (void)afnetClient:(AFNetClient *)client didFailWithError:(NSError *)error ActionCode:(NSUInteger)actionCode;
@end
