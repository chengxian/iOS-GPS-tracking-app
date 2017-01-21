//
//  MainViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 10/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "MainViewController.h"
#import "TrackViewController.h"

@interface MainViewController ()

//Outlets
//----------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIButton *btnTrackMe;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoMap;
@property (weak, nonatomic) IBOutlet UIButton *btnByTrips;
@property (weak, nonatomic) IBOutlet UIButton *btnTrackaBuddy;
@property (weak, nonatomic) IBOutlet UIButton *btnEndTrip;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTrackaBuddyWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTrackMeWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnGotoMapWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnMyTripsWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceH1Constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceH2Constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceH3Constraint;


//----------------------------------------------------------------------------


//Actions
//----------------------------------------------------------------------------
- (IBAction)btnTrackMePressed:(id)sender;

- (IBAction)btnGotoMapPressed:(id)sender;

- (IBAction)btnEndTripPressed:(id)sender;

- (IBAction)btnSettingPressed:(id)sender;

//----------------------------------------------------------------------------

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger screenWidth = [UserDataSingleton sharedSingleton].screenWidth;
    NSInteger screenHeight = [UserDataSingleton sharedSingleton].screenHeight;
    NSInteger buttonWidth = screenWidth / 2;
    CGFloat hRate = (CGFloat)screenHeight / 568;
    _btnTrackaBuddyWConstraint.constant = buttonWidth;
    _btnTrackMeWConstraint.constant = buttonWidth / 1.17647059;
    _btnGotoMapWConstraint.constant = buttonWidth / 1.17647059;
    _btnMyTripsWConstraint.constant = buttonWidth / 1.39130435;
    _distanceH1Constraint.constant = _distanceH1Constraint.constant * hRate;
    _distanceH2Constraint.constant = _distanceH2Constraint.constant * hRate;
    _distanceH3Constraint.constant = _distanceH1Constraint.constant * hRate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL hidden = [UserDataSingleton sharedSingleton].trackIsStarted;
    _btnTrackMe.hidden = hidden;
    _btnGotoMap.hidden = !hidden;
    
    _lblVersion.text = [UserDataSingleton sharedSingleton].currAppVersion;
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//Actions
//----------------------------------------------------------------------------

- (IBAction)btnTrackMePressed:(id)sender {
    NSInteger trafficMode = [[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_mode"] integerValue];
    NSString * trafficModeStr;
    switch (trafficMode) {
        case 1:
            trafficModeStr = @"Walk";
            break;
        case 2:
            trafficModeStr = @"Bike";
            break;
        case 3:
            trafficModeStr = @"Car";
            break;
        default:
            break;
    }
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"TrackaBuddy"
                                 message:[NSString stringWithFormat:@"Are you sure to start a track by %@ mode?", trafficModeStr]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"showSettingViewFromMain" sender:nil];
    }];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"showTrackViewWithStart" sender:nil];
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnGotoMapPressed:(id)sender {
}

- (IBAction)btnEndTripPressed:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:END_TRIP_NOTIFICATION object:nil];
}

- (IBAction)btnSettingPressed:(id)sender {
}

//----------------------------------------------------------------------------

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showTrackViewWithStart"]) {
        NSLog(@"Control Able");
        [UserDataSingleton sharedSingleton].trackisStartable = YES;
    }
    else if ([[segue identifier] isEqualToString:@"showTrackViewWithEnd"]) {
        [UserDataSingleton sharedSingleton].trackisEnding = YES;
    }
}
@end
