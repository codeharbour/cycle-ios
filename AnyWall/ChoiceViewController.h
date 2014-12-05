//
//  PAWWallViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class ChoiceViewController;

@protocol PAWWallViewControllerDelegate <NSObject>

- (void)wallViewControllerWantsToPresentSettings:(ChoiceViewController *)controller;

@end

@class PAWPost;

@interface ChoiceViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) id<PAWWallViewControllerDelegate> delegate;

- (IBAction)postButtonSelected:(id)sender;
- (IBAction)addClick:(id)sender;

@end

@protocol PAWWallViewControllerHighlight <NSObject>

- (void)highlightCellForPost:(PAWPost *)post;
- (void)unhighlightCellForPost:(PAWPost *)post;

@end
