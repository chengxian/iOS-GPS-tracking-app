//
//  PinAnnotationView.h
//  TrackaBuddy
//
//  Created by Alexander on 05/09/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PinAnnotationView : MKPinAnnotationView

@property (nonatomic, readwrite) CLLocationCoordinate2D         coordinate;
@property (nonatomic, copy) NSString *                          title;
@property (nonatomic, copy) NSString *                          type;
@property (nonatomic, copy) NSString *                          subtitle;
@property (nonatomic, strong) NSString *                        urlString;
@property (nonatomic, strong) PFFile *                          mediaFile;
@end
