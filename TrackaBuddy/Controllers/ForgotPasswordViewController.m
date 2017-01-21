//
//  ForgotPasswordViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 12/08/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    UIView * paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 32)];
    _txtEmail.leftView = paddingView;
    _txtEmail.leftViewMode = UITextFieldViewModeAlways;
    _txtEmail.layer.cornerRadius = 7;
    _txtEmail.layer.borderColor = [UIColor colorWithRed:(30/255.0f) green:(215/255.0f) blue:(96/255.0f) alpha:1.0f].CGColor;
    _txtEmail.layer.borderWidth = 2;
    _btnSend.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendPressed:(id)sender {
    NSString * emailStr = [_txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (emailStr.length > 0) {
        [PFUser requestPasswordResetForEmailInBackground:emailStr];
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Password change request sent! Please check your email"];
    }
    else
    {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Please insert valid email or user name"];
        return;
    }
}


#pragma mark - UITextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
@end
