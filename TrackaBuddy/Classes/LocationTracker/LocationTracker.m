//
//  LocationTracker.m
//  TrackaBuddy
//
//  Created by Alexander on 16/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "LocationTracker.h"
#import "GeoPoint.h"
#import "LocationCount.h"

@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
    static CLLocationManager *_locationManager;
    
    @synchronized(self) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        }
    }
    return _locationManager;
}

- (id)init {
    if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        _isBackgroundMode = NO;
        
        _appDelegate = [[UIApplication sharedApplication] delegate];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}

- (void)applicationEnterBackground
{
    NSLog(@"Application Enter Background Mode");
    
    _isBackgroundMode = YES;
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    if ([UserDataSingleton sharedSingleton].trackIsStarted)
        [locationManager startUpdatingLocation];

    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    self.shareModel.pauseLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                                target:self
                                                                              selector:@selector(pauseLocationUpdates)
                                                                              userInfo:nil
                                                                               repeats:YES];
    
    self.shareModel.backgroudJobTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(newBackgroundJob) userInfo:nil repeats:YES];
}

- (void)newBackgroundJob
{
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    NSLog(@"Time Remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining);
}


- (void)applicationEnterForeground {
    
    NSLog(@"Application comeback Foreground Mode");
    
    _isBackgroundMode = NO;
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    
    if ([UserDataSingleton sharedSingleton].trackIsStarted)
        [locationManager startUpdatingLocation];
    
    [self.shareModel.bgTask endAllBackgroundTasks];

    [self.shareModel.backgroudJobTimer invalidate];
    self.shareModel.backgroudJobTimer = nil;
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
   
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }

        _currTrackGeoPointArray = [UserDataSingleton sharedSingleton].currTrackGeoPointArray;

        _startPointInterval = 0;
        
        _conditionTrackPath = [GMSMutablePath path];
        
        _conditionBounds = [[GMSCoordinateBounds alloc] init];
        
        _getCorrectLocationCount = 0;
        _currentLocationCount = (LocationCount *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationCount" inManagedObjectContext:_appDelegate.managedObjectContext];
        [_currentLocationCount setUuid:[UserDataSingleton sharedSingleton].currTrackUUID];
        [_currentLocationCount setStart_date:[NSDate date]];

        _currTrackAccuracy = 100;
    }
    
    self.shareModel.getCorrectLocationTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                               target:self
                                               selector:@selector(getCorrectLocation)
                                               userInfo:nil
                                               repeats:YES];
    
    //temp code
    
    _temp1 = 37.23421;
    _temp2 = -112.12309098;
    
    //temp code
}

- (void)pauseLocationUpdates
{
    NSLog(@"pauseLocationUpdates");
    
    CLLocationManager * locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    [self performSelector:@selector(restartLocationUpdates) withObject:nil afterDelay:3.0f];
    
//    self.shareModel.restartLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:NO];
}

- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.backgroudJobTimer) {
        [self.shareModel.backgroudJobTimer invalidate];
        self.shareModel.backgroudJobTimer = nil;
    }
    
    if (self.shareModel.pauseLocationUpdateTimer) {
        [self.shareModel.pauseLocationUpdateTimer invalidate];
        self.shareModel.pauseLocationUpdateTimer = nil;
    }
    
    if (self.shareModel.getCorrectLocationTimer) {
        [self.shareModel.getCorrectLocationTimer invalidate];
        self.shareModel.getCorrectLocationTimer = nil;
    }
   
    _prevLocation = nil;
    
    _conditionBounds = nil;
    
    _conditionTrackPath = nil;

    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
//    NSLog(@"locationManager didUpdateLocations");
    
    for(int i = 0; i < locations.count; i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
//        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        
        if (newLocation.coordinate.latitude == 0 || newLocation.coordinate.longitude == 0) {
            return;
        }
        
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
//        CLLocationSpeed theSpeed = newLocation.speed;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }

        //Select only valid location and also location with good accuracy
//        if(newLocation != nil && theAccuracy > 0 && theAccuracy < _currTrackAccuracy &&(!(theLocation.latitude == 0.0 && theLocation.longitude == 0.0)))
        if(newLocation != nil && theAccuracy > 0 && theAccuracy < _currTrackAccuracy /* && theSpeed > 0 */ )
        {
            [self.shareModel.myLocationArray addObject:newLocation];
            _myLastLocation = newLocation;
            

//            _myLastLocationAccuracy = theAccuracy;
            
//            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
//            [dic setObject:[NSNumber numberWithDouble:newLocation.speed] forKey:@"speed"];
//            [dic setObject:[NSNumber numberWithDouble:theAccuracy] forKey:@"accuracy"];
//            [dic setObject:[UserDataSingleton sharedSingleton].currTrackUUID forKey:@"uuid"];
//            [dic setObject:[NSDate date] forKey:@"time"];
//            [[UserDataSingleton sharedSingleton].speedArray addObject:dic];
            
            //ShareModel Code
            //-----------------------------------------------------------------------------------------
            
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
//            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
//            
//            //Add the vallid location with good accuracy into an array
//            //Every 1 minute, I will select the best location based on accuracy and send to server
//            [self.shareModel.myLocationArray addObject:dict];
            
            //-----------------------------------------------------------------------------------------
            
            //Speed Calculate
//            double distanceMetres = [newLocation distanceFromLocation:_prevLocation];
//            NSTimeInterval tInterval = [newLocation.timestamp timeIntervalSinceDate:_prevLocation.timestamp];
//            
//            NSLog(@"nTimeInterval : %f", tInterval);
//            double tSpeed = distanceMetres / tInterval;
//            
//            PFObject * speed = [PFObject objectWithClassName:@"Speed"];
//            speed[@"speed"] =  [NSNumber numberWithDouble:tSpeed];
//            speed[@"accuracy"] = [NSNumber numberWithDouble:theAccuracy];
//            speed[@"time"] = [NSDate date];
//            speed[@"track"] =  [[UserDataSingleton sharedSingleton].trackArray lastObject];
//            [speed saveEventually];
            
            //Speed Calculate
        }
    }
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}

