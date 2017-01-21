//
//  SettingViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 18/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

//Outlets
//-----------------------------------------------------------------------------------------------------------------------------------@ Outlets


//Properties
//-----------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (strong, nonatomic) NSMutableArray *          m_TableCellIDArr;

//-----------------------------------------------------------------------------------------------------------------------------------@@ Properties



//Actions
//-----------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)switchTrafficEnableChanged:(id)sender;

- (IBAction)btnBackPressed:(id)sender;

- (IBAction)mapTypeChanged:(id)sender;

- (IBAction)trafficModeChanged:(id)sender;

//-----------------------------------------------------------------------------------------------------------------------------------@@ Actions

@end
