	//
//  TakePhotoOptionsViewController.m
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import "TakePhotoOptionsViewController.h"
#import "ImageFilterViewController.h"

@implementation TakePhotoOptionsViewController

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
//    appdelegate.arrImageData = [[NSMutableArray alloc] init];
    [self.navigationController.navigationBar setHidden:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];

}

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!isCamreaLoaded) {
        [self performSelector:@selector(initCamera) withObject:nil afterDelay:0.0f];
        isCamreaLoaded = YES;
    }
}

-(IBAction)btnCancelPress:(id)sender
{
//    NSLog(@"Image : %@",appdelegate.arrAlAssistData);
    [UserDataSingleton sharedSingleton].strPhotoOptions = @"";
//    appdelegate.arrFinalSelect = [[NSMutableArray alloc] init];
//    appdelegate.arrFinalDes = [[NSMutableArray alloc] init];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnPickerCancelPress:(id)sender
{
    [UserDataSingleton sharedSingleton].strPhotoOptions = @"";
//    if (appdelegate.arrFinalSelect.count > 0)
//    {
//        [picker1 dismissViewControllerAnimated:YES completion:nil];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else
//    {
//        [picker1 dismissViewControllerAnimated:YES completion:nil];
//    }
    [picker1 dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(IBAction)btnFlash:(id)sender
{
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil)
    {
        if ([device hasTorch] && [device hasFlash])
        {
            [device lockForConfiguration:nil];
            if (iFlash == 2)
            {
                [device setFlashMode:AVCaptureFlashModeOn];
                picker1.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
                [btnFlash setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
                iFlash =3;
            }
            else if (iFlash == 3)
            {
                [device setFlashMode:AVCaptureFlashModeOff];
                picker1.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                [btnFlash setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
                iFlash =1;
            }
            else
            {
                [device setFlashMode:AVCaptureFlashModeAuto];
                picker1.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
                [btnFlash setImage:[UIImage imageNamed:@"flash_auto.png"] forState:UIControlStateNormal];
                iFlash =2;
            }
            [device unlockForConfiguration];
        }
    }
}

-(IBAction)Capture:(id)sender
{
    [picker1 takePicture];
}

-(IBAction)btnSwitchCamera:(id)sender
{
    if(picker1.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        picker1.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else
    {
        picker1.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage
{
    
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [self.navigationController.navigationBar setHidden:YES];
//    if (appdelegate.strEditIndex.length == 0 && [appdelegate.strPhotoOptions isEqualToString:@"CAMERA"]) {
//        editedImage=[editedImage imageRotatedByDegrees:90];
//    }
    
    editedImage = [editedImage resizedImageToSize:CGSizeMake(600,600)];
    [UserDataSingleton sharedSingleton].imgOriginal = editedImage;
    [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(editedImage, 1.0);
    
    if ([UserDataSingleton sharedSingleton].boolAddPhoto) {
        [self performSegueWithIdentifier:@"showImageFilterView" sender:nil];
    } else {
        if ([UserDataSingleton sharedSingleton].strEditIndex.length > 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self performSegueWithIdentifier:@"showImageFilterView" sender:nil];
        }
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didSavedImage:(BOOL)saved
{
    
}

#pragma mark -
#pragma mark ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *resizeImage = [[UserDataSingleton sharedSingleton] squareImageWithImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"] scaledToSize:CGSizeMake(300, 300)];
    resizeImage = [resizeImage resizedImageToSize:CGSizeMake(600,600)];
    [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1.0f);
	[picker dismissViewControllerAnimated:NO completion:^{
//        CGSize cropSize = CGSizeMake(300, 300);
//        resizeableCropArea = YES;
//        GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
//        cropController.contentSizeForViewInPopover = cropController.contentSizeForViewInPopover;
//        cropController.sourceImage = [UIImage imageWithData:appdelegate.MediaData];
//        cropController.resizeableCropArea = resizeableCropArea;
//        cropController.cropSize = cropSize;
//        cropController.delegate = self;
//        [self.navigationController pushViewController:cropController animated:YES];
        
//        [self.navigationController.navigationBar setHidden:YES];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"] cropFrame:CGRectMake(10, 80.0f, 300, 300) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self.navigationController pushViewController:imgCropperVC animated:YES];
        
        isCamreaLoaded = NO;
    }];
}

-(void)handleNotification:(NSNotification *)message {
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        // Remove overlay, so that it is not available on the preview view;
        picker1.cameraOverlayView = nil;
    }
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        // Retake button pressed on preview. Add overlay, so that is available on the camera again
        picker1.cameraOverlayView = overlay;
    }
}

-(UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Actions

- (void)initCamera
{
#if TARGET_IPHONE_SIMULATOR
    [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Camera is not available"];
#elif TARGET_OS_IPHONE
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [UserDataSingleton sharedSingleton].strPhotoOptions = @"CAMERA";
        picker1 = [[UIImagePickerController alloc] init];
        picker1.delegate = self;
        picker1.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker1.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        picker1.showsCameraControls = NO;
        picker1.cameraOverlayView = overlay;
        picker1.allowsEditing = YES;
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [btnFlash setImage:[UIImage imageNamed:@"flash_auto.png"] forState:UIControlStateNormal];
        if ([device hasTorch] && [device hasFlash])
        {
            [device setFlashMode:AVCaptureFlashModeAuto];
            iFlash = 2;
        }
        [self presentViewController:picker1 animated:NO completion:nil];
    }
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
