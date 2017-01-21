//
//  ImageFilterViewController.m
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import "ImageFilterViewController.h"

@implementation ImageFilterViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _srcImage = [UIImage imageWithData:[UserDataSingleton sharedSingleton].MediaData];
    
    _imgPic.layer.borderColor = [UIColor whiteColor].CGColor;
    _imgPic.layer.borderWidth = 1;
   
    _library = [[ALAssetsLibrary alloc] init];
//    _currTrack = [UserDataSingleton sharedSingleton].currTrack;
    
    [self performSelector:@selector(setupCropVivew) withObject:nil afterDelay:0.3f];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    
    _imgPic.image = [UIImage imageWithData:[UserDataSingleton sharedSingleton].MediaData];

    NSLog(@"Height : %f",_imgPic.image.size.height);
    NSLog(@"width : %f",_imgPic.image.size.width);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)showRootView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Crop View
- (void)setupCropVivew
{
//    self.photoView = [[PhotoTweakView alloc] initWithFrame:self.view.bounds image:self.image];
    _cropImage = [UIImage imageWithData:[UserDataSingleton sharedSingleton].MediaData];
    self.photoView = [[PhotoTweakView alloc] initWithFrame:_cropContentView.bounds image:_cropImage];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_cropContentView addSubview:self.photoView];
}


#pragma mark - Crop Methods

- (void)dealloc {
    self.originalImage = nil;
    self.editedImage = nil;
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [self newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}

#pragma mark - Actions

-(IBAction)btnFilterPressed:(id)sender
{
    [self performSegueWithIdentifier:@"showImageAddEffectsView" sender:nil];
}

- (IBAction)btnCropPressed:(id)sender {
    _cropView.hidden = NO;
    _filterView.hidden = YES;
}

- (IBAction)btnCropUseButtonPressed:(id)sender {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // translate
    CGPoint translation = [self.photoView photoTranslation];
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    // rotate
    transform = CGAffineTransformRotate(transform, self.photoView.angle);
    
    // scale
    CGAffineTransform t = self.photoView.photoContentView.transform;
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);
    
    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:self.cropImage.CGImage
                                         sourceSize:self.cropImage.size
                                  sourceOrientation:self.cropImage.imageOrientation
                                        outputWidth:self.cropImage.size.width
                                           cropSize:self.photoView.cropView.frame.size
                                      imageViewSize:self.photoView.photoContentView.bounds.size];
    
    UIImage * editedImage = [UIImage imageWithCGImage:imageRef];
    [UserDataSingleton sharedSingleton].imgOriginal = editedImage;
    [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(editedImage, 1.0);
    _imgPic.image = [UIImage imageWithData:[UserDataSingleton sharedSingleton].MediaData];
    CGImageRelease(imageRef);
    
    _cropView.hidden = YES;
    _filterView.hidden = NO;
}

- (IBAction)btnCropCancelPressed:(id)sender {
    _cropView.hidden = YES;
    _filterView.hidden = NO;
}

- (IBAction)btnCropResetPressed:(id)sender {
    [_photoView resetBtnTapped:sender];
}

-(IBAction)btnCancelPressed:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)btnSavePressed:(id)sender
{
    
//    UIImageOrientationUp
    
    [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(_imgPic.image, 1.0f);
    
//    _tempImg.image = [UIImage imageWithData:[UserDataSingleton sharedSingleton].MediaData];
    
//    NSLog(@"image orientation : %d", _imgPic.image.imageOrientation);
    
    if ([UserDataSingleton sharedSingleton].currSocialGeoPoint == nil) {
        [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't get location"];
        return;
    }
    
    [ProgressHUD show:@"Saving..."];
    _isDismissed = NO;
    
    [[UserDataSingleton sharedSingleton] saveImageData:_imgPic.image completion:^(BOOL finished, NSError *error, NSString * mediaURL) {
        if (finished) {
            [ProgressHUD showSuccess:@"Saved!"];
            self.delegate = self.navigationController.viewControllers[0];
            [self.delegate imageFilterController:self didPictureSaved:YES mediaURL:mediaURL];
            [self performSelector:@selector(showRootView) withObject:nil afterDelay:0.7f];
        }
        else if (!finished && mediaURL != nil)
        {
            [ProgressHUD showSuccess:@"Offline Saved!"];
            self.delegate = self.navigationController.viewControllers[0];
            [self.delegate imageFilterController:self didPictureSaved:YES mediaURL:mediaURL];
            [self performSelector:@selector(showRootView) withObject:nil afterDelay:0.7f];
        }
        else if (!finished && error != nil)
        {
            [ProgressHUD showError:@"Save Error! Please retry"];
            return;
        }
    }];
}


#pragma mark - Methods

//dismissHUB
//-------------------------------------------------------------------------------------------------------------------------------------------------------# dismissHUB

- (void)dismissHUB
{
    [ProgressHUD showSuccess:@"Saved!"];
    self.delegate = self.navigationController.viewControllers[0];
    [self.delegate imageFilterController:self didPictureSaved:YES mediaURL:nil];
    [self performSelector:@selector(showRootView) withObject:nil afterDelay:0.7f];
    _isDismissed = YES;
    
    [_dismissHUBTimer invalidate];
    _dismissHUBTimer = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------# dismissHUB


@end
