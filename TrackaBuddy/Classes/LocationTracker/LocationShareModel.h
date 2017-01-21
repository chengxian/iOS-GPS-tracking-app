//
//  LocationShareModel.h
//  TrackaBuddy
//
//  Created by Alexander on 16/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "BackgroundTaskManager.h"

@interface LocationShareModel : NSObject

@property (strong, nonatomic) NSTimer * backgroudJobTimer;
@property (strong, nonatomic) NSTimer * pauseLocationUpdateTimer;
@property (strong, nonatomic) NSTimer * restartLocationUpdateTimer;
@property (strong, nonatomic) NSTimer * getCorrectLocationTimer;

//@property (strong, nonatomic) NSTimer *timer;
//@property (strong, nonatomic) NSTimer * serverUpdateTimer;

//@property (strong, nonatomic) NSTimer * delay10Seconds;
@property (strong, nonatomic) BackgroundTaskManager * bgTask;
@property (strong, nonatomic) NSMutableArray *myLocationArray;

+(id)sharedModel;

@end
