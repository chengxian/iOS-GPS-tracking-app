//
//  TrackViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 10/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+Ratation.h"
#import "LocationTracker.h"
#import "EditTripNameViewController.h"
#import "ImageFilterViewController.h"
#import "AddNotesViewController.h"
#import "TrackOverViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Social/Social.h>
#import "ShowGalleryViewController.h"
#import "POVoiceHUD.h"
#import "NSDictionary+RemoveNullsWithStrings.h"
#import "EditPhotoViewController.h"
#import "ALAssetsLibrary+CustomAlbum.h"
#import "SVAnnotation.h"
#import "SVPulsingAnnotationView.h"
#import "PinAnnotation.h"
#import "PinAnnotationView.h"
#import "MediaReviewController.h"

@interface TrackViewController : UIViewController<UIActionSheetDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AFNetClientDelegate, LocationTrackerDelegate, ImageFilterViewControllerDelegate, AddNotesViewControllerDelegate, EditTripNameViewControllerDelegate, UIAlertViewDelegate, MKMapViewDelegate, MediaReviewControllerDelegate>

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet MKMapView *        mapView;
@property (weak, nonatomic) IBOutlet UIView *           gestureView2;
@property (weak, nonatomic) IBOutlet UIView *           shareContainerView;
@property (weak, nonatomic) IBOutlet UIView *           shareContainerBackView;
@property (weak, nonatomic) IBOutlet UIView *           shareButtonContainer;
@property (weak, nonatomic) IBOutlet UILabel *          lblShareButtonViewTitle;
@property (weak, nonatomic) IBOutlet UIButton *         btnBack;
@property (weak, nonatomic) IBOutlet UIButton *         btnShareFacebook;
@property (weak, nonatomic) IBOutlet UIButton *         btnShareTwitter;
@property (weak, nonatomic) IBOutlet UIButton *         btnShareCancel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareContainerViewTopMarginConstraint;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (strong, nonatomic) ALAssetsLibrary *         assetsLibrary;
@property (strong, nonatomic) NSString *                gestureDirection;
@property (strong, nonatomic) NSMutableArray *          m_TableCellIDArr;
@property (strong, nonatomic) NSString *                currVoiceUUID;
@property (strong, nonatomic) LocationTracker *         currLocationTracker;
@property (assign, nonatomic) BOOL                      isStartTrack;
@property (assign, nonatomic) BOOL                      isAbleTrack;
@property (strong, nonatomic) CLLocation *              prevLocation;
@property (assign, nonatomic) NSInteger                 updateInterval;
@property (assign, nonatomic) CGFloat                   totalDistance;
@property (strong, nonatomic) NSDate *                  startDateTime;
@property (strong, nonatomic) NSDate *                  endDateTime;
@property (strong, nonatomic) NSString *                fullAddress;
@property (strong, nonatomic) NSTimer *                 selfTimer;
@property (strong, nonatomic) NSTimer *                 locationUpdateTimer;

@property (strong, nonatomic) SVAnnotation *            stayedAnnotation;
@property (strong, nonatomic) PinAnnotation *           locationPin;
@property (strong, nonatomic) MKPolyline *              currTrackPolyline;
@property (strong, nonatomic) MKPolylineView *          currTrackPolylineView;
@property (strong, nonatomic) MKPolylineRenderer *      currTrackPolylineRenderer;
@property (strong, nonatomic) NSMutableArray *          currTrackGeoPointArray;
@property (assign, nonatomic) MKCoordinateSpan          currSpan;

@property (strong, nonatomic) PFObject *                currTrack;
@property (strong, nonatomic) NSMutableArray *          currPinArray;
@property (strong, nonatomic) ALAssetsLibrary *         library;
@property (strong, nonatomic) UIImage *                 capturedMapImage;

@property (strong, nonatomic) NSTimer *                 dismissHUBTimer;
@property (assign, nonatomic) BOOL                      isDismissed;
//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties

//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnBackPressed:(id)sender;

- (IBAction)btnSettingPressed:(id)sender;

- (IBAction)btnEndTripPressed:(id)sender;

- (IBAction)btnSharePressed:(id)sender;

- (IBAction)btnCameraPressed:(id)sender;

- (IBAction)btnAddPressed:(id)sender;

- (IBAction)btnOverviewPressed:(id)sender;


//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions

@end

