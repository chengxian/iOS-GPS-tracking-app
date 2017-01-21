//
//  MapDetailViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 29/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinAnnotation.h"
#import "PinAnnotationView.h"

@interface MapDetailViewController : UIViewController<MKMapViewDelegate>

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet UILabel *                              lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *                              lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *                              lblDateTime;
@property (weak, nonatomic) IBOutlet UIView *                               gestureView1;
@property (weak, nonatomic) IBOutlet UIView *                               infoView;
@property (weak, nonatomic) IBOutlet UILabel *                              lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *                              lblOnTripTime;
@property (weak, nonatomic) IBOutlet UILabel *                              lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *                              lblWeather;
@property (weak, nonatomic) IBOutlet UIView *                               gestureView2;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets

//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (strong, nonatomic) NSString *                                    gestureDirection;
@property (strong, nonatomic) PFObject *                                    currTrip;
@property (strong, nonatomic) NSArray *                                     mediaArray;
@property (strong, nonatomic) NSMutableArray *                              currPinArray;

@property (strong, nonatomic) MKPolyline *                                  currTrackPolyline;
@property (strong, nonatomic) MKPolylineView *          currTrackPolylineView;
@property (strong, nonatomic) MKPolylineRenderer *      currTrackPolylineRenderer;

@property (strong, nonatomic) CLLocation *                                  prevLocation;
@property (assign, nonatomic) double                                        totalDistance;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties


//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnBackPressed:(id)sender;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions
@end
