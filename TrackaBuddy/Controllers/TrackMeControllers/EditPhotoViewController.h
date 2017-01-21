//
//  EditPhotoViewController.h
//  TrackaBuddy
//
//  Created by Alexander on 20/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPhotoViewController : UIViewController

//Outlets
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Outlets

@property (weak, nonatomic) IBOutlet PFImageView *imgContent;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Outlets


//Properties
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Properties

@property (strong, nonatomic) PFFile * imgFile;
@property (strong, nonatomic) NSString * urlString;
@property (assign, nonatomic) BOOL isLocal;
@property (assign, nonatomic) BOOL isPortrateImage;


//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Properties


//Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Actions

- (IBAction)btnCancelPressed:(id)sender;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Actions


//Public Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------@ Public Methods

- (void)setPhotoFromAssets:(NSString *)urlString;

- (void)setPhotoFileFromRemote:(PFFile *)imgFile;

//-------------------------------------------------------------------------------------------------------------------------------------------------------@@ Public Methods

@end
