//
//  MyTripsViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 17/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMDateSelectionViewController.h"
#import "MyTripsTableCell.h"
#import "MGSwipeTableCell.h"

@interface MyTripsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MyTripsTableCellDelegate, MGSwipeTableCellDelegate, UIAlertViewDelegate>

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet UITableView *              tblList;
@property (weak, nonatomic) IBOutlet UIView *                   searchBackView;
@property (weak, nonatomic) IBOutlet UIView *                   searchOptionContainer;
@property (weak, nonatomic) IBOutlet UITextField *              txtName;
@property (weak, nonatomic) IBOutlet UITextField *              txtAddr;
@property (weak, nonatomic) IBOutlet UITextField *              txtFrom;
@property (weak, nonatomic) IBOutlet UITextField *              txtTo;
@property (weak, nonatomic) IBOutlet UIButton *                 btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *                 btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSearchView;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (strong, nonatomic) RMDateSelectionViewController *   dateSelectionController;
@property (strong, nonatomic) UIDatePicker *                    dtFromPicker;
@property (strong, nonatomic) UIDatePicker *                    dtToPicker;
@property (assign, nonatomic) BOOL                              filterIsApplied;
@property (strong, nonatomic) NSDate *                          fromDate;
@property (strong, nonatomic) NSDate *                          toDate;
@property (strong, nonatomic) NSMutableArray *                  trackArray;
@property (assign, nonatomic) NSInteger                         selIndex;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties


//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnBackPressed:(id)sender;

- (IBAction)btnSearchViewPressed:(id)sender;

- (IBAction)btnSearchPressed:(id)sender;

- (IBAction)btnCancelSearchPrssed:(id)sender;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions

@end
