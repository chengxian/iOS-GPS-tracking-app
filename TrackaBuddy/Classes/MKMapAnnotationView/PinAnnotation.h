//
//  PinAnnotation.h
//  SVPulsingAnnotationView
//
//  Created by Sam Vermette on 04.03.13.
//  Copyright (c) 2013 Sam Vermette. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PinAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, readwrite) CLLocationCoordinate2D         coordinate;
@property (nonatomic, copy) NSString *                          title;
@property (nonatomic, copy) NSString *                          type;
@property (nonatomic, copy) NSString *                          subtitle;
@property (strong, nonatomic) NSString *                        urlString;
@property (nonatomic, strong) PFFile *                          mediaFile;

@end
