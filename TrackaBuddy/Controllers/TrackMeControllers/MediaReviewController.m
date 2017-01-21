//
//  MediaReviewController.m
//  TrackaBuddy
//
//  Created by Alexander on 30/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "MediaReviewController.h"
#import "ViewUtils.h"
#import "UIImage+Crop.h"
#import "UIImage+Rotate.h"

@import AVFoundation;

@implementation MediaReviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _videoView.hidden = _isPhoto;
    _lblPassedTime.hidden = _isPhoto;
    _imageView.hidden = !_isPhoto;
    
    _btnUse.titleLabel.text = _isPhoto ? @"Use" : @"Save";

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (_isPhoto) {
        NSString *info = [NSString stringWithFormat:@"Size: %@  -  Orientation: %ld", NSStringFromCGSize(self.image.size), (long)self.image.imageOrientation];
        
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        self.infoLabel.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
        self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.text = info;
        [self.view addSubview:self.infoLabel];
        
        self.imageView.image = self.image;
    }
    else
    {
        self.avPlayer = [AVPlayer playerWithURL:self.videoUrl];
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.avPlayer currentItem]];
        
        self.avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoView.layer addSublayer:self.avPlayerLayer];
    }
    
    _lblPassedTime = [[UILabel alloc] init];
    _lblPassedTime.frame = CGRectMake((screenRect.size.width - 100) / 2 , 60, 100, 30);
    _lblPassedTime.clipsToBounds = YES;
    _lblPassedTime.layer.cornerRadius = 5;
    _lblPassedTime.text = @"00 : 00";
    _lblPassedTime.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    _lblPassedTime.textColor = [UIColor whiteColor];
    _lblPassedTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblPassedTime];
    _lblPassedTime.hidden = _isPhoto;
    
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPlay.frame = CGRectMake(0, 0, 80, 80);
    _btnPlay.center = self.view.center;
    _btnPlay.clipsToBounds = YES;
    [_btnPlay setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    _btnPlay.layer.cornerRadius = _btnPlay.width / 2.0f;
    _btnPlay.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnPlay.layer.borderWidth = 2.0f;
    _btnPlay.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _btnPlay.layer.shouldRasterize = YES;
    [_btnPlay addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnPlay];
    _btnPlay.hidden = _isPhoto;
    

    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUInteger radius = 0;
    
    switch ([UserDataSingleton sharedSingleton].currDeviceOrientation) {
        case UIDeviceOrientationPortrait:
            radius = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            radius = 90;
            break;
        case UIDeviceOrientationLandscapeRight:
            radius = 270;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        _btnRetake.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _btnUse.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _btnPlay.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        
//        _imageView.transform = CGAffineTransformMakeRotation(((360-radius) * M_PI) / 180);
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        _lblPassedTime.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        if ([UserDataSingleton sharedSingleton].currDeviceOrientation == UIDeviceOrientationLandscapeLeft) {
            _lblPassedTime.center = CGPointMake(screenRect.size.width - 25, (screenRect.size.height - 30) / 2);
        }
        else if ([UserDataSingleton sharedSingleton].currDeviceOrientation == UIDeviceOrientationLandscapeRight)
        {
            _lblPassedTime.center = CGPointMake(25, (screenRect.size.height - 30) / 2);
        }
        else
        {
            _lblPassedTime.center = CGPointMake(screenRect.size.width / 2, 25);
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [_videoTimer invalidate];
    _videoTimer = nil;
    
    _btnPlay.layer.opacity = 0;
    _btnPlay.hidden = NO;
    [UIView animateWithDuration:.5f animations:^{
        _btnPlay.layer.opacity = 1;
    } completion:^(BOOL finished) {
        
    }];
    
//    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.imageView.frame = self.view.contentBounds;
    
    [self.infoLabel sizeToFit];
    self.infoLabel.width = self.view.contentBounds.size.width;
    self.infoLabel.top = 0;
    self.infoLabel.left = 0;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRetakePressed:(id)sender {
//    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnUsePressed:(id)sender {
    if (_isPhoto) {
        
        UIImage * desImage;
        
        if ([UserDataSingleton sharedSingleton].orientationWhenCaptured == UIDeviceOrientationLandscapeLeft) {
            desImage = [self rotateImage:_image degrees:270];
        }
        else if ([UserDataSingleton sharedSingleton].orientationWhenCaptured == UIDeviceOrientationLandscapeRight)
        {
            desImage = [self rotateImage:_image degrees:90];
        }
        else
            desImage = _image;
        
        [UserDataSingleton sharedSingleton].imgOriginal = desImage;
        [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(desImage, 1.0);
        [self performSegueWithIdentifier:@"showImageFilterView2" sender:nil];
    }
    else
    {
        [_videoTimer invalidate];
        _videoTimer = nil;
        
        _btnPlay.layer.opacity = 0;
        _btnPlay.hidden = NO;
        [UIView animateWithDuration:.5f animations:^{
            _btnPlay.layer.opacity = 1;
        } completion:^(BOOL finished) {
            
        }];
        
        NSData * videoFile = [NSData dataWithContentsOfURL:_videoUrl];
        
        NSLog(@"file size : %.2f MB", (float)videoFile.length/1024.0f/1024.0f);

        if (videoFile) {
            if ([UserDataSingleton sharedSingleton].currSocialGeoPoint == nil) {
                [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't get location"];
                return;
            }
            [ProgressHUD show:@"Saving..."];
            
            [[UserDataSingleton sharedSingleton] saveVideoData:videoFile videoURL:_videoUrl completion:^(BOOL finished, NSError *error, NSString *mediaURL) {
                if (finished) {
                    [ProgressHUD showSuccess:@"Saved!"];
                    self.delegate = self.navigationController.viewControllers[0];
                    [self.delegate mediaReviewController:self didVideoSaved:YES mediaURL:mediaURL];
                    [self performSelector:@selector(showRootViewController) withObject:nil afterDelay:0.7f];
                }
                else
                {
                    [ProgressHUD showSuccess:@"Offline Saved!"];
                    self.delegate = self.navigationController.viewControllers[0];
                    [self.delegate mediaReviewController:self didVideoSaved:YES mediaURL:mediaURL];
                    [self performSelector:@selector(showRootViewController) withObject:nil afterDelay:0.7f];
                }
            }];
        }
    }
}

- (void)orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    NSUInteger radius = 0;
    
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            NSLog(@"orientation-Portrait");
            radius = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"orientation-LandscapeLeft");
            radius = 90;
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"orientation-LandscapeRight");
            radius = 270;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        _btnRetake.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _btnUse.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _btnPlay.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        _lblPassedTime.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        if (device.orientation == UIDeviceOrientationLandscapeLeft) {
            _lblPassedTime.center = CGPointMake(screenRect.size.width - 25, (screenRect.size.height - 30) / 2);
        }
        else if (device.orientation == UIDeviceOrientationLandscapeRight)
        {
            _lblPassedTime.center = CGPointMake(25, (screenRect.size.height - 30) / 2);
        }
        else
        {
            _lblPassedTime.center = CGPointMake(screenRect.size.width / 2, 25);
        }
    }];
}

