//
//  AddNotesViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 13/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNotesViewControllerDelegate;

@interface AddNotesViewController : UIViewController
{
    UIToolbar   * keyboardToolbar;
    UIBarButtonItem  * btnDone;
}

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet UITextView *tvNote;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (assign, nonatomic) BOOL isReview;

@property (nonatomic, strong) id<AddNotesViewControllerDelegate> delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties


//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnSavePressed:(id)sender;

- (IBAction)btnCancelPressed:(id)sender;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions


//Public Method
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Public Methods

- (void)setReview:(BOOL)isReview;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Public Methods

@end

@protocol AddNotesViewControllerDelegate <NSObject>

- (void)addNotesController:(AddNotesViewController *)addNotesController didNoteSaved:(BOOL)saved;

@end