//Send the location to Server
- (void)getCorrectLocation {
//    NSLog(@"getCorrectLocation");
    
    // Find the best location from the array based on accuracy
//    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    CLLocation * myBestLocation;
    
    for(int i = 0; i < self.shareModel.myLocationArray.count; i++){
//        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        CLLocation * currentLocation = (CLLocation *)[self.shareModel.myLocationArray objectAtIndex:i];
        
        if(i == 0)
            myBestLocation = currentLocation;
        else
        {
            if(currentLocation.horizontalAccuracy <= myBestLocation.horizontalAccuracy)
                myBestLocation = currentLocation;
        }
    }

//    NSLog(@"My Best location:%@",myBestLocation);

    //If the array is 0, get the last location
    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
    if(self.shareModel.myLocationArray.count == 0)
    {
        NSLog(@"Unable to get location, use the last known location");
        
        self.myLocation = _myLastLocation;
        
        return;
    }
    else
    {
        self.myLocation = myBestLocation;
    }
    
    if (self.myLocation.speed <= 0) {
        [_delegate locationTracker:self didStayedLocation:self.myLocation];
        return;
    }
    
    if (_startPointInterval < START_POINT_INTERVAL) {
        _startPointInterval ++;
        return;
    }
   
//    CLLocation * newLocation = [[CLLocation alloc] initWithLatitude:_myLocation.latitude longitude:_myLocation.longitude];
    double distanceMetres = 1.0f;
    
    if (_prevLocation != nil) {
        distanceMetres = [self.myLocation distanceFromLocation:_prevLocation];
        
        if (distanceMetres > 6.0f) {
            
            if ([_conditionTrackPath count] >= CONDITION_REGION_COUNT) {
                [_conditionTrackPath removeCoordinateAtIndex:0];
            }
            else
            {
                if ([_conditionTrackPath count] > 1 && [_conditionTrackPath count] < CONDITION_REGION_COUNT) {
                    if ([_conditionBounds containsCoordinate:self.myLocation.coordinate]) {
                        [_conditionTrackPath addCoordinate:self.myLocation.coordinate];
                        _conditionBounds = [[GMSCoordinateBounds alloc] initWithPath:_conditionTrackPath];
                        return;
                    }
                    else
                    {
                        _totalDistance += distanceMetres;
                        
                        [UserDataSingleton sharedSingleton].currLocation = self.myLocation;
                        
                        GeoPoint * geoPoint = (GeoPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GeoPoint" inManagedObjectContext:_appDelegate.managedObjectContext];
                        [geoPoint setUuid:[UserDataSingleton sharedSingleton].currTrackUUID];
                        [geoPoint setLatitude:[NSNumber numberWithDouble:self.myLocation.coordinate.latitude]];
                        [geoPoint setLongitude:[NSNumber numberWithDouble:self.myLocation.coordinate.longitude]];
                        [geoPoint setCreatedAt:[NSDate date]];
                        
                        NSError * error = nil;
                        if (![_appDelegate.managedObjectContext save:&error]) {
                            NSLog(@"CoreData Save Error: %@", error.description);
                            return;
                        }

                        NSMutableArray * point = [[NSMutableArray alloc] initWithCapacity:2];
                        [point addObject:[NSNumber numberWithDouble:self.myLocation.coordinate.latitude]];
                        [point addObject:[NSNumber numberWithDouble:self.myLocation.coordinate.longitude]];
                        [_currTrackGeoPointArray addObject:point];
                        
                        [_delegate locationTracker:self didUpdatedLocations:self.myLocation];
                        _prevLocation = self.myLocation;
                    }
                }
                [_conditionTrackPath addCoordinate:self.myLocation.coordinate];
                _conditionBounds = [[GMSCoordinateBounds alloc] initWithPath:_conditionTrackPath];
            }
        }
    }
    else
    {
        _prevLocation = self.myLocation;
        
        NSLog(@"PrevLocation Nil");
        
        [UserDataSingleton sharedSingleton].currLocation = self.myLocation;
        
        GeoPoint * geoPoint = (GeoPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GeoPoint" inManagedObjectContext:_appDelegate.managedObjectContext];
        [geoPoint setUuid:[UserDataSingleton sharedSingleton].currTrackUUID];
        [geoPoint setLatitude:[NSNumber numberWithDouble:self.myLocation.coordinate.latitude]];
        [geoPoint setLongitude:[NSNumber numberWithDouble:self.myLocation.coordinate.longitude]];
        [geoPoint setCreatedAt:[NSDate date]];
        
        NSError * error = nil;
        if (![_appDelegate.managedObjectContext save:&error]) {
            NSLog(@"CoreData Save Error: %@", error.description);
        }
        
        NSMutableArray * point = [[NSMutableArray alloc] initWithCapacity:2];
        [point addObject:[NSNumber numberWithDouble:self.myLocation.coordinate.latitude]];
        [point addObject:[NSNumber numberWithDouble:self.myLocation.coordinate.longitude]];
        [_currTrackGeoPointArray addObject:point];
        
        [_delegate locationTracker:self didUpdatedLocations:self.myLocation];
    }

    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}

- (void)saveCurrentLocationGetCount
{
//    LocationCount * locationCount = (LocationCount *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationCount" inManagedObjectContext:_appDelegate.managedObjectContext];
    [_currentLocationCount setCount:[NSNumber numberWithInteger:_getCorrectLocationCount]];
    
    NSError * error = nil;
    if (![_appDelegate.managedObjectContext save:&error]) {
        NSLog(@"CoreData Save Error: %@", error.description);
    }
}

- (void)getCorrectLocation1
{
    
    NSLog(@"getCorrectLocation1");
    
    CLLocation * newLocation = [[CLLocation alloc] initWithLatitude:_temp1 longitude:_temp2];

    NSMutableArray * point = [[NSMutableArray alloc] initWithCapacity:2];
    [point addObject:[NSNumber numberWithDouble:newLocation.coordinate.latitude]];
    [point addObject:[NSNumber numberWithDouble:newLocation.coordinate.longitude]];
    
    [_tempGeoPointArray addObject:point];

    if ([_tempGeoPointArray count] >= 20 && _isSaved ) {
        //save to local
        
        NSLog(@"savePin");
        
        NSMutableArray * localArray = [[NSMutableArray alloc] initWithArray:_tempGeoPointArray];
        [_tempGeoPointArray removeAllObjects];
        _isSaved = NO;
        
        PFObject * currTrack = [UserDataSingleton sharedSingleton].currTrack;
        NSString * uuidStr = currTrack[@"uuid"];
        
        PFQuery * query = [PFQuery queryWithClassName:PARSE_CLASS_TRACKLIST];
        [query fromLocalDatastore];
        [query whereKey:@"uuid" equalTo:uuidStr];

        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                [object[@"geo_point_array"] addObjectsFromArray:localArray];
//                [object saveEventually];
                
                _isSaved = YES;
                
//                NSMutableArray * testArray = object[@"geo_point_array"];
//                NSLog(@"testArray count : %ld", (long)[testArray count]);
            }
        }];
    }
    [_currTrackPath addLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [_delegate locationTracker:self didUpdatedLocations:newLocation];

    _temp1 += 0.0001;
    _temp2 += 0.0001;

}

