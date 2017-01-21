//
//  ProfileViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 22/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UITextFieldDelegate>

//Outlets

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnLogOut;

//Actions
- (IBAction)btnSaveProfilePressed:(id)sender;

- (IBAction)btnLogoutPressed:(id)sender;

- (IBAction)btnBackPressed:(id)sender;
@end
