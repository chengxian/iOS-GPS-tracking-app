//
//  BackgroundTaskManager.h
//  TrackaBuddy
//
//  Created by Alexander on 16/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

@interface BackgroundTaskManager : NSObject

+(instancetype)sharedBackgroundTaskManager;

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;
-(void)endAllBackgroundTasks;

@end
