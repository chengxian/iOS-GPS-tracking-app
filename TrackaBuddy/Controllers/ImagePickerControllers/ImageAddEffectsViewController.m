//
//  ImageAddEffectsViewController.m
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#define kFilterImageViewTag 9999
#define kFilterImageViewContainerViewTag 9998
#define kBlueDotImageViewOffset 25.0f
#define kFilterCellHeight 72.0f
#define kBlueDotAnimationTime 0.2f
#define kFilterTableViewAnimationTime 0.2f
#define kGPUImageViewAnimationOffset 27.0f

#import "ImageAddEffectsViewController.h"

@implementation ImageAddEffectsViewController
@synthesize scrlEffect,imageAfter;
@synthesize videoCamera,currentType,isHighQualityVideo;
@synthesize filter;

//MingleloopAppDelegate *appdelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    appdelegate = (MingleloopAppDelegate*)[UIApplication sharedApplication].delegate;
    
    arrImage = [[NSArray alloc] initWithObjects:@"normal.png",@"amaro.png",@"rise.png",@"hudson.png",@"X-pro.png",@"sierra.png",@"lo-fi.png",@"earlybird.png",@"sutro.png",@"toaster.png",@"brannan.png",@"inkwell.png",@"walden.png",@"hefe.png",@"valencia.png",@"nashville.png",@"1977.png",@"kelvin.png", nil];
    
    arrName = [[NSArray alloc] initWithObjects:@"Normal",@"Amaro",@"Rise",@"Hudson",@"X-Pro",@"Sierra",@"Lo-Fi",@"Earlybird",@"Sutro",@"Toaster",@"Brannan",@"Inkwell",@"Walden",@"Hefe",@"Valencia",@"Nashville",@"1977",@"Kelvin", nil];
    
    self.videoCamera = [[IFVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack highVideoQuality:self.isHighQualityVideo];
    self.videoCamera.delegate = self;
    self.videoCamera.gpuImageView.inputView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.videoCamera.gpuImageView];
    
    linkedImage = [UserDataSingleton sharedSingleton].imgOriginal;
    
    self.videoCamera.rawImage = linkedImage;
    [self.videoCamera takePhoto:linkedImage];
    [self.videoCamera switchFilter:currentType];
    
//    self.videoCamera.gpuImageView.frame = CGRectMake(0, 0, 200, 100);
//    [self.view addSubview:self.videoCamera.gpuImageView];
    
    CGRect fff = self.videoCamera.gpuImageView.frame;
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        fff.origin.y = 80;
    }
    else
    {
        fff.origin.y = 120;
    }
    
   
    NSLog(@"x : %f, y : %f, width : %f, height : %f", fff.origin.x, fff.origin.y, fff.size.width, fff.size.height);
//    NSLog(@"raw Image width : %f, height %f", self.videoCamera.rawImage.size.width, self.videoCamera.rawImage.size.height);
//    NSLog(@"x : %f, y : %f, width : %f, height : %f", fff.origin.x, fff.origin.y, fff.size.width, fff.size.height);
//    if (appdelegate.strEditIndex.length == 0) {
//        if ([appdelegate.strPhotoOptions isEqualToString:@"CAMERA"]) {
//            self.videoCamera.gpuImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
//        }
//    }
   
   
    [UIView animateWithDuration:kFilterTableViewAnimationTime animations:^(){
        self.videoCamera.gpuImageView.frame = fff;        
        self.videoCamera.gpuImageView.layer.borderWidth = 1;
        self.videoCamera.gpuImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    int x=10;
    
    for (int i = 0; i<18; i++)
    {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(x, 10, 80, 80)];
        img.image = [UIImage imageNamed:[arrImage objectAtIndex:i]];
        img.tag = i+1;
        [scrlEffect addSubview:img];
        
        if (i==0)
        {
            img.layer.cornerRadius=0;
            img.layer.masksToBounds = YES;
            img.layer.borderColor = [UIColor colorWithRed:20/255.0 green:193/255.0 blue:193/255.0 alpha:1.0].CGColor;
            img.layer.borderWidth = 2.0;
        }
        
        UILabel *lbl = [[UILabel alloc] init];
        if ([[UIScreen mainScreen] bounds].size.height == 480)
        {
            lbl.frame = CGRectMake(x, 75, 80, 15);
        }
        else
        {
            lbl.frame = CGRectMake(x, 105, 80, 15);
        }
        
        lbl.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.tag = i+1;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = [arrName objectAtIndex:i];
        [scrlEffect addSubview:lbl];
        
        UITapGestureRecognizer *ImagetapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTapGestureRecognizer:)];
        ImagetapGestureRecognize.numberOfTapsRequired = 1;
        [img setUserInteractionEnabled:YES];
        [img addGestureRecognizer:ImagetapGestureRecognize];
        
        x += 90;
    }
    
    NSInteger width = [UserDataSingleton sharedSingleton].screenWidth;
    NSInteger height = [UserDataSingleton sharedSingleton].screenHeight;
    

    self.view.frame = CGRectMake(0, 0, width, height);
    if (height == 480)
    {
//        self.view.frame = CGRectMake(0, 0, 320, 480);
        scrlEffect.frame = CGRectMake(0, 380, 320, 100);
        scrlEffect.contentSize = CGSizeMake(x, 100);
        _scrlEffectHeightConstraint.constant = 100;
    }
    else
    {
        scrlEffect.contentSize = CGSizeMake(x, 135);
    }
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

-(void)ImageTapGestureRecognizer:(UITapGestureRecognizer*)sender
{
    NSArray *arr = [scrlEffect subviews];
    for (int k=0; k<[arr count]; k++)
    {
        if ([[arr objectAtIndex:k] isKindOfClass:[UIImageView class]])
        {
            UIImageView *img = [arr objectAtIndex:k];
            if (sender.view.tag == img.tag)
            {
                img.layer.cornerRadius=0;
                img.layer.masksToBounds = YES;
                img.layer.borderColor = [UIColor colorWithRed:20/255.0 green:193/255.0 blue:193/255.0 alpha:1.0].CGColor;
                img.layer.borderWidth = 2.0;
                
                self.currentType = (IFFilterType)sender.view.tag - 1;
                [self.videoCamera switchFilter:(IFFilterType)sender.view.tag - 1];
            }
            else
            {
                img.layer.cornerRadius=0;
                img.layer.masksToBounds = NO;
                img.layer.borderColor = [UIColor clearColor].CGColor;
                img.layer.borderWidth = 0.0;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnCancelPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnDonePress:(id)sender
{
    [self.videoCamera saveCurrentStillImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
