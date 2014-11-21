//
//  PlaceViewController.m
//  Anywall
//
//  Created by Pete Nelson on 21/11/2014.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PlaceViewController.h"

@implementation PlaceViewController

- (void)viewDidLoad{
	
	[_review setDataSource:self];
	[_review setDelegate:self];
	
	[_review reloadData];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [_ratings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:MyIdentifier];
	}
	NSNumber *stars = ((PFObject *)[_ratings objectAtIndex:indexPath.row])[@"stars"];
	NSString *comment = ((PFObject *)[_ratings objectAtIndex:indexPath.row])[@"comment"];
	//id user = ((PFObject *)[_ratings objectAtIndex:indexPath.row])[@"user"];
	cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",stars,comment];
	return cell;
}

@end
