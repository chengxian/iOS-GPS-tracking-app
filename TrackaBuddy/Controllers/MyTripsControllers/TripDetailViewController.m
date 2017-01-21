//
//  TripDetailViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 22/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "TripDetailViewController.h"
#import "MapDetailViewController.h"
#import "CommentViewItem.h"
#import "EditPhotoViewController.h"

@implementation TripDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionPhotos.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _collectionPhotos.layer.borderWidth = 1;
    
    _imgProfile.layer.cornerRadius = 25;
    _collectionCellWidth = ([UserDataSingleton sharedSingleton].screenWidth - 40) / 3;
    _collectionCellSize.width = _collectionCellWidth;
    _collectionCellSize.height = _collectionCellWidth;
    
    UITapGestureRecognizer * profileTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileSelected:)];
    profileTapGesture.numberOfTapsRequired = 1;
    [_imgProfile addGestureRecognizer:profileTapGesture];
    
    
    [self addCommentPart];
    
    [self getTripDetails];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self getTripDetails];
}

- (void)didReceiveMemoryWarning {
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

#pragma mark - UICollectionView DataSoure and Delegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _collectionCellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_mediaArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    PFImageView * thumbImage = (PFImageView *)[cell.contentView viewWithTag:COLLECTIONVIEWCELL_IMAGE_TAG];
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 1;
    if (row == 0) {
        PFFile * map_thumbfile = _currTrip[@"track_picture"];
        if (map_thumbfile) {
            thumbImage.file = map_thumbfile;
            [thumbImage loadInBackground];
        }
        else
        {
            thumbImage.image = [UIImage imageNamed:@"map_trip_thumb"];
        }
    }
    else
    {
        PFObject * media = (PFObject *)[_mediaArray objectAtIndex:row - 1];
        PFFile * thumbFile = media[@"thumbnail_file"];
        NSLog(@"thumb url : %@", thumbFile.url);
        thumbImage.file = thumbFile;
        [thumbImage loadInBackground];
        
        UILabel * label = (UILabel *)[cell.contentView viewWithTag:COLLECTIONVIEWCELL_LABEL_TAG];
        UIImageView * videoIcon = (UIImageView *)[cell.contentView viewWithTag:COLLECTIONVIEWCELL_VIDEO_ICON_TAG];
        if ([media[@"media_type"] integerValue] == 2) {
            label.hidden = NO;
            videoIcon.hidden = NO;
            label.text = media[@"duration"];
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        [self mapThumbSelected];
    }
    else
    {
        [self mediaSelected:row - 1];
    }
}

#pragma mark - Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Methods

//getTripDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------------# getTripDetails

- (void)getTripDetails
{
    _lblTitle.text = _currTrip[@"name"];
    
    [self disbleControls];

    [ProgressHUD show:@"Loading..."];
    
    PFUser * user = _currTrip[@"user"];
    NSString * username = [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]];
    
    PFFile * avatarFile = user[@"avatar"];
    _imgProfile.file = avatarFile;
    [_imgProfile loadInBackground];
    
    [[UserDataSingleton sharedSingleton] getMediasByTrip:_currTrip completion:^(BOOL finished, NSArray *array, NSError *error) {
        if (finished)
        {
            NSString * tripName = _currTrip[@"name"];
            if (tripName == nil || [tripName isEqualToString:@""]) {
                tripName = @"No Named";
            }
            _mediaArray = array;
            if ([_mediaArray count] > 0) {
                NSString * oriText = [NSString stringWithFormat:@"%@ added %ld items to the album %@", username, (unsigned long)[_mediaArray count], tripName];
                UIFont *currentFont = _lblTripDescription.font;
                UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
                
                NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:oriText];
                [text setAttributes:@{NSFontAttributeName:newFont} range:NSMakeRange(0, username.length)];
                [text setAttributes:@{NSFontAttributeName:newFont} range:NSMakeRange(text.length - tripName.length, tripName.length)];
                [_lblTripDescription setAttributedText:text];

                [_collectionPhotos reloadData];
            }
            else
            {
                NSString * oriText = [NSString stringWithFormat:@"%@ did not post any medias to the album %@", username, tripName];
                UIFont *currentFont = _lblTripDescription.font;
                UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
                
                NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:oriText];
                [text setAttributes:@{NSFontAttributeName:newFont} range:NSMakeRange(text.length - tripName.length, tripName.length)];
                [text setAttributes:@{NSFontAttributeName:newFont} range:NSMakeRange(0, username.length)];
                [_lblTripDescription setAttributedText:text];
            }
            [ProgressHUD dismiss];
            [self performSelector:@selector(enableControls) withObject:nil afterDelay:0.3f];
        }
        else
        {
            [ProgressHUD dismiss];
            [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't get data"];
            [self performSelector:@selector(enableControls) withObject:nil afterDelay:0.3f];
        }
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## getTripDetails


//addCommentPart
//-------------------------------------------------------------------------------------------------------------------------------------------------------# addCommentPart

- (void)addCommentPart
{
    CommentViewItem * item = [[[NSBundle mainBundle] loadNibNamed:@"CommentViewItem" owner:self options:nil] objectAtIndex:0];
    item.frame = CGRectMake(0, 0, [UserDataSingleton sharedSingleton].screenWidth, 50.0f);
    [_commentsView addSubview:item];
    [item setUser:[PFUser currentUser]];
    [item setComment:@"This is test comment!"];
    [item setLike:NO];
    [item setHour:10];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## addCommentPart

//profileSelected
//-------------------------------------------------------------------------------------------------------------------------------------------------------# profileSelected

-(void)profileSelected:(UITapGestureRecognizer*)sender
{
    NSLog(@"profileSelected");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------# profileSelected


//mapThumbSelected
//-------------------------------------------------------------------------------------------------------------------------------------------------------# mapThumbSelected

- (void)mapThumbSelected
{
    NSLog(@"mapThumbSelected");
    [self performSegueWithIdentifier:@"showMapDetailView" sender:nil];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------------## mapThumbSelected

//mediaSelected
//-------------------------------------------------------------------------------------------------------------------------------------------------------# mediaSelected

- (void)mediaSelected:(NSInteger)index
{
    NSLog(@"mediaSelected");
    
    PFObject * media = [_mediaArray objectAtIndex:index];
    NSInteger type = [media[@"media_type"] integerValue];
    _selectedMediaFile = media[@"media_file"];
    if (type == 1) {                    //picture
        [self performSegueWithIdentifier:@"showEditPhotoViewFromTripDetail" sender:nil];
    }
    else if (type == 2)                 //video
    {
        [ProgressHUD show:@"Downloading..."];
        [_selectedMediaFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                [ProgressHUD dismiss];
                NSString * file = [[UserDataSingleton sharedSingleton].documentDirectory stringByAppendingPathComponent:@"MyFile.mov"];
                [data writeToFile:file atomically:YES];
                
                MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:file]];
                [playerVC.moviePlayer setShouldAutoplay:NO];
                
                [[NSNotificationCenter defaultCenter] removeObserver:playerVC
                                                                name:MPMoviePlayerPlaybackDidFinishNotification
                                                              object:playerVC.moviePlayer];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(movieFinishedCallback:)
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                                           object:playerVC.moviePlayer];
                
                playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                
                [self presentMoviePlayerViewControllerAnimated:playerVC];
            }
            else
            {
                [ProgressHUD dismiss];
                [[UserDataSingleton sharedSingleton] AlertWithCancel_btn:@"Can't play due to network status. Please retry"];
                return;
            }
        }];
    }
    else                                //audio
    {
        
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## mediaSelected

//movieFinishedCallback
//-------------------------------------------------------------------------------------------------------------------------------------------------------# movieFinishedCallback

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## movieFinishedCallback


- (void)enableControls
{
    _btnBack.enabled = YES;
    _socialContentView.userInteractionEnabled = YES;
    _collectionPhotos.userInteractionEnabled = YES;
}

- (void)disbleControls
{
    _btnBack.enabled = NO;
    _socialContentView.userInteractionEnabled = NO;
    _collectionPhotos.userInteractionEnabled = NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Methods

#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnLikePressed:(id)sender {
}

- (IBAction)btnCommentPressed:(id)sender {
}

- (IBAction)btnSharePressed:(id)sender {
}

- (IBAction)btnAllCommentPressed:(id)sender {
}

- (IBAction)btnShareCountPressed:(id)sender {
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions

#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMapDetailView"]) {
        MapDetailViewController * vc = [segue destinationViewController];
        vc.currTrip = _currTrip;
        vc.mediaArray = _mediaArray;
    }
    else if ([[segue identifier] isEqualToString:@"showEditPhotoViewFromTripDetail"])
    {
        EditPhotoViewController * vc = [segue destinationViewController];
        [vc setPhotoFileFromRemote:_selectedMediaFile];
    }
}

@end
