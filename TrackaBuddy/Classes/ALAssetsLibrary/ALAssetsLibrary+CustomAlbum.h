//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Updated by Shirong Huang on 07/20/15.
//  Copyright (c) 2011 Marin Todorov, Shirong Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SuccessBlock)(NSURL * assetURL);
typedef void(^FailureBlock)(NSError* error);



@interface ALAssetsLibrary(CustomAlbum)

-(void)saveImage:(UIImage *)image toAlbum:(NSString*)albumName successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

-(void)saveVideo:(NSURL *)assetURL toAlbum:(NSString*)albumName successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

@end