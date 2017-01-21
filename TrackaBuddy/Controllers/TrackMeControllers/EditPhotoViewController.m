//
//  EditPhotoViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 20/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "EditPhotoViewController.h"

@implementation EditPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _imgContent.layer.borderWidth = 1;
//    _imgContent.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if (_isLocal) {
        NSString * mediaurl = _urlString;
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                UIImage * image = [UIImage imageWithCGImage:iref scale:1.0 orientation:(UIImageOrientation)[rep orientation]];
                NSLog(@"image orientation : %d", image.imageOrientation);
                _imgContent.image = image;
            }
        };
        
        //
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
        };
        
        if(mediaurl && [mediaurl length])
        {
            NSURL *asseturl = [NSURL URLWithString:mediaurl];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl
                           resultBlock:resultblock
                          failureBlock:failureblock];
        }
    }
    else
    {
        if (_imgFile) {
            _imgContent.file = _imgFile;
            
            [ProgressHUD show:@""];
            
            [_imgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    _imgContent.image = [UIImage imageWithData:data];
                    [ProgressHUD dismiss];
                }
            }];
            
//            [ProgressHUD show:@""];
//            [_imgContent loadInBackground:^(UIImage *image, NSError *error) {
//                if (!error) {
//                    [ProgressHUD dismiss];
//                }
//            }];
        }
    }
    _isPortrateImage = NO;
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIApplication * application = [UIApplication sharedApplication];
    [application setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Orientation
//
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    if (_isPortrateImage) {
//        NSLog(@"PortrateImage");
//    }
//    else
//        NSLog(@"LandscapeImage");
//    
//    NSUInteger orientation = (_isPortrateImage == YES) ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskLandscape;
//    return orientation;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions

#pragma mark - Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Public Method

- (void)setPhotoFromAssets:(NSString *)urlString;
{
    _isLocal = YES;
    
    if (urlString) {
        _urlString = urlString;
    }
}

- (void)setPhotoFileFromRemote:(PFFile *)imgFile
{
    _isLocal = NO;
    
    if (imgFile) {
        _imgFile = imgFile;
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Public Method

@end
