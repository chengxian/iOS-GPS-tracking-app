//
//  TrackList.h
//  TrackaBuddy
//
//  Created by Alexander on 16/10/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrackList : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSMutableArray * geoPointArray;
@property (nonatomic, retain) NSDate * endDateTime;
@property (nonatomic, retain) NSDate * startDatetime;
@property (nonatomic, retain) NSNumber * trafficMode;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * createdAt;

@end
