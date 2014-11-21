//
//  PlaceViewController.h
//  Anywall
//
//  Created by Pete Nelson on 21/11/2014.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *review;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong) NSArray *ratings;

@end
