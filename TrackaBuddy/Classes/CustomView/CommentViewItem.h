//
//  CommentViewItem.h
//  TrackaBuddy
//
//  Created by Alexander on 25/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentViewItemDelegate;

@interface CommentViewItem : UIView

//Outlets
@property (weak, nonatomic) IBOutlet UIImageView *              imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *                  lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *                  lblComment;
@property (weak, nonatomic) IBOutlet UILabel *                  lblHour;
@property (weak, nonatomic) IBOutlet UIButton *                 btnLike;

//Properties
@property (strong, nonatomic) PFUser *                          mUser;
@property (strong, nonatomic) id<CommentViewItemDelegate>       delegate;
@property (assign, nonatomic) BOOL                              mLike;

//Actions
- (IBAction)btnProfilePressed:(id)sender;

- (IBAction)btnLikePressed:(id)sender;

//Methods
- (void)setUser:(PFUser *)user;

- (void)setComment:(NSString *)comment;

- (void)setHour:(NSInteger)hour;

- (void)setLike:(BOOL)like;

- (PFUser *)user;

- (NSString *)comment;

@end


@protocol CommentViewItemDelegate <NSObject>

- (void)didSelecteUser:(BOOL)selected user:(PFUser *)user;

- (void)didLike:(BOOL)like;

@end