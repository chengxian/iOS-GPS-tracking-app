//
//  TrackViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 10/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "TrackViewController.h"


@implementation TrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Gesture And Share Button Setting(Facebook, Twitter, like as ActionSheet)
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Gesture, Share Button Setting
    
    _shareButtonContainer.layer.cornerRadius = 5;
    _btnShareFacebook.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _btnShareFacebook.layer.borderWidth = 1;
    _btnShareTwitter.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _btnShareTwitter.layer.borderWidth = 1;
    _btnShareCancel.layer.cornerRadius = 5;
    
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSocialShareButton)];
    [_shareContainerView addGestureRecognizer:tapRecognizer];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Gesture, Share Button Setting
    
    //Map Setting
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Map Setting
    
    _mapView.mapType = (MKMapType)[[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"map_type"] integerValue];
    
    [self resetMapViewWithCurrentLocation:nil];
  
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Map Setting
    
    // Location Service Setting
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Location Service Setting
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Please enable location services");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Location Service Setting
    
    // Setup LocationTracker
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Setup LocationTracker
    
    _currLocationTracker = [UserDataSingleton sharedSingleton].currLocationTracker;
    if (_currLocationTracker == nil )
    {
        [UserDataSingleton sharedSingleton].currLocationTracker = [[LocationTracker alloc] init];
        _currLocationTracker = [UserDataSingleton sharedSingleton].currLocationTracker;
    }
   
    _currTrackGeoPointArray = [UserDataSingleton sharedSingleton].currTrackGeoPointArray;
    
    _currPinArray = [UserDataSingleton sharedSingleton].currPinArray;
    
    _currTrack = [[UserDataSingleton sharedSingleton].trackArray lastObject];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Setup LocationTracker
    
    //Setup ALAssetsLibrary
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Setup ALAssetsLibrary
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Setup ALAssetsLibrary
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnEndTripPressed:) name:END_TRIP_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEnterBackgroudNotification) name:NOTIFICATION_ENTER_BACKGROUND object:nil];
}

- (void)didReceiveEnterBackgroudNotification
{
    NSLog(@"didReceiveEnterBackgroudNotification");
    
    [self.navigationController dismissMoviePlayerViewControllerAnimated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    _currLocationTracker.delegate = self;
    
    if ([UserDataSingleton sharedSingleton].trackisStartable) {
        [self StartTrack];
    }
    
    if ([UserDataSingleton sharedSingleton].currTrackTitle != nil && ![[UserDataSingleton sharedSingleton].currTrackTitle isEqualToString:@""])
    {
        _currTrack[@"name"] = [NSString stringWithFormat:@"%@", [UserDataSingleton sharedSingleton].currTrackTitle];
    }
    
//    if ([[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_enable"] boolValue])
//    {
        [self showTrackPath];
        [self dropAllPins];
//    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    //Release Self from Current LocationTracker Delegate
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Release Self
    
    _currLocationTracker.delegate = nil;
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Release Self
    
    //Invalidate the Timer(for Current DateTime Update)
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Invalidate Timer
    
    [_selfTimer invalidate];
    _selfTimer = nil;
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Invalidate Timer
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)resetMapViewWithCurrentLocation:(CLLocation *)location
{
    CLLocation * currLocation = [LocationTracker sharedLocationManager].location;
    float latitude, longitude;
    latitude = currLocation.coordinate.latitude;
    longitude = currLocation.coordinate.longitude;
    
    if ([UserDataSingleton sharedSingleton].currMapZoomLevel > 15) {
        [UserDataSingleton sharedSingleton].currMapZoomLevel = 15;
    }
    
    CLLocationCoordinate2D currLocationCoordinate = currLocation.coordinate;
    MKCoordinateRegion region = {currLocationCoordinate, [UserDataSingleton sharedSingleton].currMapSpan};
    
    [_mapView setRegion:region];
}

#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        static NSString *identifier = @"currentLocation";
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(pulsingView == nil) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0 green:0 blue:0.678431 alpha:1];
            pulsingView.canShowCallout = YES;
        }
        
        return pulsingView;
    }
    else if ([annotation isKindOfClass:[PinAnnotation class]])
    {
        PinAnnotation * pin = (PinAnnotation *)annotation;
        static NSString * identifier = @"pinAnnotation";
        PinAnnotationView * pinView = (PinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (pinView == nil) {
            pinView = [[PinAnnotationView alloc] initWithAnnotation:pin reuseIdentifier:identifier];
        }
//        pinView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_marker", pin.type]];
        if ([pin.type isEqualToString:@"start"] || [pin.type isEqualToString:@"end"]) {
            pinView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_marker", pin.type]];
        }
        else
            pinView.image = [UIImage imageNamed:@"pin"];

        pinView.type = pin.type;
        pinView.urlString = pin.urlString;
        
        pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPin:)];
        [pinView addGestureRecognizer:tapGesture];
        
        return pinView;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer * renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 3.0f;
    renderer.strokeColor = [UIColor blueColor];
    return renderer;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [UserDataSingleton sharedSingleton].currMapSpan = mapView.region.span;
}

