//
//  MyTripsTableCell.h
//  TrackaBuddy
//
//  Created by Alexander on 21/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@protocol MyTripsTableCellDelegate;

@interface MyTripsTableCell : MGSwipeTableCell

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (assign, nonatomic) NSUInteger mIndex;

@property (strong, nonatomic) id<MyTripsTableCellDelegate> cellDelegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties


//Public Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Public Methods

- (void) setValue:(NSString *)title details:(NSString *)details index:(NSInteger)index;

- (void) setValue:(PFObject *)object index:(NSInteger)index;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Public Methods


//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnInfoPressed:(id)sender;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions

@end

@protocol MyTripsTableCellDelegate <NSObject>

- (void)myTripTableCell:(MyTripsTableCell *)myTripTableCell didSelectedRow:(NSInteger)row;

@end
