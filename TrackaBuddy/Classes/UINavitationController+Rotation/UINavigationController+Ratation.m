//
//  UINavigationController+Ratation.m
//  TrackaBuddy
//
//  Created by Alexander on 28/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "UINavigationController+Ratation.h"

@implementation UINavigationController (Ratation)

- (BOOL) shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
