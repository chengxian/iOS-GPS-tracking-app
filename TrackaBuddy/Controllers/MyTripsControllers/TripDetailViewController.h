//
//  TripDetailViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 22/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripDetailViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets
@property (weak, nonatomic) IBOutlet UILabel *                      lblTitle;
@property (weak, nonatomic) IBOutlet PFImageView *                  imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *                      lblTripDescription;
@property (weak, nonatomic) IBOutlet UICollectionView *             collectionPhotos;
@property (weak, nonatomic) IBOutlet UILabel *                      lblLikeCount;
@property (weak, nonatomic) IBOutlet UIButton *                     btnShareCount;
@property (weak, nonatomic) IBOutlet UIButton *                     btnAllComment;
@property (weak, nonatomic) IBOutlet UIView *                       commentsView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *socialContentView;


//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (strong, nonatomic) PFObject *                            currTrip;
@property (strong, nonatomic) NSArray *                             mediaArray;
@property (assign, nonatomic) CGFloat                               collectionCellWidth;
@property (assign, nonatomic) CGSize                                collectionCellSize;
@property (strong, nonatomic) NSString *                            remotePhotoURL;
@property (strong, nonatomic) PFFile *                              selectedMediaFile;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties

//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions

- (IBAction)btnBackPressed:(id)sender;

- (IBAction)btnLikePressed:(id)sender;
- (IBAction)btnCommentPressed:(id)sender;

- (IBAction)btnSharePressed:(id)sender;
- (IBAction)btnAllCommentPressed:(id)sender;
- (IBAction)btnShareCountPressed:(id)sender;
@end
