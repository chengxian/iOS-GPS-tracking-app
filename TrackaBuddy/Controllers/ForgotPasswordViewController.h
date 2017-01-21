//
//  ForgotPasswordViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 12/08/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

//Actions
- (IBAction)btnBackPressed:(id)sender;

- (IBAction)btnSendPressed:(id)sender;

@end
