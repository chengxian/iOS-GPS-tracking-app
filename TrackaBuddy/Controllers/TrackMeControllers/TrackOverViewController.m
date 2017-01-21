//
//  TrackOverViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 28/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "TrackOverViewController.h"

@implementation TrackOverViewController

- (void)viewDidLoad
{
    _blurredImageView.image = _blurredImage;
    
    _lblElevation.text =[NSString stringWithFormat:@"%.2f m", [[_overviewData valueForKey:@"elevation"] floatValue]];
    
    CGFloat distance = [[_overviewData valueForKey:@"distance"] floatValue];
    if (distance > 100) {
        CGFloat kilometre = distance / 1000;
        if (kilometre > 0) {
            _lblDistance.text = [NSString stringWithFormat:@"%.1f km", kilometre];
        }
    }
    else
    {
        _lblDistance.text = [NSString stringWithFormat:@"%.1f m", distance];
    }
    _lblStartTime.text = [NSString stringWithFormat:@"Start : %@", [_overviewData valueForKey:@"starttime"]];
    _lblDuration.text = [NSString stringWithFormat:@"On Trips: %@",[_overviewData valueForKey:@"duration"]];
    _lblHeartRate.text = [NSString stringWithFormat:@"%.2f / min",[[_overviewData valueForKey:@"heartrate"] floatValue]];
    _lblTemp.text = [NSString stringWithFormat:@"%.2f °C",[[_overviewData valueForKey:@"temp"] floatValue]];
    
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

- (IBAction)btnBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setTrackOverviewData:(NSMutableDictionary *)data;
{
    _overviewData = data;
}
@end
