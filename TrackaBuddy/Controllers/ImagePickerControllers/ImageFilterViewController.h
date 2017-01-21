//
//  ImageFilterViewController.h
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageAddEffectsViewController.h"
#import "ShowGalleryViewController.h"
#import "PhotoTweakView.h"
#import "UIColor+Tweak.h"
#import "ALAssetsLibrary+CustomAlbum.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

@protocol ImageFilterViewControllerDelegate;
@protocol PhotoTweaksViewControllerDelegate;

@interface ImageFilterViewController : UIViewController

@property (strong, nonatomic) UIImage *                                 srcImage;
@property (strong, nonatomic) UIImage *                                 cropImage;
@property (weak, nonatomic) IBOutlet UIView *                           filterView;
@property (weak, nonatomic) IBOutlet UIView *                           cropView;
@property (weak, nonatomic) IBOutlet UIView *                           cropContentView;

@property (weak, nonatomic) IBOutlet UIImageView *                      imgPic;
@property (strong, nonatomic) PFObject *                                currTrack;
@property (strong, nonatomic) ALAssetsLibrary *                         library;
@property (strong, nonatomic) id<ImageFilterViewControllerDelegate>     delegate;
@property (nonatomic, weak) id<PhotoTweaksViewControllerDelegate>       delegate1;

//Crop

@property (strong, nonatomic) PhotoTweakView *                          photoView;
@property (nonatomic, retain) UIImage *                                 originalImage;
@property (nonatomic, retain) UIImage *                                 editedImage;
@property (strong, nonatomic) NSTimer *                                 dismissHUBTimer;
@property (assign, nonatomic) BOOL                                      isDismissed;
@property (weak, nonatomic) IBOutlet UIImageView *tempImg;

//Crop Actions
- (IBAction)btnCropPressed:(id)sender;

- (IBAction)btnCropUseButtonPressed:(id)sender;

- (IBAction)btnCropCancelPressed:(id)sender;

- (IBAction)btnCropResetPressed:(id)sender;

//Filter Actions
-(IBAction)btnSavePressed:(id)sender;

-(IBAction)btnFilterPressed:(id)sender;

-(IBAction)btnCancelPressed:(id)sender;

@end

@protocol ImageFilterViewControllerDelegate <NSObject>

- (void)imageFilterController:(ImageFilterViewController *)imageFilterController didPictureSaved:(BOOL)saved mediaURL:(NSString *)mediaURL;

@end

@protocol PhotoTweaksViewControllerDelegate <NSObject>

/**
 Called on image cropped.
 */
- (void)photoTweaksController:(ImageFilterViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage;
/**
 Called on cropping image canceled
 */
- (void)photoTweaksControllerDidCancel:(ImageFilterViewController *)controller;

@end
