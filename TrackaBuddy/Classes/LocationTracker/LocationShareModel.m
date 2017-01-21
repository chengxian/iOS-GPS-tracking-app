//
//  LocationShareModel.m
//  TrackaBuddy
//
//  Created by Alexander on 16/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "LocationShareModel.h"

@implementation LocationShareModel

//Class method to make sure the share model is synch across the app
+ (id)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}


@end