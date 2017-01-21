//
//  ShowGalleryViewController.h
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageFilterViewController.h"

@interface ShowGalleryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,GKImagePickerDelegate, GKImageCropControllerDelegate,VPImageCropperDelegate>
{
    UIImageView *recipeImageView;
    BOOL resizeableCropArea;
    
    NSMutableArray *assetGroups;
	NSOperationQueue *queue;
	id parent;
    ALAssetsLibrary *library;
    ALAssetsGroup *assetGroup;
    int selectedAssets;
    BOOL boolGo;
}

//Properties
@property (weak, nonatomic) IBOutlet UICollectionView *clView;

//Actions
- (IBAction)btnCancelPressed:(id)sender;
@end

