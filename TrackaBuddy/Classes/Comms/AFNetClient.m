//
//  AFNetClient.m
//  MyApp
//
//  Created by Ping Ahn on 4/24/14.
//  Copyright (c) 2014 SoftAIC. All rights reserved.
//

#import "AFNetClient.h"

@implementation AFNetClient

+ (AFNetClient *)sharedClient
{
    static AFNetClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:WEATHER_BASE_URL]];
        
        // for only https call
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//        securityPolicy.allowInvalidCertificates = YES;
//        _sharedClient.securityPolicy = securityPolicy;
//        [_sharedClient.securityPolicy setAllowInvalidCertificates:YES]; // for only https call
        // set timeout
        [_sharedClient.requestSerializer setTimeoutInterval:30.0];
    });
    
    return _sharedClient;
}

- (void)presetClient
{
    // for only https call
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    self.securityPolicy = securityPolicy;
    [self.securityPolicy setAllowInvalidCertificates:YES]; // for only https call
    // set timeout
    [self.requestSerializer setTimeoutInterval:30.0];
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        //self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer = [JSONResponseSerializerWithData serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)setRequestSerializer:(NSUInteger)requestSerializerType ResponseSerializer:(NSUInteger)responseSerializerType
{
    if (requestSerializerType == AFNetClientRequestSerializerTypeJSON)
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    else if (requestSerializerType == AFNetClientRequestSerializerTypePLIST)
        self.requestSerializer = [AFPropertyListRequestSerializer serializer];
    
    if (responseSerializerType == AFNetClientResponseSerializerTypeJSON)
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    else if (responseSerializerType == AFNetClientResponseSerializerTypeXML)
        self.responseSerializer = [AFXMLParserResponseSerializer serializer];
    else if (responseSerializerType == AFNetClientResponseSerializerTypePLIST)
        self.responseSerializer = [AFPropertyListResponseSerializer serializer];
}

- (void)setRequestAuthHeaderWithUsername:(NSString *)username Password:(NSString *)password
{
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}

- (void)getResponseFromServerWithClientType:(NSUInteger)type URL:(NSString *)urlString Params:(NSDictionary *)params ActionCode:(NSUInteger)actionCode
{
    if (type == AFNetClientTypePOST) { // POST
        [self POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([self.delegate respondsToSelector:@selector(afnetClient:didSuccessWithResponse:ActionCode:)]) {
                [self.delegate afnetClient:self didSuccessWithResponse:responseObject ActionCode:actionCode];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(afnetClient:didFailWithError:ActionCode:)]) {
                [self.delegate afnetClient:self didFailWithError:error ActionCode:actionCode];
            }
        }];
    } else if (type == AFNetClientTypeGET) { // GET
        [self GET:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([self.delegate respondsToSelector:@selector(afnetClient:didSuccessWithResponse:ActionCode:)]) {
                [self.delegate afnetClient:self didSuccessWithResponse:responseObject ActionCode:actionCode];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(afnetClient:didFailWithError:ActionCode:)]) {
                [self.delegate afnetClient:self didFailWithError:error ActionCode:actionCode];
            }
        }];
    } else if (type == AFNetClientTypePUT) { // PUT
        [self PUT:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([self.delegate respondsToSelector:@selector(afnetClient:didSuccessWithResponse:ActionCode:)]) { 
                [self.delegate afnetClient:self didSuccessWithResponse:responseObject ActionCode:actionCode];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(afnetClient:didFailWithError:ActionCode:)]) {
                [self.delegate afnetClient:self didFailWithError:error ActionCode:actionCode];
            }
        }];
    }
}
@end