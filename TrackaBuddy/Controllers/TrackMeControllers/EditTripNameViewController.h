//
//  EditTripNameViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 10/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditTripNameViewControllerDelegate;

@interface EditTripNameViewController : UIViewController<UITextFieldDelegate>

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

//@property(strong, nonatomic) PFObject * currTrack;
@property(strong, nonatomic) id<EditTripNameViewControllerDelegate> delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties


//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnSavePressed:(id)sender;

- (IBAction)btnCancelPressed:(id)sender;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions

@end

@protocol EditTripNameViewControllerDelegate <NSObject>

- (void)didSaveTripName:(BOOL)saved;

@end
