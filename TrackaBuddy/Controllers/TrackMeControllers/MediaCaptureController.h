//
//  MediaCaptureController.h
//  TrackaBuddy
//
//  Created by Alexander on 29/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import "ViewUtils.h"

@interface MediaCaptureController : UIViewController

@property (strong, nonatomic) LLSimpleCamera *        camera;
@property (strong, nonatomic) UIButton *              backButton;
@property (strong, nonatomic) UIButton *              snapButton;
@property (strong, nonatomic) UIButton *              switchButton;
@property (strong, nonatomic) UIButton *              flashButton;
@property (strong, nonatomic) UIButton *              galleryButton;
@property (strong, nonatomic) UISegmentedControl *    segmentedControl;
@property (strong, nonatomic) UIView *                controlContainer;
@property (strong, nonatomic) UIView *                controlContainer1;
@property (strong, nonatomic) NSTimer *               videoTimer;
@property (strong, nonatomic) UILabel *               lblPassedTime;
@property (assign, nonatomic) NSUInteger              passedTime;

@property (strong, nonatomic) UIImage *               capturedImage;
@property (strong, nonatomic) NSURL *                 capturedVideoURL;

- (void) snapButtonPressed:(id)sender;
- (void) flashButtonPressed:(id)sender;
- (void) cameraButtonPressed:(id)sender;
- (void) segmentValueChanged:(id)sender;
- (void) backButtonPressed:(id)sender;
@end
