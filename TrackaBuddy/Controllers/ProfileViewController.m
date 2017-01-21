//
//  ProfileViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 22/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _txtName.text = [PFUser currentUser].username;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _txtName.layer.cornerRadius = 3;
    _txtPassword.layer.cornerRadius = 3;
    _txtConfirm.layer.cornerRadius = 3;
    _btnSaveProfile.layer.cornerRadius = 5;
    _btnLogOut.layer.cornerRadius = 5;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ UITextFieldDelegate Methods


#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnSaveProfilePressed:(id)sender {
    NSString * userName = [_txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * password = [_txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * confirm = [_txtConfirm.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    if (userName.length == 0) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Please insert valid email or user name."];
        return;
    }
    
    if (password.length > 0) {
        if (password.length < 6) {
            [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Please insert at least 6 characters."];
            return;
        }
        
        if (![password isEqualToString:confirm]) {
            [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Password and Confirm must be equal."];
            return;
        }
    }
    
    UIImage * image = [UIImage imageNamed:@"profile"];
    
    [ProgressHUD show:@"Saving..."];
    [[UserDataSingleton sharedSingleton] saveProfile:userName email:userName password:password profile_image:image completion:^(BOOL finished, NSError *error) {
        if (finished) {
            [ProgressHUD showSuccess:@"Saved"];
        }
        else
        {
            [ProgressHUD showSuccess:@"Offline Saved"];
        }
    }];
    
}

- (IBAction)btnLogoutPressed:(id)sender {
    [self logOut];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions


#pragma mark - Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Methods

- (void)logOut
{
    if ([UserDataSingleton sharedSingleton].trackIsStarted) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Track is running! Please end the track and retry lotout."];
        return;
    }
    [PFUser logOut];
    
    [[UserDataSingleton sharedSingleton].userDefaults setObject:nil forKey:@"current_user"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Methods


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