#pragma mark - MKMapView AnnotationView Tap Methods

- (void)didTapPin:(UITapGestureRecognizer *)sender {
    PinAnnotationView * pinView = (PinAnnotationView *)sender.view;
    if ([pinView.type  isEqual:@"pic"]) {
        [self performSegueWithIdentifier:@"showEditPhotoView" sender:pinView];
    }
    else if ([pinView.type isEqual:@"video"])
    {
        NSString * urlString = pinView.urlString;
        MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
        [playerVC.moviePlayer setShouldAutoplay:NO];
        
        [[NSNotificationCenter defaultCenter] removeObserver:playerVC
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:playerVC.moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:playerVC.moviePlayer];
        
        playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentMoviePlayerViewControllerAnimated:playerVC];
    }
    else if([pinView.type isEqual:@"note"])
    {
        [self performSegueWithIdentifier:@"showAddNotesView1" sender:nil];
    }
}


#pragma mark - Navigation Methods

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [_mapView removeAnnotation:_stayedAnnotation];
    _stayedAnnotation = nil;

    if ([[segue identifier] isEqualToString:@"showEditPhotoView"])
    {
        NSString * urlString = ((PinAnnotationView *)sender).urlString;
        EditPhotoViewController * vc = [segue destinationViewController];
        [vc setPhotoFromAssets:urlString];
//        vc.isPortrateImage = NO;
    }
    else if ([[segue identifier] isEqualToString:@"showAddNotesView1"])
    {
        AddNotesViewController * vc = [segue destinationViewController];
        [vc setReview:NO];
    }
    else if ([[segue identifier] isEqualToString:@"showTrackOverviewController"])
    {
        TrackOverViewController * vc = [segue destinationViewController];
        
        // Take screenshot
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
        
        [_mapView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = [image applyBlurWithRadius:2.0
                                 tintColor:[UIColor colorWithWhite:0 alpha:0.4]
                     saturationDeltaFactor:.5
                                 maskImage:nil
                                   atFrame:(CGRect){{0, 0}, image.size}];
        [vc setBlurredImage:image];
        
        // Get OverviewData
        NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
        [data setValue:[NSNumber numberWithFloat:4.5] forKey:@"elevation"];
        [data setValue:[NSNumber numberWithFloat:_currLocationTracker.totalDistance] forKey:@"distance"];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm aaa"];
        NSString * startTime = [formatter stringFromDate:[UserDataSingleton sharedSingleton].currTrackStartDateTime];
        NSString * duration = [DateUtils getDiffTimeFromDate:[UserDataSingleton sharedSingleton].currTrackStartDateTime];
        
        [data setValue:startTime forKey:@"starttime"];
        [data setValue:duration forKey:@"duration"];
        [data setValue:[NSNumber numberWithFloat:65] forKey:@"heartrate"];
        [data setValue:[NSNumber numberWithFloat:23] forKey:@"temp"];
        
        [vc setTrackOverviewData:data];
    }
    
}


