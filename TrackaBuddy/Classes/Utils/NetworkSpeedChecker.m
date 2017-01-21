//
//  NetworkSpeedChecker.m
//  TrackaBuddy
//
//  Created by Alexander on 15/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "NetworkSpeedChecker.h"

@implementation NetworkSpeedChecker{
}

- (void)determineNetworkStatus:(SpeedCheckerCompletion)handler
{
    self.completionHandler = handler;
    
    NSURL * url = [NSURL URLWithString:@"https://developer.apple.com/"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    self.startTime = [NSDate date];
    self.length = 0;
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.connection) {
            [self.connection cancel];
            self.connection = nil;
            if (self.completionHandler != nil) {
                self.completionHandler(NO);
            }
        }
    });
}

- (CGFloat)determineMegabytesPerSecond
{
    NSTimeInterval elapsed;
    
    if (self.startTime) {
        elapsed = [[NSDate date] timeIntervalSinceDate:self.startTime];
        
        NSLog(@"Download Speed : %f", self.length / elapsed / 1024);
        
        return  self.length / elapsed / 1024;
    }
    
    return -1;
}

#pragma mark - NSURLConnectionDelegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.startTime = [NSDate date];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.connection) {
        self.connection = nil;
        
        if( self.delegate != nil )
            [self.delegate speedChecker:self didDecidedOnline:NO];
        
        if( self.completionHandler != nil )
            self.completionHandler(NO);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    
    if ([self determineMegabytesPerSecond] >= MIN_DOWNLOAD_QTY_PER_SEC) {

        if( self.delegate != nil )
            [self.delegate speedChecker:self didDecidedOnline:YES];
        
        if( self.completionHandler != nil )
            self.completionHandler(YES);
    }
    else
    {
        if( self.delegate != nil )
            [self.delegate speedChecker:self didDecidedOnline:NO];
        
        if( self.completionHandler != nil )
            self.completionHandler(NO);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.length += [data length];
}

@end
