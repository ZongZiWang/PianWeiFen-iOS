//
//  PWFTopicViewController.m
//  PianWeiFen
//
//  Created by ZongZiWang on 13-1-4.
//  Copyright (c) 2013年 WebDataMining. All rights reserved.
//

#import "PWFTopicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "PWFWeiboViewController.h"
#import "Coffeepot.h"

@interface PWFTopicViewController () <EGORefreshTableHeaderDelegate>{
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

@property (weak, nonatomic) PWFWeiboViewController *weiboVC;

@end

@implementation PWFTopicViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	self.weiboVC = (PWFWeiboViewController *)((UINavigationController *)self.sidePanelController.centerPanel).topViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 1) return self.topics.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 1) return @"主题分类";
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopicCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	if (indexPath.section == 1) cell.textLabel.text = self.topics[indexPath.row][@"topic"];
	else cell.textLabel.text = @"全部";
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.sidePanelController toggleLeftPanel:self];
		[self.weiboVC refreshWeibo];
	} else {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		self.weiboVC.title = self.topics[indexPath.row][@"topic"];
		self.weiboVC.weibos = self.topics[indexPath.row][@"statuses"];
		[self.sidePanelController toggleLeftPanel:self];
		[self.weiboVC.tableView reloadData];
	}
}

- (void)refreshTopic
{
	if ([self.weiboVC.sinaWeibo isAuthValid]) {
		[[Coffeepot shared] requestWithMethodPath:@"wdm/statuses/workspace/pwf_timeline.php" params:@{@"access_token" : self.weiboVC.sinaWeibo.accessToken} success:^(CPRequest *request, id collection) {
			if ([collection isKindOfClass:[NSArray class]]) {
				self.topics = collection;
				[self.tableView reloadData];
			}
			[self doneLoadingTableViewData];
		} error:^(CPRequest *request, NSError *error) {
			NSLog(@"%@", error);
			[self doneLoadingTableViewData];
		}];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	} else {
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:.5];
		[self.sidePanelController toggleLeftPanel:self];
		[self.weiboVC.sinaWeibo logIn];
	}
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
	[self refreshTopic];
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
