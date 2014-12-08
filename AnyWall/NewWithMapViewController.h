//
//  PAWWallPostCreateViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class NewWithMapViewController;

@protocol PAWWallPostCreateViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForWallPostCrateViewController:(NewWithMapViewController *)controller;

@end

@interface NewWithMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<PAWWallPostCreateViewControllerDataSource> dataSource;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) IBOutlet UITextField *name;
@property (nonatomic, strong) IBOutlet UITextField *rating;
@property (nonatomic, strong) IBOutlet UITextField *comment;
@property (nonatomic, strong) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, strong) IBOutlet UIButton *postButton;

- (IBAction)cancelPost:(id)sender;
- (IBAction)postPost:(id)sender;

@end
