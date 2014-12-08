
#import "NewWithMapViewController.h"

#import <Parse/Parse.h>
#import "PAWConstants.h"
#import "PAWPost.h"
#import "PAWConfigManager.h"

@interface NewWithMapViewController ()

@property (nonatomic, assign) NSUInteger maximumCharacterCount;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@end

@implementation NewWithMapViewController

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
	
	[self.mapView setDelegate:self];
	
	self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495f, -122.029095f),
												 MKCoordinateSpanMake(0.008516f, 0.021801f));
	//self.mapPannedSinceLocationUpdate = NO;
	[self startStandardUpdates];
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
	//CLLocation *currentLocation = [self.dataSource currentLocationForWallPostCrateViewController:self];
	CLLocationCoordinate2D currentCoordinate = _currentLocation.coordinate;
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
															  otherButtonTitles:@"OK", nil];
					[alertView show];
					return;
				}
				if (succeeded) {
					
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thanks"
																							   message:@"for contributing"
																							  delegate:self
																					 cancelButtonTitle:nil
																					 otherButtonTitles:@"OK", nil];
					[alertView show];
					
					
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if([alertView.title isEqualToString:@"Thanks"]){
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}


#pragma mark -
#pragma mark CLLocationManagerDelegate methods and helpers

- (CLLocationManager *)locationManager {
	if (_locationManager == nil) {
		_locationManager = [[CLLocationManager alloc] init];
		
		_locationManager.delegate = self;
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
		// Set a movement threshold for new events.
		_locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
	}
	return _locationManager;
}

- (void)startStandardUpdates {
	[self.locationManager startUpdatingLocation];
	
	/*CLLocation *currentLocation = self.locationManager.location;
	if (currentLocation) {
		self.currentLocation = currentLocation;
		//[self showPin];
	}*/
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
		{
			NSLog(@"kCLAuthorizationStatusAuthorized");
			// Re-enable the post button if it was disabled before.
			self.navigationItem.rightBarButtonItem.enabled = YES;
			[self.locationManager startUpdatingLocation];
		}
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fixie can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for Fixie to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alertView show];
			// Disable the post button.
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}
			break;
		case kCLAuthorizationStatusNotDetermined:
		{
			NSLog(@"kCLAuthorizationStatusNotDetermined");
		}
			break;
		case kCLAuthorizationStatusRestricted:
		{
			NSLog(@"kCLAuthorizationStatusRestricted");
		}
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.currentLocation = newLocation;
	[self showPin];
}

- (void)showPin{
	CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:self.currentLocation.coordinate.latitude
															longitude:self.currentLocation.coordinate.longitude];
	
	PAWPost *post = [[PAWPost alloc] initWithCoordinate:self.currentLocation.coordinate andTitle:@"test" andSubtitle:@"test"];
	//[post setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
	
	
	
	[self.mapView addAnnotation:post];
	[(MKPinAnnotationView *)[self.mapView viewForAnnotation:post] setPinColor:MKPinAnnotationColorPurple];
	[(MKPinAnnotationView *)[self.mapView viewForAnnotation:post] setDraggable:YES];
	[(MKPinAnnotationView *)[self.mapView viewForAnnotation:post] setUserInteractionEnabled:YES];
	[(MKPinAnnotationView *)[self.mapView viewForAnnotation:post] animatesDrop];
	
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
	if (newState == MKAnnotationViewDragStateEnding)
	{
		CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
		self.currentLocation = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
		NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
	}
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
	
	if (error.code == kCLErrorDenied) {
		[self.locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
	}
}



#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
	if ([overlay isKindOfClass:[MKCircle class]]) {
		/*MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:self.circleOverlay];
		[circleRenderer setFillColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.2f]];
		[circleRenderer setStrokeColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7f]];
		[circleRenderer setLineWidth:1.0f];*/
		//return circleRenderer;
	}
	return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapVIew viewForAnnotation:(id<MKAnnotation>)annotation {
	// Let the system handle user location annotations.
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	
	static NSString *pinIdentifier = @"CustomPinAnnotation";
	
	// Handle any custom annotations.
	if ([annotation isKindOfClass:[PAWPost class]]) {
		// Try to dequeue an existing pin view first.
		MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapVIew dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
		
		if (!pinView) {
			// If an existing pin view was not available, create one.
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
													  reuseIdentifier:pinIdentifier];
		} else {
			pinView.annotation = annotation;
		}
		pinView.pinColor = [(PAWPost *)annotation pinColor];
		pinView.animatesDrop = [((PAWPost *)annotation) animatesDrop];
		pinView.canShowCallout = YES;
		pinView.draggable = YES;
		pinView.userInteractionEnabled = YES;
		
		return pinView;
	}
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	id<MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[PAWPost class]]) {
		PAWPost *post = [view annotation];
		//[self.wallPostsTableViewController highlightCellForPost:post];
	} else if ([annotation isKindOfClass:[MKUserLocation class]]) {
		// Center the map on the user's current location:
		CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,
																		  filterDistance * 2.0f,
																		  filterDistance * 2.0f);
		
		[self.mapView setRegion:newRegion animated:YES];
		//self.mapPannedSinceLocationUpdate = NO;
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	id<MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[PAWPost class]]) {
		PAWPost *post = [view annotation];
		//[self.wallPostsTableViewController unhighlightCellForPost:post];
	}
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	//self.mapPannedSinceLocationUpdate = YES;
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
