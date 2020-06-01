//
//  ATSearchTableViewController.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATSearchTableViewController.h"
#import "ATPackageManager.h"
#import "ATSearch.h"
#import "ATPackageCell.h"
#import "ATPackageMoreInfoView.h"
#import "ATPackageInfoController.h"

@implementation ATSearchTableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[ATPackageManager sharedPackageManager].search count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"cell";
	
	ATPackage* package = [[ATPackageManager sharedPackageManager].search packageAtIndex:(unsigned int)[indexPath row]];
	ATPackageCell *cell = (ATPackageCell*)[tv dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell == nil) {
		cell = [[ATPackageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier package:package];
	}
	else
		[cell setPackage:package];
	
	cell.odd = ([indexPath row] % 2);
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	// Configure the cell
	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	ATPackage * package = [[ATPackageManager sharedPackageManager].search packageAtIndex:(int)row];
	if(package.entryID && [package needExtendedInfoFetch])
	{
		UITableViewCell *cell = [tv cellForRowAtIndexPath:indexPath];
		
		[(ATPackageCell*)cell setShowIndicator:YES];
		[cell setSelected:NO animated:YES];
		
		fetchCell = (ATPackageCell*)cell;
		fetchCellNumber = (int)row;
		
		[package fetchExtendedInfo];
	}
	else
	{
		/*if (package.customInfoURL != nil && packageCustomInfoController)
		{
			packageCustomInfoController.package = package;
			packageCustomInfoController.urlToLoad = package.customInfoURL;
			packageCustomInfoController.navigationItem.title = package.name;
			[self.navigationController pushViewController:packageCustomInfoController animated:YES];
		}
		else */
		{
			packageInfoController.package = package;
			packageInfoController.navigationItem.title = package.name;
			[self.navigationController pushViewController:packageInfoController animated:YES];
		}
	}

	[tv deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) fetchDone:(NSNotification*)notification
{
	if(fetchCellNumber >= 0 && fetchCell != nil)
	{
		ATPackage * package = [notification object];
		
		[fetchCell setShowIndicator:NO];
		
		fetchCell = nil;
		fetchCellNumber = -1;
		/*if(package.customInfoURL != nil)
		{
			packageCustomInfoController.package = package;
			packageCustomInfoController.urlToLoad = package.customInfoURL;
			packageCustomInfoController.navigationItem.title = package.name;
			[self.navigationController pushViewController:packageCustomInfoController animated:YES];
		}
		else*/
		{
			packageInfoController.package = package;
			packageInfoController.navigationItem.title = package.name;
			[self.navigationController pushViewController:packageInfoController animated:YES];
		}
	}
}

- (void)searchUpdated:(NSNotification*)notification
{
	[tableView reloadData];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	tableView.rowHeight = 80.0;
	[tableView setBackgroundColor:[UIColor colorWithRed:.68 green:.68 blue:.69 alpha:1]];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;	
	
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fetchDone:) 
												 name:ATPackageInfoDoneFetchingNotification 
											   object:nil];	

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(searchUpdated:) 
												 name:ATSearchResultsUpdatedNotification 
											   object:nil];	
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[searchBar resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)setSearch:(NSString*)text
{
	[searchBar setText:text];
	[ATPackageManager sharedPackageManager].search.searchCriteria = text;
	[tableView reloadData];
	[[ATPackageManager sharedPackageManager].search searchImmediately];
}

#pragma mark -

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText
{
	[ATPackageManager sharedPackageManager].search.searchCriteria = searchText;
	[tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb
{
	//[ATPackageManager sharedPackageManager].search.searchCriteria = sb.text;
	//[tableView reloadData];
	
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb
{
	[ATPackageManager sharedPackageManager].search.searchCriteria = nil;
	[tableView reloadData];
	
	[sb resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)sb
{
	return YES;
}

@end