- (void)getCorrectLocation2
{
    
    NSLog(@"getCorrectLocation2");
    
    CLLocation * newLocation = [[CLLocation alloc] initWithLatitude:_temp1 longitude:_temp2];
    
//    GeoPoint * geoPoint = (GeoPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GeoPoint" inManagedObjectContext:[UserDataSingleton sharedSingleton].sharedManagedObjectContext];
    
    if (_startPointInterval < START_POINT_INTERVAL) {
        _startPointInterval ++;
        return;
    }
    
    //crash code
//        NSMutableArray * array = [[NSMutableArray alloc] init];
//    
//    
//        for (int i = 0; i < 10; i++) {
//            [array addObject:[NSNumber numberWithInt:i]];
//        }
//    
//        [array removeObjectAtIndex:11];
    //crash code

    
    GeoPoint * geoPoint = (GeoPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"GeoPoint" inManagedObjectContext:_appDelegate.managedObjectContext];
    
    [geoPoint setUuid:[UserDataSingleton sharedSingleton].currTrackUUID];
    [geoPoint setLatitude:[NSNumber numberWithDouble:newLocation.coordinate.latitude]];
    [geoPoint setLongitude:[NSNumber numberWithDouble:newLocation.coordinate.longitude]];
    [geoPoint setCreatedAt:[NSDate date]];
    
    NSError * error = nil;
    if (![_appDelegate.managedObjectContext save:&error]) {
        NSLog(@"CoreData Save Error: %@", error.description);
    }
    
    [_currTrackPath addLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [_delegate locationTracker:self didUpdatedLocations:newLocation];
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    if (_isBackgroundMode) {
        [self.shareModel.bgTask beginNewBackgroundTask];
    }
    
    _temp1 += 0.0001;
    _temp2 += 0.0001;
    
}

- (void)updateLocationToServer
{
    
}



@end
