//
//  PAWWallPostCreateViewController.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWWallPostCreateViewController.h"

#import <Parse/Parse.h>

#import "PAWConstants.h"
#import "PAWConfigManager.h"

@interface PAWWallPostCreateViewController ()

@property (nonatomic, assign) NSUInteger maximumCharacterCount;

@end

@implementation PAWWallPostCreateViewController

#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _maximumCharacterCount = [[PAWConfigManager sharedManager] postMaxCharacterCount];
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 144.0f, 26.0f)];
    self.characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 144.0f, 21.0f)];
    self.characterCountLabel.backgroundColor = [UIColor clearColor];
    self.characterCountLabel.textColor = [UIColor darkGrayColor];
	[accessoryView addSubview:self.characterCountLabel];

    //self.textView.inputAccessoryView = accessoryView;

   // [self updateCharacterCountLabel];
    //[self checkCharacterCount];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.name becomeFirstResponder];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark -
#pragma mark UINavigationBar-based actions

- (IBAction)cancelPost:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postPost:(id)sender {
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [self.name resignFirstResponder];

    // Capture current text field contents:
    /*[self updateCharacterCountLabel];
    BOOL isAcceptableAfterAutocorrect = [self checkCharacterCount];

    if (!isAcceptableAfterAutocorrect) {
        [self.textView becomeFirstResponder];
        return;
    }*/

    // Data prep:
    CLLocation *currentLocation = [self.dataSource currentLocationForWallPostCrateViewController:self];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];
    PFUser *user = [PFUser currentUser];

    // Stitch together a postObject and send this async to Parse
    PFObject *postObject = [PFObject objectWithClassName:@"Place"];
    postObject[PAWParsePostTextKey] = self.name.text;
	PFRelation *relation = [postObject relationForKey:@"createdBy"];
	[relation addObject:user];
	
    postObject[PAWParsePostLocationKey] = currentPoint;

    // Use PFACL to restrict future modifications to this object.
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES];
    [readOnlyACL setPublicWriteAccess:NO];
    postObject.ACL = readOnlyACL;

    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Couldn't save!");
            NSLog(@"%@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"]
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Ok", nil];
            [alertView show];
            return;
        }
        if (succeeded) {
            NSLog(@"Successfully saved place!");
            NSLog(@"%@", postObject);
			
			PFObject *ratingObject = [PFObject objectWithClassName:@"Rating"];
			NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
			[f setNumberStyle:NSNumberFormatterDecimalStyle];
			NSNumber *myRating = [f numberFromString:self.rating.text];
			ratingObject[@"stars"] = myRating;
			ratingObject[@"comment"] = self.comment.text;
			
			PFRelation *relation = [ratingObject relationForKey:@"user"];
			[relation addObject:user];
			
			PFRelation *relationPlace = [ratingObject relationForKey:@"place"];
			[relationPlace addObject:postObject];
			
			[ratingObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (error) {
					NSLog(@"Couldn't save!");
					NSLog(@"%@", error);
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"]
																		message:nil
																	   delegate:self
															  cancelButtonTitle:nil
															  otherButtonTitles:@"Ok", nil];
					[alertView show];
					return;
				}
				if (succeeded) {
				
				}
			}];
			
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:PAWPostCreatedNotification object:nil];
            });
        } else {
            NSLog(@"Failed to save.");
        }
    }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    //[self updateCharacterCountLabel];
    //[self checkCharacterCount];
}

#pragma mark -
#pragma mark Accessors

- (void)setMaximumCharacterCount:(NSUInteger)maximumCharacterCount {
    if (self.maximumCharacterCount != maximumCharacterCount) {
        _maximumCharacterCount = maximumCharacterCount;

        //[self updateCharacterCountLabel];
        //[self checkCharacterCount];
    }
}

#pragma mark -
#pragma mark Private


@end
