//
//  CommentViewItem.m
//  TrackaBuddy
//
//  Created by Alexander on 25/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "CommentViewItem.h"

@implementation CommentViewItem

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (self.subviews.count == 0) {
            UINib * nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
            UIView * subview = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
            subview.frame = self.bounds;
            [self addSubview:subview];
        }
        self.mLike = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//Methods

- (void)setUser:(PFUser *)user
{
    _mUser = user;
}

- (void)setComment:(NSString *)comment
{
    _lblComment.text = comment;
}

- (void)setHour:(NSInteger)hour
{
    _lblHour.text = [NSString stringWithFormat:@"%ld hours ago", (long)hour];
}

- (void)setLike:(BOOL)like
{
    _mLike = like;
    _btnLike.titleLabel.text = _mLike ? @"UnLike" : @"Like";
}

- (PFUser *)user
{
    return _mUser;
}

- (NSString *)comment
{
    return _lblComment.text;
}


- (IBAction)btnProfilePressed:(id)sender {
    [self.delegate didSelecteUser:YES user:_mUser];
}

- (IBAction)btnLikePressed:(id)sender {
    _mLike = !_mLike;
    [self.delegate didLike:_mLike];
}
@end