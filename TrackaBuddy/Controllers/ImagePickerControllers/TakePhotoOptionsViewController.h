//
//  TakePhotoOptionsViewController.h
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePhotoOptionsViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,GKImagePickerDelegate, GKImageCropControllerDelegate,VPImageCropperDelegate>
{
    IBOutlet UIButton *btnCancle;
    IBOutlet UIView *overlay;
    IBOutlet UIView *viewBottom;
    IBOutlet UIImageView *imgOverlayBg;
    UIImagePickerController *picker1;
    int iTag;
    
    BOOL isCamreaLoaded;
    
    BOOL resizeableCropArea;
    IBOutlet UIButton *btnFlash;
    AVCaptureDevice *device;
    int iFlash;
}

-(IBAction)btnCancelPress:(id)sender;
-(IBAction)btnPickerCancelPress:(id)sender;
-(IBAction)btnFlash:(id)sender;
-(IBAction)btnSwitchCamera:(id)sender;
-(IBAction)Capture:(id)sender;

@end
