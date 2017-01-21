//
//  MyTripsTableCell.m
//  TrackaBuddy
//
//  Created by Alexander on 21/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "MyTripsTableCell.h"

@interface MyTripsTableCell ()



@end

@implementation MyTripsTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Public Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Public Methods

- (void) setValue:(NSString *)title details:(NSString *)details index:(NSInteger)index
{
    _lblTitle.text = title;
    _lblDetails.text = details;
    _mIndex = index;
}

- (void) setValue:(PFObject *)object index:(NSInteger)index;
{
    NSDate * startDate = object[@"start_datetime"];
    NSString * dateString = [DateUtils getDateStringFromDateType2:startDate];
    
    NSString * title = object[@"name"];
    title =  (title == nil || [title isEqualToString:@""]) ? @"No Named" : title;
    _lblTitle.text = title;
    _lblDetails.text = dateString;
    _mIndex = index;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Public Methods


#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnInfoPressed:(id)sender {
    NSLog(@"btnInfo Pressed");
    [self.cellDelegate myTripTableCell:self didSelectedRow:_mIndex];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions
@end