#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnBackPressed:(id)sender {
    [self showRootView];
}

- (void)showRootView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)btnEndTripPressed:(id)sender {
    NSLog(@"btnEndTripPressed");
    
    [self EndTrack];
}


//btnSharePressed
//-------------------------------------------------------------------------------------------------------------------------------------------------------# btnSharePressed

- (IBAction)btnSharePressed:(id)sender {
    if ([sender tag] == 1) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [fbPostSheet setInitialText:@"This is a Facebook post!"];
            [fbPostSheet setCompletionHandler:^(SLComposeViewControllerResult result)
            {
                if (result == SLComposeViewControllerResultCancelled) {
                    NSLog(@"The user cancelled");
                }
                else if (result == SLComposeViewControllerResultDone)
                {
                    NSLog(@"The user posted to Facebook");
                }
            }];
            [self presentViewController:fbPostSheet animated:YES completion:nil];
        } else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"You can't post right now, make sure your device has an internet connection and you have at least one facebook account setup"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if ([sender tag] == 2)
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"This is a tweet!"];
            [self presentViewController:tweetSheet animated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if ([sender tag] == 3)
    {
    }
    NSLog(@"btnSharePressed");
    [self showSocialShareButton];
}

- (IBAction)btnCameraPressed:(id)sender {

    if (![self isPostAvailable]) {
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR
    [self performSegueWithIdentifier:@"showGalleryViewController1" sender:nil];
#else
    [self performSegueWithIdentifier:@"showMediaCaptureController" sender:nil];
#endif
    
}

- (IBAction)btnAddPressed:(id)sender {

//    if (![self isPostAvailable]) {
//        return;
//    }

    [UserDataSingleton sharedSingleton].currSocialGeoPoint = [PFGeoPoint geoPointWithLocation:[UserDataSingleton sharedSingleton].currLocation];
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"Edit Trip name", @"Add notes", nil];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select One"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.tag = 3;
    for (NSString *title in array) {
        [actionSheet addButtonWithTitle:title];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self.view];
}

- (IBAction)btnOverviewPressed:(id)sender {
    [_mapView removeAnnotation:_stayedAnnotation];
    _stayedAnnotation = nil;

    [self performSegueWithIdentifier:@"showTrackOverviewController" sender:nil];
}

- (IBAction)btnSettingPressed:(id)sender {
    [self performSegueWithIdentifier:@"showSettingViewFromTrackView" sender:nil];
}

- (BOOL)isPostAvailable
{
    //temp code
//    [UserDataSingleton sharedSingleton].currLocation = [[CLLocation alloc] initWithLatitude:34.0222236084 longitude:-118.8082986978];
    //temp code
    
    [UserDataSingleton sharedSingleton].currSocialGeoPoint = [PFGeoPoint geoPointWithLocation:[UserDataSingleton sharedSingleton].currLocation];
    
    if (![UserDataSingleton sharedSingleton].trackIsStarted) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"You can post the photo in tracking"];
        return NO;
    }

    if ([UserDataSingleton sharedSingleton].currLocation.coordinate.latitude == 0 || [UserDataSingleton sharedSingleton].currLocation.coordinate.longitude == 0) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Cannot get Geo point"];
        return NO;
    }

    return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## btnSharePressed


//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions


