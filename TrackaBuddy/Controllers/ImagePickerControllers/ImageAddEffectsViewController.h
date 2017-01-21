//
//  ImageAddEffectsViewController.h
//  Mingleloop
//
//  Created by Shirong Huang on 24/01/14.
//  Copyright (c) 2014 NineHertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "InstaFilters.h"
#import "UIImage+IF.h"

@interface ImageAddEffectsViewController : UIViewController<UIScrollViewDelegate>
{
    UIImage *linkedImage;
    NSArray *arrImage;
    NSArray *arrName;
}

@property(nonatomic,strong)IBOutlet UIScrollView *scrlEffect;
@property(nonatomic,strong)UIImage *imageAfter;
@property (nonatomic, strong) IFVideoCamera *videoCamera;
@property (nonatomic, unsafe_unretained) IFFilterType currentType;
@property (nonatomic, unsafe_unretained) BOOL isHighQualityVideo;
@property (nonatomic, strong) IFImageFilter *filter;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrlEffectHeightConstraint;

-(IBAction)btnCancelPress:(id)sender;
-(IBAction)btnDonePress:(id)sender;

@end
