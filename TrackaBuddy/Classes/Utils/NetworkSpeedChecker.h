//
//  NetworkSpeedChecker.h
//  TrackaBuddy
//
//  Created by Alexander on 15/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SpeedCheckerCompletion)(BOOL isOnline);

@protocol NetworkSpeedCheckerDelegate;

@interface NetworkSpeedChecker : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *     connection;
@property (nonatomic) NSInteger                     length;
@property (nonatomic, strong) NSDate *              startTime;
@property (nonatomic, assign) BOOL                  isOnline;

@property (nonatomic, strong) SpeedCheckerCompletion completionHandler;

@property (strong, nonatomic) id<NetworkSpeedCheckerDelegate> delegate;

- (void)determineNetworkStatus:(SpeedCheckerCompletion)handler;

@end

@protocol NetworkSpeedCheckerDelegate <NSObject>
@required

- (void)speedChecker:(NetworkSpeedChecker *)cheker didDecidedOnline:(BOOL)online;

@end

