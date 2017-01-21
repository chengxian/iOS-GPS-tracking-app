//
//  EditTripNameViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 10/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "EditTripNameViewController.h"

@implementation EditTripNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _txtName.text = [UserDataSingleton sharedSingleton].currTrackTitle;
    
    _txtName.layer.cornerRadius = 3;
    _txtName.layer.borderWidth = 1;
    _btnSave.layer.cornerRadius = 3;
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


#pragma mark - UITextFieldDelegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ UITextField Delegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ UITextField Delegate Methods


#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnSavePressed:(id)sender {
    
    NSString * tripName = [_txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tripName isEqualToString:@""]) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Please insert correct trip name"];
        return;
    }

    [UserDataSingleton sharedSingleton].currTrackTitle = [NSString stringWithFormat:@"%@", tripName];
    self.delegate = self.navigationController.viewControllers[0];
    [self.delegate didSaveTripName:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions

@end