//
//  LoginViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 17/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

//Outlets
//----------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *loginContainer;
@property (weak, nonatomic) IBOutlet UITextField *      txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *      txtPass;
@property (weak, nonatomic) IBOutlet UIButton *         btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *         btnRemember;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint2;


//----------------------------------------------------------------------------

//Properties
//----------------------------------------------------------------------------

@property (nonatomic, assign) BOOL                      isRemeber;

//----------------------------------------------------------------------------

//Actions
//----------------------------------------------------------------------------

- (IBAction)btnSignInPressed:(id)sender;

- (IBAction)btnRememberPressed:(id)sender;

//----------------------------------------------------------------------------

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"current_user"] != nil) {
        [self performSegueWithIdentifier:@"showMainView" sender:nil];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Setting Control Style
    //----------------------------------------------------------------------------
    
    UIView * paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 32)];
    _txtEmail.leftView = paddingView;
    _txtEmail.leftViewMode = UITextFieldViewModeAlways;
    UIView * paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 32)];
    _txtPass.leftView = paddingView1;
    _txtPass.leftViewMode = UITextFieldViewModeAlways;
    _txtEmail.layer.borderColor = [UIColor colorWithRed:(30/255.0f) green:(215/255.0f) blue:(96/255.0f) alpha:1.0f].CGColor;
    _txtEmail.layer.borderWidth = 2;
    _txtPass.layer.borderColor = [UIColor colorWithRed:(30/255.0f) green:(215/255.0f) blue:(96/255.0f) alpha:1.0f].CGColor;
    _txtPass.layer.borderWidth = 2;
    _btnSignIn.layer.cornerRadius = 25;
    _btnRemember.layer.cornerRadius = 5;
    
    _isRemeber = [UserDataSingleton sharedSingleton].isRemember;
    
    if ([[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"logined_user"] != nil) {
        _txtEmail.text = [[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"logined_user"];
    }
    //----------------------------------------------------------------------------
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//UITextField Delegate Methods
//----------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

//----------------------------------------------------------------------------

#pragma mark - Methods
//----------------------------------------------------------------------------

- (void)keyboardWillShow:(NSNotification *)notif
{
    
    CGRect passTestFrame = _txtPass.frame;
    CGFloat heightKeyboard;
    
    NSDictionary *info = [notif userInfo];
    CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ((notif.name == UIKeyboardWillShowNotification) || (notif.name == UIKeyboardDidShowNotification))
    {
        heightKeyboard = keyboard.size.height;
    }
    
    CGFloat distanceFromBottom = [UserDataSingleton sharedSingleton].screenHeight - (_loginContainer.frame.origin.y + passTestFrame.size.height + passTestFrame.origin.y)-20;
//    CGFloat desConstant = distanceFromBottom - heightKeyboard - 30 - passTestFrame.size.height;
    CGFloat desConstant = heightKeyboard -  distanceFromBottom;

    if (distanceFromBottom < heightKeyboard) {
        NSLog(@"distabce : %f", heightKeyboard - distanceFromBottom);
        
        _constraint1.constant = 0;
        
        CGRect fff = _containerView.frame;
        fff.origin.y = 20;
        _containerView.frame = fff;
        
        [UIView animateWithDuration:0.3f animations:^{
            _constraint1.constant = - desConstant;
            _constraint2.constant = desConstant;
            [self.view layoutIfNeeded];
        }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    
    [UIView animateWithDuration:2.0 animations:^{
        _constraint2.constant = 0;
        _constraint1.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

//----------------------------------------------------------------------------


#pragma mark - Actions
//----------------------------------------------------------------------------

- (IBAction)btnSignInPressed:(id)sender {
    
    [ProgressHUD show:@"Signing..."];
    
    [PFUser logInWithUsernameInBackground:_txtEmail.text password:_txtPass.text block:^(PFUser *user, NSError *error) {
        [ProgressHUD dismiss];

        if (user) {
            if (_isRemeber) {
                [[UserDataSingleton sharedSingleton].userDefaults setObject:user.email forKey:@"current_user"];
            }

            [[UserDataSingleton sharedSingleton].userDefaults setObject:user.email forKey:@"logined_user"];
            [[UserDataSingleton sharedSingleton].userDefaults synchronize];
            
            [self performSegueWithIdentifier:@"showMainView" sender:nil];
            return;
        }
        else
        {
            NSLog(@"Please check you credential");
            [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Please check your email(username) or password!"];
        }
    }];
    
    //sample sign up
//    [ProgressHUD show:@"Signup Processing..."];
//
//    UIImage * image = [UIImage imageNamed:@"profile"];
//    [[UserDataSingleton sharedSingleton] signUpUser:@"tester@gmail.com" email:@"tester@gmail.com" password:@"aaaaaaaa" profile_image:image completion:^(BOOL finished, NSError *error) {
//        if (finished)
//        {
//            [ProgressHUD showSuccess:@"Success!"];
//        }
//        else
//        {
//            [ProgressHUD showError:@"Can't Signup, Network Error!"];
//        }
//    }];
    //sample sign up
}

- (IBAction)btnRememberPressed:(id)sender {
    _isRemeber = !_isRemeber;
    [_btnRemember setImage:_isRemeber ? [UIImage imageNamed:@"check_on"] : [UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

//----------------------------------------------------------------------------
@end