- (void)playButtonPressed:(id)sender {
    
    AVPlayerItem * item = _avPlayer.currentItem;
    [item seekToTime:kCMTimeZero];
    _lblPassedTime.text = @"00 : 00";
    
    [self.avPlayer play];
    
    [UIView animateWithDuration:1.0f animations:^{
        _btnPlay.layer.opacity = 0;
    } completion:^(BOOL finished) {
        _btnPlay.hidden = YES;
    }];
    
    _passedTime = 0;
    _videoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calculatePassedVideoTime) userInfo:nil repeats:YES];
}

#pragma mark - Passed Video Time

- (void)calculatePassedVideoTime
{
    _passedTime++;
    NSString * text = _passedTime < 10 ? [NSString stringWithFormat:@"00 : 0%ld", (unsigned long)_passedTime] : [NSString stringWithFormat:@"00 : %ld", (unsigned long)_passedTime];
    _lblPassedTime.text = text;
}

#pragma mark - Image Rotation

- (UIImage *)rotateImage:(UIImage *)image degrees:(CGFloat)degress
{
    UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    NSLog(@"origin width : %f , height : %f", view.frame.size.width, view.frame.size.height);
    
    view.image = image;
    view.transform = CGAffineTransformMakeRotation((degress * M_PI) / 180);
    
    NSLog(@"after width : %f , height : %f", view.frame.size.width, view.frame.size.height);
    
    CGSize rotatedSize = view.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height/2);
    if (degress > 180) {
        CGContextScaleCTM(bitmap, 1.0, -1.0);
    }
    else
        CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width / 2, -rotatedSize.height / 2, rotatedSize.width, rotatedSize.height), [image CGImage]);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)showRootViewController
{
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
