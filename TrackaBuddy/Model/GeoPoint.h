//
//  GeoPoint.h
//  TrackaBuddy
//
//  Created by Alexander on 21/08/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GeoPoint : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * uuid;

@end
