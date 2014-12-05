//
//  HomeViewController.m
//  Fixie
//
//  Created by Pete Nelson on 05/12/2014.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "PAWAppDelegate.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)findClick:(id)sender {
}

- (IBAction)addClick:(id)sender {
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate addNew];
}
@end
