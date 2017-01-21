//
//  MapDetailViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 29/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "MapDetailViewController.h"
#import "EditPhotoViewController.h"
#import <math.h>

@implementation MapDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Gesture Setting to show the Infomatin View(Time, Distance, On Trip Time, Weather)
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Gesture Setting
    
    UISwipeGestureRecognizer * swipeRecognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showInfoView)];
    [swipeRecognizer1 setDirection:UISwipeGestureRecognizerDirectionDown];
    [_gestureView1 addGestureRecognizer:swipeRecognizer1];
    
    UISwipeGestureRecognizer * swipeRecognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideInfoView)];
    [swipeRecognizer2 setDirection:UISwipeGestureRecognizerDirectionUp];
    [_gestureView2 addGestureRecognizer:swipeRecognizer2];
    
    _gestureDirection = @"down";
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Gesture Setting
    
    //Map Setting
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Map Setting
    
    _mapView.mapType = (MKMapType)[[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"map_type"] integerValue];
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------------Map Setting
    
    [self showMapDetailData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEnterBackgroudNotification) name:NOTIFICATION_ENTER_BACKGROUND object:nil];
}

- (void)didReceiveEnterBackgroudNotification
{
    NSLog(@"didReceiveEnterBackgroudNotification");
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[PinAnnotation class]])
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
        pinView.mediaFile = pin.mediaFile;
        
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

#pragma mark - MKMapView AnnotationView Tap Methods

