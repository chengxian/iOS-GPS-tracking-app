//
//  TrackOverViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 28/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackOverViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *blurredImageView;
@property (strong, nonatomic) NSMutableDictionary * overviewData;
@property (strong, nonatomic) UIImage * blurredImage;
@property (weak, nonatomic) IBOutlet UILabel *lblElevation;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblHeartRate;
@property (weak, nonatomic) IBOutlet UILabel *lblTemp;

- (IBAction)btnBackPressed:(id)sender;

- (void)setTrackOverviewData:(NSMutableDictionary *)data;

@end
