//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropViewController.h"
#import "GKImageCropView.h"
#import "ImageFilterViewController.h"

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *useButton;

- (void)_actionCancel;
- (void)_actionUse;
- (void)_setupNavigationBar;
- (void)_setupCropView;

@end

@implementation GKImageCropViewController

//MingleloopAppDelegate *appdelegate;

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton, resizeableCropArea;

#pragma mark -
#pragma Private Methods

- (void)_actionCancel
{
    [self.navigationController.navigationBar setHidden:YES];
//    if (appdelegate.strEditIndex.length > 0)
//    {
//        [self dismissViewControllerAnimated:NO completion:nil];
//    }
//    else
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (void)_actionUse
{
    [self.navigationController.navigationBar setHidden:YES];
    _croppedImage = [self.imageCropView croppedImage];
    
//    if (appdelegate.strEditIndex.length == 0 && [appdelegate.strPhotoOptions isEqualToString:@"CAMERA"]) {
//        _croppedImage=[_croppedImage imageRotatedByDegrees:90];
//    }
//    appdelegate.imgOriginal = _croppedImage;
//    appdelegate.MediaData = UIImageJPEGRepresentation(_croppedImage, 1.0);
//    if (appdelegate.strEditIndex.length > 0)
//    {
//        [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    else
//    {
//        [self performSegueWithIdentifier:@"showImageFilterView" sender:nil];
//        ImageFilterViewController *image = [[ImageFilterViewController alloc] initWithNibName:@"ImageFilterViewController" bundle:nil];
//        [self.navigationController pushViewController:image animated:YES];
//    }
}

- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees
{
    CGFloat rads = M_PI * degrees / 180;
    float newSide = MAX([image size].width, [image size].height);
    CGSize size =  CGSizeMake(newSide, newSide);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
    CGContextRotateCTM(ctx, rads);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[image size].width/2,-[image size].height/2,size.width, size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

- (void)_setupNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
        target:self action:@selector(_actionCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Use" style:UIBarButtonItemStylePlain target:self
        action:@selector(_actionUse)];
}


- (void)_setupCropView
{
    self.imageCropView = [[GKImageCropView alloc] initWithFrame:self.view.bounds];
    [self.imageCropView setImageToCrop:sourceImage];
    [self.imageCropView setResizableCropArea:self.resizeableCropArea];
    [self.imageCropView setCropSize:cropSize];
    [self.view addSubview:self.imageCropView];
}

//- (void)_setupCancelButton
//{
//    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
//    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
//    
//    [[self.cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
//    [[self.cancelButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
//    [self.cancelButton setFrame:CGRectMake(0, 0, 50, 30)];
//    [self.cancelButton setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateNormal];
//    [self.cancelButton setTitleColor:[UIColor colorWithRed:0.173 green:0.176 blue:0.176 alpha:1] forState:UIControlStateNormal];
//    [self.cancelButton setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
//    [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
//    
//}
//
//- (void)_setupUseButton
//{
//    self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    [self.useButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
//    [self.useButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
//    
//    [[self.useButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
//    [[self.useButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
//    [self.useButton setFrame:CGRectMake(0, 0, 50, 30)];
//    [self.useButton setTitle:NSLocalizedString(@"Use",@"") forState:UIControlStateNormal];
//    [self.useButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
//    [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
//    
//}
//
//- (UIImage *)_toolbarBackgroundImage
//{
//    CGFloat components[] = {
//        1., 1., 1., 1.,
//        123./255., 125/255., 132./255., 1.
//    };
//    
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 54), YES, 0.0);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
//    
//    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, 54), kCGImageAlphaNoneSkipFirst);
//    
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//	
//	  CGGradientRelease(gradient);
//	  CGColorSpaceRelease(colorSpace);
//    UIGraphicsEndImageContext();
//    
//    return viewImage;
//}

#pragma mark -
#pragma Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Crop";
        
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
        label.text=self.navigationItem.title;
        label.textColor=[UIColor whiteColor];
        label.backgroundColor =[UIColor clearColor];
        label.adjustsFontSizeToFitWidth=YES;
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView=label;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [self.navigationController.navigationBar setHidden:NO];
//    appdelegate = (MingleloopAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self _setupNavigationBar];
    [self _setupCropView];

//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        [self.navigationController setNavigationBarHidden:YES];
//    } else {
//		[self.navigationController setNavigationBarHidden:NO];
//	}
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.imageCropView.frame = self.view.bounds;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
