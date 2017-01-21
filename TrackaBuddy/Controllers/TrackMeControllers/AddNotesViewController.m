//
//  AddNotesViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 13/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "AddNotesViewController.h"

@implementation AddNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tvNote.layer.borderWidth = 1;
    _tvNote.layer.cornerRadius = 3;
    _btnSave.layer.cornerRadius = 3;
    
    if (_isReview) {
        _btnSave.hidden = YES;
        _tvNote.text = [UserDataSingleton sharedSingleton].noteStr;
    }
    
    _tvNote.keyboardAppearance = UIKeyboardAppearanceDark;
    [self createInputAccessoryView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createInputAccessoryView{
    keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.tintColor = [UIColor whiteColor];
    
    btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTyping:)];
    UIBarButtonItem *flexspace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardToolbar setItems:[NSArray arrayWithObjects: flexspace,btnDone, nil] animated:NO];
    
    [_tvNote setInputAccessoryView:keyboardToolbar];
}


#pragma mark - Public Method
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Public Method

- (void)setReview:(BOOL)isReview
{
    _isReview = isReview;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Public Method


#pragma mark - Method
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Method

-(void)doneTyping:(id)sender{
    [_tvNote resignFirstResponder];
}

- (void)showRootView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Method


#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnSavePressed:(id)sender {
    [UserDataSingleton sharedSingleton].noteStr = _tvNote.text;
    
    if ([UserDataSingleton sharedSingleton].currSocialGeoPoint == nil) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't get location"];
        return;
    }
    
    [ProgressHUD show:@"Saving..."];
    [[UserDataSingleton sharedSingleton] saveNote:_tvNote.text completion:^(BOOL finished, NSError *error) {
        if (finished) { 
            [ProgressHUD showSuccess:@"Saved!"];
        }
        else
        {
            [ProgressHUD showSuccess:@"Offline Saved!"];
        }
        
        self.delegate = self.navigationController.viewControllers[0];
        [self.delegate addNotesController:self didNoteSaved:YES];
        [self performSelector:@selector(showRootView) withObject:nil afterDelay:0.7f];
    }];
}

- (IBAction)btnCancelPressed:(id)sender {
    _tvNote.text = @"";
    [self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end