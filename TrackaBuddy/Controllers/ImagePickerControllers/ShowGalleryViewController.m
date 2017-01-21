//
//  ShowGalleryViewController.m
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import "ShowGalleryViewController.h"

@implementation ShowGalleryViewController

//MingleloopAppDelegate *appdelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelPress:)];
        [self.navigationItem setLeftBarButtonItem:button animated:NO];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    appdelegate=(MingleloopAppDelegate*)[UIApplication sharedApplication].delegate;
    
    UIImageView *imageview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toplogo.png"]];
    self.navigationItem.titleView = imageview;
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height==480)
    {
        self.view.frame = CGRectMake(0, 0, 320, 480);
        _clView.frame = CGRectMake(0, 64, 320, 416);
    }
    else
    {
        _clView.frame = CGRectMake(0, 64, 320, 504);
    }
    
    layout.sectionInset=UIEdgeInsetsMake(5, 5, 5, 5);
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [_clView setDataSource:self];
    [_clView setDelegate:self];
    _clView.backgroundColor=[UIColor clearColor];
    _clView.showsHorizontalScrollIndicator = NO;
    _clView.showsVerticalScrollIndicator = NO;
    [_clView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
}

-(void)viewWillAppear:(BOOL)animated
{
    if([[UIScreen mainScreen] bounds].size.height == 480)
    {
        self.view.frame=CGRectMake(0, 0,320, 480);
    }
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [UserDataSingleton sharedSingleton].arrImageData = [[NSMutableArray alloc] init];
    [UserDataSingleton sharedSingleton].arrAlAssistData = [[NSMutableArray alloc] init];
    assetGroups = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	assetGroups = tempArray;
    
    boolGo = YES;
    
    library = [[ALAssetsLibrary alloc] init];
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (group == nil)
                           {
                               return;
                           }
                           
                           [assetGroups addObject:group];
                           //NSLog(@"assetGroups : %@",assetGroups);
                           assetGroup=[assetGroups objectAtIndex:0];
                           if ([assetGroups count] > 0)
                           {
                               [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
                           }
                           
                       };
                       
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           
                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                           [alert show];
                           
                           NSLog(@"A problem occured %@", [error description]);
                       };
                       
                       // Enumerate Albums
                       [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                              usingBlock:assetGroupEnumerator
                                            failureBlock:assetGroupEnumberatorFailure];
                       
                   });
}

-(void)preparePhotos
{
    [assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if(result == nil)
         {
             return;
         }
         
         //NSDate* date = [result valueForProperty:ALAssetPropertyDate];
         [[UserDataSingleton sharedSingleton].arrAlAssistData addObject:result];
         NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
         UIImage *fullScreenImage = [UIImage imageWithCGImage:[result thumbnail]];
         [workingDictionary setObject:fullScreenImage forKey:@"UIImagePickerControllerOriginalImage"];
         [[UserDataSingleton sharedSingleton].arrImageData addObject:workingDictionary];
     }];
    
    [UserDataSingleton sharedSingleton].arrAlAssistData = [[[[UserDataSingleton sharedSingleton].arrAlAssistData reverseObjectEnumerator] allObjects] mutableCopy];
    
    [UserDataSingleton sharedSingleton].arrImageData = [[[[UserDataSingleton sharedSingleton].arrImageData reverseObjectEnumerator] allObjects] mutableCopy];
    
    [_clView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self.navigationController.navigationBar setHidden:YES];
}

-(void)viewDidUnload
{
    assetGroups = nil;
    assetGroup = nil;
    library = nil;
}

-(void)btnNextPress:(id)sender
{
//    FinalImagesViewController *final = [[FinalImagesViewController alloc] initWithNibName:@"FinalImagesViewController" bundle:nil];
//    [self.navigationController pushViewController:final animated:YES];
}

-(void)btnCancelPress:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [self.navigationController.navigationBar setHidden:YES];
    if ([UserDataSingleton sharedSingleton].strEditIndex.length == 0 && [[UserDataSingleton sharedSingleton].strPhotoOptions isEqualToString:@"CAMERA"]) {
        editedImage=[editedImage imageRotatedByDegrees:90];
    }
    
    [UserDataSingleton sharedSingleton].imgOriginal = editedImage;
    [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(editedImage, 1.0);
    if ([UserDataSingleton sharedSingleton].boolAddPhoto) {
        [self performSegueWithIdentifier:@"showImageFilterView1" sender:nil];
    } else {
        if ([UserDataSingleton sharedSingleton].strEditIndex.length > 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self performSegueWithIdentifier:@"showImageFilterView1" sender:nil];
        }
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Collection view delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[UserDataSingleton sharedSingleton].arrImageData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    NSInteger cellWidth = _clView.frame.size.width / 3 - 10;
    
    recipeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth)];
    [recipeImageView setImage:[[[UserDataSingleton sharedSingleton].arrImageData objectAtIndex:indexPath.row] objectForKey:@"UIImagePickerControllerOriginalImage"]];
    [cell.contentView addSubview:recipeImageView];
    
//    if ([[appdelegate.dictSelect objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] isEqualToString:@"1"])
//    {
//        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(75, 76, 18, 18)];
//        img.image = [UIImage imageNamed:@"pc_done.png"];
//        [recipeImageView addSubview:img];
//    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PressUsers:)];
    [singleTap setDelaysTouchesBegan : YES];
    [singleTap setNumberOfTapsRequired : 1];
    [recipeImageView addGestureRecognizer : singleTap];
    recipeImageView.userInteractionEnabled = YES;
    recipeImageView.tag = indexPath.row;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellWidth = _clView.frame.size.width / 3 - 10;
    return CGSizeMake(cellWidth, cellWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark - Select Image from UICollectionView

-(void)PressUsers:(UIGestureRecognizer*) sender
{
    [[UserDataSingleton sharedSingleton].dictSelect setValue:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)sender.view.tag]];
    [UserDataSingleton sharedSingleton].imgIndex = sender.view.tag;
    ALAssetRepresentation *assetRepresentation = [[[UserDataSingleton sharedSingleton].arrAlAssistData objectAtIndex:sender.view.tag] defaultRepresentation];
    UIImage *img = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:UIImageOrientationUp];
    //img = [appdelegate squareImageWithImage:img scaledToSize:CGSizeMake(300, 300)];
    //img = [img resizedImageToSize:CGSizeMake(600,600)];
    
    [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(img, 1.0f);
    
    if (boolGo)
    {
        boolGo = NO;

        [self.navigationController.navigationBar setHidden:YES];
//        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:img cropFrame:CGRectMake(10, 80.0f, 300, 300) limitScaleRatio:3.0];
//        imgCropperVC.delegate = self;
//        [self.navigationController pushViewController:imgCropperVC animated:YES];
        [UserDataSingleton sharedSingleton].imgOriginal = img;
        [UserDataSingleton sharedSingleton].MediaData = UIImageJPEGRepresentation(img, 1.0);
        if ([UserDataSingleton sharedSingleton].boolAddPhoto) {
            [self performSegueWithIdentifier:@"showImageFilterView1" sender:nil];
        } else {
            if ([UserDataSingleton sharedSingleton].strEditIndex.length > 0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self performSegueWithIdentifier:@"showImageFilterView1" sender:nil];
            }
        }
    }
}

#pragma mark - Actions
- (IBAction)btnCancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
