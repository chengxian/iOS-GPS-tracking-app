//
//  MediaReviewController.h
//  TrackaBuddy
//
//  Created by Alexander on 30/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MediaReviewControllerDelegate;

@interface MediaReviewController : UIViewController

@property (strong, nonatomic) UILabel *                 infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *      imageView;
@property (strong, nonatomic) UIImage *                 image;
@property (weak, nonatomic) IBOutlet UIView *           videoView;
@property (strong, nonatomic) NSURL *                   videoUrl;
@property (strong, nonatomic) AVPlayer *                avPlayer;
@property (strong, nonatomic) AVPlayerLayer *           avPlayerLayer;
@property (assign, nonatomic) BOOL                      isPhoto;
@property (weak, nonatomic) IBOutlet UIButton *         btnRetake;
@property (weak, nonatomic) IBOutlet UIButton *         btnUse;
@property (strong, nonatomic) UILabel *                 lblPassedTime;
@property (strong, nonatomic) UIButton *                btnPlay;
@property (strong, nonatomic) NSTimer *                 videoTimer;
@property (assign, nonatomic) NSUInteger                passedTime;
@property (assign, nonatomic) UIDeviceOrientation       orientationWhenCaptured;

@property (strong, nonatomic) id<MediaReviewControllerDelegate> delegate;


//- (instancetype)initWithImage:(UIImage *)image;
//
//- (instancetype)initWithVideoUrl:(NSURL *)url;

- (IBAction)btnRetakePressed:(id)sender;

- (IBAction)btnUsePressed:(id)sender;

@end

@protocol MediaReviewControllerDelegate <NSObject>

- (void)mediaReviewController:(MediaReviewController *)mediaReviewController didVideoSaved:(BOOL)saved mediaURL:(NSString *)mediaURL;

@end