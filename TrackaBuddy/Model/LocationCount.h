//
//  LocationCount.h
//  TrackaBuddy
//
//  Created by Alexander on 27/08/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocationCount : NSManagedObject

@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * uuid;

@end