- (void)didTapPin:(UITapGestureRecognizer *)sender {
    PinAnnotationView * pinView = (PinAnnotationView *)sender.view;
    
    if ([pinView.type  isEqual:MARKER_TYPE[MARKER_PIC]]) {
        [self performSegueWithIdentifier:@"showEditPhotoViewFromMapDetail" sender:pinView];
    }
    else if ([pinView.type isEqual:MARKER_TYPE[MARKER_VIDEO]])
    {
        PFFile * mediaFile = pinView.mediaFile;
        
        [ProgressHUD show:@"Downloading..."];
        [mediaFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                [ProgressHUD dismiss];
                NSString * file = [[UserDataSingleton sharedSingleton].documentDirectory stringByAppendingPathComponent:@"MyFile.mov"];
                [data writeToFile:file atomically:YES];
                
                MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:file]];
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
            else
            {
                [ProgressHUD dismiss];
                [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't play due to network status. Please retry"];
                return;
            }
        }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ GMSMapView Delegate

#pragma mark - SwipeGestueRecogniger Handle Methods

//showInfoView
//-------------------------------------------------------------------------------------------------------------------------------------------------------# showInfoView

- (void)showInfoView
{
    if (!_infoView.hidden) {
        return;
    }
    CGRect f = _infoView.frame;
    f.origin.y = -80;
    _infoView.frame = f;
    _infoView.hidden = NO;
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8f options:0 animations:^{
        CGRect cf = _infoView.frame;
        cf.origin.y = 0;
        _infoView.frame = cf;
    } completion:^(BOOL finished) {
        [_mapView layoutIfNeeded];
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## showInfoView


//hideInfoView
//-------------------------------------------------------------------------------------------------------------------------------------------------------# hideInfoView

- (void)hideInfoView
{
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5f options:0 animations:^{
        CGRect cf = _infoView.frame;
        cf.origin.y = -80;
        _infoView.frame = cf;
    } completion:^(BOOL finished) {
        _infoView.hidden = YES;
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## hideInfoView

#pragma mark - Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Methods

- (void)showMapDetailData
{
    [ProgressHUD show:@"Loading..."];
    
    _lblTitle.text = _currTrip[@"name"];
    _lblAddress.text = _currTrip[@"address"];
    NSDate * start_datetime = _currTrip[@"start_datetime"];
    _lblDateTime.text = [DateUtils getDateStringFromDateType2:start_datetime];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm aaa"];
    NSString * dateString = [formatter stringFromDate:start_datetime];
    _lblStartTime.text = [NSString stringWithFormat:@"Time : %@", dateString];
    
    NSDate * end_datetime = _currTrip[@"end_datetime"];
    NSString * onTripTimeStr = [DateUtils getDiffTimeBetweenTwoDate:start_datetime toDate:end_datetime];
    onTripTimeStr = [onTripTimeStr isEqualToString:@""] ? @"1m" : onTripTimeStr;
    _lblOnTripTime.text = [NSString stringWithFormat:@"On Trips : %@", onTripTimeStr];
    
    NSMutableArray * geoPointArray = _currTrip[@"geo_point_array"];
    
    NSLog(@"point count : %ld", (unsigned long)[geoPointArray count]);
    
    if ([geoPointArray count] > 1) {
        [self showTrackPathAndDistance:geoPointArray];
        [self dropAllPins];
        [self fitBoundsMapView:geoPointArray];
        [ProgressHUD dismiss];
    }
    else
    {
        NSLog(@"Error");
        [ProgressHUD dismiss];
    }
    
}

- (void)showTrackPathAndDistance:(NSMutableArray *)geopoint_array
{
    CLLocationCoordinate2D coordnates[geopoint_array.count];
    CGFloat totalDistance = 0, distance = 0;
    CLLocation * prevLocation, * newLocatin;
    
    for (int i = 0; i < geopoint_array.count; i++) {
        NSMutableArray * point = geopoint_array[i];
        CLLocationCoordinate2D geo_point;
        geo_point.latitude = [point[0] doubleValue];
        geo_point.longitude = [point[1] doubleValue];
        coordnates[i] = geo_point;
        
        newLocatin = [[CLLocation alloc] initWithLatitude:geo_point.latitude longitude:geo_point.longitude];
        if (prevLocation) {
            distance = [newLocatin distanceFromLocation:prevLocation];
            totalDistance += distance;
            NSLog(@"index : %d, distance : %f , totalDistance : %f", i, distance, totalDistance);
        }
        prevLocation = newLocatin;
    }

    if (totalDistance > 100) {
        CGFloat kilometre = totalDistance / 1000;
        if (kilometre > 0) {
            _lblDistance.text = [NSString stringWithFormat:@"Distance : %.1fkm", kilometre];
        }
    }
    else
    {
        _lblDistance.text = [NSString stringWithFormat:@"Distance : %.1fm", totalDistance];
    }
    
    _currTrackPolyline = [MKPolyline polylineWithCoordinates:coordnates count:geopoint_array.count];
    [_mapView addOverlay:_currTrackPolyline level:MKOverlayLevelAboveRoads];
    
    NSMutableArray * startPoint = [geopoint_array objectAtIndex:0];
    CLLocation * startLocation = [[CLLocation alloc] initWithLatitude:[startPoint[0] doubleValue] longitude:[startPoint[1] doubleValue]];
    [self dropPin:startLocation type:MARKER_TYPE[MARKER_START] mediaFile:nil];
    
    NSMutableArray * endPoint = [geopoint_array objectAtIndex:[geopoint_array count] - 1];
    CLLocation * endLocation = [[CLLocation alloc] initWithLatitude:[endPoint[0] doubleValue] longitude:[endPoint[1] doubleValue]];
    [self dropPin:endLocation type:MARKER_TYPE[MARKER_END] mediaFile:nil];
}


- (void) dropAllPins
{
    if ([_mediaArray count] > 0) {
        for (PFObject * media in _mediaArray) {
            PFGeoPoint * point = media[@"geo_point"];
            CLLocation * location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
            NSInteger type = [media[@"media_type"] integerValue] + 2;
            PFFile * mediaFile = media[@"media_file"];

            [self dropPin:location type:MARKER_TYPE[type] mediaFile:mediaFile];
        }
    }
}


- (void) dropPin:(CLLocation *)location type:(NSString *)typeStr mediaFile:(PFFile *)mediaFile
{
    PinAnnotation * pin = [[PinAnnotation alloc] initWithCoordinate:location.coordinate];
    pin.coordinate = location.coordinate;
    pin.type = typeStr;
    pin.mediaFile = mediaFile;
    
    [_mapView addAnnotation:pin];
}

//fitBoundsMapView
//-------------------------------------------------------------------------------------------------------------------------------------------------------# fitBoundsMapView

- (void)fitBoundsMapView:(NSMutableArray *)geopoint_array
{
    CLLocationDegrees minLat = 90, maxLat = -90, minLong = 180, maxLong = -180;
    
    if (geopoint_array.count > 0) {
        for (NSMutableArray * point in geopoint_array) {
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

//-------------------------------------------------------------------------------------------------------------------------------------------------------## fitBoundsMapView


//movieFinishedCallback
//-------------------------------------------------------------------------------------------------------------------------------------------------------# movieFinishedCallback

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

//-------------------------------------------------------------------------------------------------------------------------------------------------------## movieFinishedCallback

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Methods


- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PinAnnotationView * pinView = (PinAnnotationView *)sender;
    PFFile * mediaFile = pinView.mediaFile;
    
     if ( mediaFile != nil && [[segue identifier] isEqualToString:@"showEditPhotoViewFromMapDetail"])
     {
         EditPhotoViewController * vc = [segue destinationViewController];
         [vc setPhotoFileFromRemote:mediaFile];
     }
}

@end
