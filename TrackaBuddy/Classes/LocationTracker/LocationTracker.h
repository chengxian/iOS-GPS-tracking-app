//
//  LocationTracker.h
//  TrackaBuddy
//
//  Created by Alexander on 16/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "LocationShareModel.h"
#import "LocationCount.h"

@protocol LocationTrackerDelegate;

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

//@property (nonatomic) CLLocationCoordinate2D        myLastLocation;
@property (nonatomic, strong) CLLocation *          myLastLocation;
@property (nonatomic) CLLocationAccuracy            myLastLocationAccuracy;
//@property (nonatomic) CLLocationAccuracy            maxLocationAccuracy;

@property (strong,nonatomic) LocationShareModel *   shareModel;

//@property (nonatomic) CLLocationCoordinate2D        myLocation;
@property (nonatomic, strong) CLLocation *          myLocation;
//@property (nonatomic) CLLocationAccuracy            myLocationAccuracy;

@property (nonatomic, assign) BOOL                  isBackgroundMode;

@property (strong, nonatomic) CLLocation *          prevLocation;
@property (strong, nonatomic) GMSMutablePath *      currTrackPath;
@property (strong, nonatomic) GMSMutablePath *      conditionTrackPath;
@property (strong, nonatomic) GMSCoordinateBounds * conditionBounds;
@property (strong, nonatomic) NSMutableArray *      currTrackGeoPointArray;
@property (assign, nonatomic) NSInteger             updateInterval;
@property (strong, nonatomic) NSMutableArray *      tempGeoPointArray;
@property (assign, nonatomic) BOOL                  isSaved;

@property (assign, nonatomic) NSInteger             uploadInterval;
@property (assign, nonatomic) CGFloat               totalDistance;

@property (assign, nonatomic) NSInteger             startPointInterval;
@property (assign, nonatomic) NSInteger             currTrackAccuracy;

@property (nonatomic, strong) id<LocationTrackerDelegate> delegate;

@property (strong, nonatomic) AppDelegate *         appDelegate;

@property (assign, nonatomic) double                temp1;
@property (assign, nonatomic) double                temp2;

@property (assign, nonatomic) NSInteger             getCorrectLocationCount;
@property (strong, nonatomic) LocationCount *       currentLocationCount;

+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;


@end

@protocol LocationTrackerDelegate <NSObject>
@required
- (void)locationTracker:(LocationTracker *)tracker didUpdatedLocations:(CLLocation *)lastLocation;

- (void)locationTracker:(LocationTracker *)tracker didStayedLocation:(CLLocation *)stayedLocation;
@end