#pragma mark - UIActionSheet Delegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 3 && buttonIndex == 0)
    {
        [self performSegueWithIdentifier:@"showEditTripNameView" sender:nil];
    }
    else if (actionSheet.tag == 3 && buttonIndex == 1)
    {
        if (![self isPostAvailable]) {
            return;
        }

        [self performSegueWithIdentifier:@"showAddNotesView" sender:nil];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ UIActionSheet Delegate


#pragma mark - EditTripNameViewController Delegate
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ EditTripNameViewController Delegate

- (void)didSaveTripName:(BOOL)saved
{
    if (saved) {
        //Show Track Title
        //-------------------------------------------------------------------------------------------------------------------------------------------------------Show Track Title
        
        if ( [UserDataSingleton sharedSingleton].currTrackTitle != nil && ![[UserDataSingleton sharedSingleton].currTrackTitle isEqualToString:@""])
        {
            _currTrack[@"name"] = [NSString stringWithFormat:@"%@", [UserDataSingleton sharedSingleton].currTrackTitle];
        }
        
        //-------------------------------------------------------------------------------------------------------------------------------------------------------Show Track Title
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ EditTripNameViewController Delegate

#pragma mark - ImageFilterViewController Delegate Method
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ ImageFilterViewController Delegate

- (void)imageFilterController:(ImageFilterViewController *)imageFilterController didPictureSaved:(BOOL)saved mediaURL:(NSString *)mediaURL
{
    if (saved) {
        CLLocation * location = [[CLLocation alloc] initWithLatitude:[UserDataSingleton sharedSingleton].currSocialGeoPoint.latitude longitude:[UserDataSingleton sharedSingleton].currSocialGeoPoint.longitude];
        [self dropPin:location type:@"pic" mediaURL:mediaURL];
        
        NSLog(@"mediaURL : %@", mediaURL);
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ ImageFilterViewController Delegate

#pragma mark - MediaReviewController Delegate Method
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ MediaReviewController Delegate

- (void)mediaReviewController:(MediaReviewController *)mediaReviewController didVideoSaved:(BOOL)saved mediaURL:(NSString *)mediaURL
{
    if (saved) {
        CLLocation * location = [[CLLocation alloc] initWithLatitude:[UserDataSingleton sharedSingleton].currSocialGeoPoint.latitude longitude:[UserDataSingleton sharedSingleton].currSocialGeoPoint.longitude];
        [self dropPin:location type:@"video" mediaURL:mediaURL];
        
        NSLog(@"mediaURL : %@", mediaURL);                                                                                                                                                                                                                
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ MediaReviewController Delegate

#pragma mark - AddNotesViewController Delegate Method
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ AddNotesViewController Delegate

- (void)addNotesController:(AddNotesViewController *)addNotesController didNoteSaved:(BOOL)saved
{
    if (saved) {
        CLLocation * location = [[CLLocation alloc] initWithLatitude:[UserDataSingleton sharedSingleton].currSocialGeoPoint.latitude longitude:[UserDataSingleton sharedSingleton].currSocialGeoPoint.longitude];
        [self dropPin:location type:@"note" mediaURL:nil];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ AddNotesViewController Delegate


#pragma mark - LocationTracker Delegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ LocatinTracker Delegate

- (void)locationTracker:(LocationTracker *)tracker didUpdatedLocations:(CLLocation *)lastLocation
{
    if (_currLocationTracker.isBackgroundMode) {
        return;
    }
    
    [self setCurrentLocationPin:lastLocation.coordinate];

//    NSLog(@"Current Location: Latitude(%f) Longitude(%f)",lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
   
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:lastLocation.latitude longitude:lastLocation.longitude];
    
//    [_mapView removeAnnotation:_stayedAnnotation];

    if (_isStartTrack) {
        MKCoordinateRegion region = {lastLocation.coordinate, [UserDataSingleton sharedSingleton].currMapSpan};
        [_mapView setRegion:region];
        
        //temp code
        
        PFObject * hackObject = [PFObject objectWithClassName:@"Hack"];
        hackObject[@"status"] = [NSNumber numberWithInteger:1];
        hackObject[@"user"] = [PFUser currentUser];
        hackObject[@"current_version"] = [UserDataSingleton sharedSingleton].currAppVersion;
        if ([UserDataSingleton sharedSingleton].isNetworkAble) {
            [hackObject saveInBackground];
        }
        else
            [hackObject saveEventually];
        
        //temp code
        
        [self dropPin:lastLocation type:MARKER_TYPE[MARKER_START] mediaURL:nil];
        
        //Get Current Address
        //--------------------------------------------------------------------------------------------------------------
        
        if ([UserDataSingleton sharedSingleton].isNetworkAble) {
            CLGeocoder * geoCorder = [[CLGeocoder alloc] init];
            [geoCorder reverseGeocodeLocation:lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                //                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                if (error == nil && [placemarks count] > 0) {
                    CLPlacemark *placemark = [placemarks lastObject];
                    [UserDataSingleton sharedSingleton].currTrackAddress = [NSString stringWithFormat:@"%@ %@, %@", placemark.locality, placemark.administrativeArea, placemark.ISOcountryCode];
                    _currTrack[@"address"] = [UserDataSingleton sharedSingleton].currTrackAddress;
                } else {
                    NSLog(@"%@", error.debugDescription);
                }
            }];
        }
        _isStartTrack = NO;
        //--------------------------------------------------------------------------------------------------------------
    }
    else
    {
        if ([_currTrackGeoPointArray count] <= 1) {
            return;
        }

        [self showTrackPath];
    }
}

- (void)locationTracker:(LocationTracker *)tracker didStayedLocation:(CLLocation *)stayedLocation
{
    if (!_stayedAnnotation) {
        _stayedAnnotation = [[SVAnnotation alloc] init];
        [self.mapView addAnnotation:_stayedAnnotation];
    }
    _stayedAnnotation.coordinate = stayedLocation.coordinate;
    
    [self showTrackPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ LocatinTracker Delegate

#pragma mark- AFNetClient Delegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ AFNetClient Delegate

- (void)afnetClient:(AFNetClient *)client didSuccessWithResponse:(id)response ActionCode:(NSUInteger)actionCode
{
    if (response == nil) return;
    
    if (actionCode == ActionTypeGetWeatherCondition && _isStartTrack) {
        NSDictionary *dict = (NSDictionary *)response;
        dict = [dict dictionaryByReplacingNullsWithStrings];
        
        if (dict != nil) {
            NSDictionary * dic = dict[@"current_observation"];
            NSString * weatherStr = [dic objectForKey:@"weather"];
            NSString * fullAddress = [dic[@"display_location"] objectForKey:@"full"];
            _currTrack[@"address"] = fullAddress;
            _currTrack[@"weather"] = weatherStr;
            if ([[UserDataSingleton sharedSingleton].currTrackTitle isEqualToString:@""]) {
                _currTrack[@"name"] = weatherStr;
            }
            
            [[UserDataSingleton sharedSingleton] saveCurrentTrack:^(BOOL finished, NSError *error) {
                if (finished) {
                    _isAbleTrack = YES;
                    [UserDataSingleton sharedSingleton].trackIsStarted = YES;
                    NSLog(@"Success Start Track");
                    _isStartTrack = NO;
                }
                else
                {
                    [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't start track, Please check your network connection"];
                    [_currLocationTracker stopLocationTracking];
                    _isAbleTrack = NO;
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }
}

- (void)afnetClient:(AFNetClient *)client didFailWithError:(NSError *)error ActionCode:(NSUInteger)actionCode
{
    NSLog(@"Error : %@", error.description);
    [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't Start Track. Please retry!"];
    [_currLocationTracker stopLocationTracking];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ AFNetClient Delegate

#pragma mark - Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Methods

// StartTrack
//-------------------------------------------------------------------------------------------------------------------------------------------------------# StartTrack
- (void) StartTrack
{    
    BOOL isEnableTrack = [[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_enable"] boolValue];
    
    if (!isEnableTrack) {
        CLLocation * currLocation = [LocationTracker sharedLocationManager].location;
        float latitude, longitude;
        latitude = currLocation.coordinate.latitude;
        longitude = currLocation.coordinate.longitude;
        
        if ([UserDataSingleton sharedSingleton].currMapZoomLevel > 15) {
            [UserDataSingleton sharedSingleton].currMapZoomLevel = 15;
        }

        return;
    }
    
    if([UserDataSingleton sharedSingleton].trackIsStarted)
    {
        _isStartTrack = NO;
        
        [self dropAllPins];
        return;
    }
    
    //Setting New Track Information
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Setting New Track Information
    
    [UserDataSingleton sharedSingleton].currTrackUUID = [[UserDataSingleton sharedSingleton] getUUIDString];
    
    PFObject * currTrack = [PFObject objectWithClassName:PARSE_CLASS_TRACKLIST];
    [[UserDataSingleton sharedSingleton].trackArray addObject:currTrack];
    
    [UserDataSingleton sharedSingleton].currTrackStartDateTime = [NSDate date];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Setting New Track Information

    _isStartTrack = YES;
    
    if (_currPinArray) {
        [_currPinArray removeAllObjects];
    }
    else
    {
        [UserDataSingleton sharedSingleton].currPinArray = [[NSMutableArray alloc] init];
        _currPinArray = [UserDataSingleton sharedSingleton].currPinArray;
    }
    
    if (_currTrackGeoPointArray) {
        [_currTrackGeoPointArray removeAllObjects];
    }
    else
    {
        [UserDataSingleton sharedSingleton].currTrackGeoPointArray = [[NSMutableArray alloc] init];
        _currTrackGeoPointArray = [UserDataSingleton sharedSingleton].currTrackGeoPointArray;
    }
    
    _isAbleTrack = YES;
    [UserDataSingleton sharedSingleton].trackIsStarted = YES;
    
    _currLocationTracker.totalDistance = 0.0f;
    
    NSLog(@"Success Start Track");
    
    //Start Location Tracking
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Start Location Tracking
   
    [_currLocationTracker startLocationTracking];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Start Location Tracking
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## StartTrack

// EndTrack
//-------------------------------------------------------------------------------------------------------------------------------------------------------# EndTrack

- (void) EndTrack
{
    if (![UserDataSingleton sharedSingleton].trackIsStarted) {
        return;
    }
    
    if ( [UserDataSingleton sharedSingleton].currTrackTitle == nil || [[UserDataSingleton sharedSingleton].currTrackTitle isEqualToString:@""]) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Please insert trip name"];
        return;
    }
    
//    if ([_currTrackPath count] < 2) {
//        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Incorrect track path"];
//        return;
//    }
    
    [_mapView removeAnnotation:_stayedAnnotation];
    
    //Drop EndPin
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Drop EndPin
    
   
    NSMutableArray * endPoint = [_currTrackGeoPointArray lastObject];
    CLLocationCoordinate2D currLocation = CLLocationCoordinate2DMake([endPoint[0] doubleValue], [endPoint[1] doubleValue]);
    CLLocation * location = [[CLLocation alloc] initWithLatitude:currLocation.latitude longitude:currLocation.longitude];
    [self dropPin:location type:MARKER_TYPE[MARKER_END] mediaURL:nil];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Drop EndPin
    
    //End Time Setting and Send Current Track Data to Parse.com
    //-------------------------------------------------------------------------------------------------------------------------------------------------------End Time Setting and Save
    
    if (!_endDateTime) {
        _endDateTime = [NSDate date];
    }
    
    //Stop LocationTracker
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Stop LocationTracker
    
    [_currLocationTracker stopLocationTracking];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Stop LocationTracker
    
    //Last Current Track Save
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Last Current Track Save
    
//    _currTrack[@"name"] = [NSString stringWithFormat:@"%@", [UserDataSingleton sharedSingleton].currTrackTitle];

//    _dismissHUBTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(dismissHUB) userInfo:nil repeats:NO];

    [ProgressHUD show:@"Saving..."];
    _isDismissed = NO;
    _btnBack.enabled = NO;
    
    [[UserDataSingleton sharedSingleton] saveCurrentTrack1:^(BOOL isOnline, BOOL finished, NSString * errString) {
        if (finished) {
            if (isOnline)
                [ProgressHUD showSuccess:@"Saved!"];
            else
                [ProgressHUD showSuccess:@"Offline Saved!"];
            _btnBack.enabled = YES;
            _isDismissed = YES;
            
            //Clear TripTitle
            //-------------------------------------------------------------------------------------------------------------------------------------------------------Clear TripTitle
            
            [UserDataSingleton sharedSingleton].currTrackTitle = @"";
            
            //-------------------------------------------------------------------------------------------------------------------------------------------------------Clear TripTitle
            
            [_selfTimer invalidate];
            _selfTimer = nil;
            
            [self fitBoundsMapView];
            
            [UserDataSingleton sharedSingleton].trackIsStarted = NO;
            [UserDataSingleton sharedSingleton].trackisStartable = NO;
            
            _currTrack = nil;
            _currTrackGeoPointArray = nil;
        }
        else
        {
            [ProgressHUD dismiss];
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Can't save the track. Will you continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alertView show];

            _btnBack.enabled = YES;
        }
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## EndTrack


//dismissHUB
//-------------------------------------------------------------------------------------------------------------------------------------------------------# dismissHUB

- (void)dismissHUB
{
    [ProgressHUD showSuccess:@"Saved!"];
    _btnBack.enabled = YES;
    _isDismissed = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------# dismissHUB


//fitBoundsMapView
//-------------------------------------------------------------------------------------------------------------------------------------------------------# fitBoundsMapView

- (void)fitBoundsMapView
{
    CLLocationDegrees minLat = 90, maxLat = -90, minLong = 180, maxLong = -180;
    
    if (_currTrackGeoPointArray.count > 0) {
        for (NSMutableArray * point in _currTrackGeoPointArray) {
            minLat = [point[0] doubleValue] < minLat ? [point[0] doubleValue] : minLat;
            maxLat = [point[0] doubleValue] > maxLat ? [point[0] doubleValue] : maxLat;
            minLong = [point[1] doubleValue] < minLong ? [point[1] doubleValue] : minLong;
            maxLong= [point[1] doubleValue] > maxLong ? [point[1] doubleValue] : maxLong;
            
            MKCoordinateRegion region;
            region.center.latitude = (minLat + maxLat) / 2;
            region.center.longitude = (minLong + maxLong) / 2;
            
            region.span.latitudeDelta = (maxLat - minLat) * MAP_PADDING;
            
            region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE) ? MINIMUM_VISIBLE_LATITUDE : region.span.latitudeDelta;
            
            region.span.longitudeDelta = (maxLong - minLong) * MAP_PADDING;
            
            MKCoordinateRegion scaledRegion = [_mapView regionThatFits:region];
            [_mapView setRegion:scaledRegion animated:YES];
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------# fitBoundsMapView


//captureMapView
//-------------------------------------------------------------------------------------------------------------------------------------------------------# captureMapView

- (void)captureMapView
{
//        CGSize size = _googleMapView.frame.size;
//        UIGraphicsBeginImageContext(size);
//        [[self.googleMapView layer] renderInContext:UIGraphicsGetCurrentContext()];
//        _capturedMapImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    if(error)
//        NSLog(@"Error");
//    else
//        NSLog(@"Success");
//}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## captureMapView

//showSocialShareButton
//-------------------------------------------------------------------------------------------------------------------------------------------------------# showSocialShareButton

- (void)showSocialShareButton
{
    BOOL isHidden = _shareContainerView.hidden;
    
    CGRect f = _shareContainerView.frame;
    f.origin.y = isHidden ? [UserDataSingleton sharedSingleton].screenHeight : 0;
    _shareContainerView.frame = f;
    _shareContainerView.hidden = isHidden ? NO : isHidden;
    _shareContainerBackView.hidden = isHidden ? NO : isHidden;
    _shareContainerBackView.layer.opacity = isHidden ? 0 : 0.4f;
    
    [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
        CGRect cf = _shareContainerView.frame;
        cf.origin.y = isHidden ? 0 : [UserDataSingleton sharedSingleton].screenHeight;
        _shareContainerView.frame = cf;
         _shareContainerBackView.layer.opacity = isHidden ? 0.4f : 0;
    } completion:^(BOOL finished) {
        _shareContainerView.hidden = isHidden ? NO : YES;
        _shareContainerBackView.hidden = isHidden ? NO : YES;
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## showSocialShareButton

//generateThumbnailImage
//-------------------------------------------------------------------------------------------------------------------------------------------------------# generateThumbnailImage

-(UIImage *)generateThumbnailImage : (NSURL *)filepath
{
    AVAsset *asset = [AVAsset assetWithURL:filepath];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0
                                       orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    //    thumbNail = thumbnail;
    return thumbnail;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## generateThumbnailImage


//showRootView
//-------------------------------------------------------------------------------------------------------------------------------------------------------# showRootView

- (void)showRootView:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## showRootView


-(void)updateLocation {
//    NSLog(@"updateLocation");
//    
//    [_currLocationTracker updateLocationToServer];
}


//dropAllPins
//-------------------------------------------------------------------------------------------------------------------------------------------------------# dropAllPins

- (void) dropAllPins
{
    for (PinAnnotation * pin in _currPinArray) {
        [_mapView addAnnotation:pin];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## dropAllPins


//dropPin
//-------------------------------------------------------------------------------------------------------------------------------------------------------# dropPin

- (void) dropPin:(CLLocation *)location type:(NSString *)typeStr mediaURL:(NSString *)urlString
{
    PinAnnotation * pin = [[PinAnnotation alloc] initWithCoordinate:location.coordinate];
    pin.coordinate = location.coordinate;
    pin.type = typeStr;
    pin.urlString = urlString;

    [_mapView addAnnotation:pin];

    [_currPinArray addObject:pin];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## dropPin


//showTrackPath
//-------------------------------------------------------------------------------------------------------------------------------------------------------# showTrackPath

- (void)showTrackPath
{
    CLLocationCoordinate2D coordnates[_currTrackGeoPointArray.count];
    for (int i = 0; i < _currTrackGeoPointArray.count; i++) {
        NSMutableArray * point = _currTrackGeoPointArray[i];
        CLLocationCoordinate2D geo_point;
        geo_point.latitude = [point[0] doubleValue];
        geo_point.longitude = [point[1] doubleValue];
        coordnates[i] = geo_point;
    }
    _currTrackPolyline = [MKPolyline polylineWithCoordinates:coordnates count:_currTrackGeoPointArray.count];
    [_mapView addOverlay:_currTrackPolyline level:MKOverlayLevelAboveRoads];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## showTrackPath

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

- (void)setCurrentLocationPin:(CLLocationCoordinate2D)coordinate
{
    if (!_stayedAnnotation) {
        _stayedAnnotation = [[SVAnnotation alloc] init];
        [self.mapView addAnnotation:_stayedAnnotation];
        MKCoordinateRegion region = {coordinate, [UserDataSingleton sharedSingleton].currMapSpan};
        [_mapView setRegion:region];
    }
    _stayedAnnotation.coordinate = coordinate;
    
    if (!MKMapRectContainsPoint(_mapView.visibleMapRect, MKMapPointForCoordinate(coordinate))) {
        MKCoordinateRegion region = {coordinate, [UserDataSingleton sharedSingleton].currMapSpan};
        [_mapView setRegion:region];
    }
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [UserDataSingleton sharedSingleton].currTrackTitle = @"";
        [UserDataSingleton sharedSingleton].trackIsStarted = NO;
        [UserDataSingleton sharedSingleton].trackisStartable = NO;
        
        [_selfTimer invalidate];
        _selfTimer = nil;

        _currTrack = nil;
        _currTrackGeoPointArray = nil;
        
        _btnBack.enabled = YES;
        
//        [_dismissHUBTimer invalidate];
//        _dismissHUBTimer = nil;
        
        [self showRootView];
    }
}

@end

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Methods
//http://api.wunderground.com/api/7d30fe039f34d4d9/conditions/q/37.33771,-122.0316.json
