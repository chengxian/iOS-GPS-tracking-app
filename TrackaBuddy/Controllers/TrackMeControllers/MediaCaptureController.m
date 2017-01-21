//
//  MediaCaptureController.m
//  TrackaBuddy
//
//  Created by Alexander on 29/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "MediaCaptureController.h"
#import "MediaReviewController.h"
#import "ShowGalleryViewController.h"

@implementation MediaCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self initCameraWithQuality:AVCaptureSessionPresetPhoto];
    
    [self setButtonControlPanel];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)setButtonControlPanel
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    _controlContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
    _controlContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    
    _controlContainer1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 90)];
    _controlContainer1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    _controlContainer1.bottom = screenRect.size.height;
    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake((screenRect.size.width - 70) / 2, 10, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer1 addSubview:self.snapButton];
    
    
    //button to gallery
    self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.galleryButton.frame = CGRectMake(20, 5, 40.0f, 40.0f);
    [self.galleryButton setImage:[UIImage imageNamed:@"btn_gallery"] forState:UIControlStateNormal];
    self.galleryButton.clipsToBounds = YES;
    self.galleryButton.frame = CGRectMake(8, 19, 40.f, 40.f);
    self.galleryButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.galleryButton addTarget:self action:@selector(galleryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer1 addSubview:self.galleryButton];
    
    //button to previous view
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(8, 5, 40.f, 40.f);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer addSubview:self.backButton];
    
    // button to toggle camera positions
    self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.switchButton.frame = CGRectMake(0, 10, 30.0f, 30.0f);
    self.switchButton.right = _controlContainer.frame.size.width - 8;
    self.switchButton.tintColor = [UIColor whiteColor];
    [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
    [self.switchButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer addSubview:self.switchButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 10, 30.0f, 30.0f);
    self.flashButton.right = self.switchButton.left - 8;
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash.png"] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer addSubview:self.flashButton];
    
    
    //Video, Phto segment
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Picture",@"Video"]];
    self.segmentedControl.center = _controlContainer.center;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_controlContainer addSubview:self.segmentedControl];
    
    //lavel to show the passed time.
    self.lblPassedTime = [[UILabel alloc] init];
    self.lblPassedTime.frame = CGRectMake((screenRect.size.width - 100) / 2 , 60, 100, 30);
    self.lblPassedTime.clipsToBounds = YES;
    self.lblPassedTime.layer.cornerRadius = 5;
    self.lblPassedTime.text = @"00 : 00";
    self.lblPassedTime.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    self.lblPassedTime.textColor = [UIColor whiteColor];
    self.lblPassedTime.textAlignment = NSTextAlignmentCenter;
    self.lblPassedTime.hidden = YES;
    
    [self.view addSubview:self.lblPassedTime];
    
    [self.view addSubview:_controlContainer];
    [self.view addSubview:_controlContainer1];
}

- (void)initCameraWithQuality:(NSString * )quality
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:quality
                                                 position:CameraPositionBack
                                             videoEnabled:YES];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == CameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
//    [_controlContainer bringSubviewToFront:self.view];
//    [_controlContainer1 bringSubviewToFront:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
//    if (_segmentedControl.selectedSegmentIndex == 0) {
//        self.camera.cameraQuality = AVCaptureSessionPresetPhoto;
//    }
//    else
//    {
//        self.camera.cameraQuality = AVCaptureSessionPresetMedium;
//    }
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // stop the camera
    [self.camera stop];
}

/* other lifecycle methods */
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.camera.view.frame = self.view.contentBounds;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}

- (void)snapButtonPressed:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        // capture
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                
                // we should stop the camera, since we don't need it anymore. We will open a new vc.
                // this very important, otherwise you may experience memory crashes
                [camera stop];
                
                // show the image
                _capturedImage = image;
                [UserDataSingleton sharedSingleton].orientationWhenCaptured = [UserDataSingleton sharedSingleton].currDeviceOrientation;
                [self performSegueWithIdentifier:@"showImageReviewController" sender:self];
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];
    }
    else {
        
        if(!self.camera.isRecording) {
            self.segmentedControl.hidden = YES;
            self.flashButton.hidden = YES;
            self.switchButton.hidden = YES;
            
            self.snapButton.layer.borderColor = [UIColor redColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
            
            // start recording
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
            
            [self.camera startRecordingWithOutputUrl:outputURL];
            
            _passedTime = 0;
            _videoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calculatePassedVideoTime) userInfo:nil repeats:YES];
        }
        else
        {
            if (_passedTime > 5) {
                [_videoTimer invalidate];
                _videoTimer = nil;
                
                _passedTime = 0;
                _lblPassedTime.text = @"00 : 00";
                
                self.segmentedControl.hidden = NO;
                self.flashButton.hidden = NO;
                self.switchButton.hidden = NO;
                
                self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
                self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
                
                [self.camera stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                    _capturedVideoURL = outputFileUrl;
                    [self performSegueWithIdentifier:@"showVideoReviewController" sender:nil];
                }];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please record more than 5 secs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
        }
    }
}

- (void)flashButtonPressed:(id)sender {
    if(self.camera.flash == CameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:CameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:CameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (void)cameraButtonPressed:(id)sender {
    [self.camera togglePosition];
}

- (void)segmentValueChanged:(id)sender {
    NSLog(@"Segment value changed!");
    _galleryButton.hidden = _segmentedControl.selectedSegmentIndex == 1;
    _lblPassedTime.hidden = _segmentedControl.selectedSegmentIndex == 0;
}

- (void)backButtonPressed:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)galleryButtonPressed:(id)sender {
    NSLog(@"gallery Button Pressed");
    
    [self performSegueWithIdentifier:@"showGalleryViewController" sender:nil];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - UIDevice OrientationChanged

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
    
    [UIView animateWithDuration:.5f animations:^{
        _backButton.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _switchButton.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _flashButton.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        _galleryButton.transform = CGAffineTransformMakeRotation((radius * M_PI) / 180);
        
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
            _lblPassedTime.center = CGPointMake(screenRect.size.width / 2, 75);
        }
    }];
    
}

#pragma mark - UINavigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showImageReviewController"]) {
        NSLog(@"showImageReviewController");
        MediaReviewController * vc = segue.destinationViewController;
        vc.image = _capturedImage;
        vc.isPhoto = YES;
    }
    else if ([[segue identifier] isEqualToString:@"showVideoReviewController"]) {
        NSLog(@"showVideoReviewController");
        MediaReviewController * vc = segue.destinationViewController;
        vc.videoUrl = _capturedVideoURL;
        vc.isPhoto = NO;
    }
}

#pragma mark - Passed Video Time

- (void)calculatePassedVideoTime
{
    if (_passedTime < 60) {
        _passedTime++;
        NSString * text = _passedTime < 10 ? [NSString stringWithFormat:@"00 : 0%ld", (unsigned long)_passedTime] : [NSString stringWithFormat:@"00 : %ld", (unsigned long)_passedTime];
        _lblPassedTime.text = text;
    }
    else
    {
        [_videoTimer invalidate];
        _videoTimer = nil;
        
        [self snapButtonPressed:nil];
    }
}

@end
