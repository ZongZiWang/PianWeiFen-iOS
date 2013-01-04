//
//  PWFViewController.m
//  PianWeiFen
//
//  Created by ZongZiWang on 13-1-4.
//  Copyright (c) 2013年 WebDataMining. All rights reserved.
//

#import "PWFViewController.h"

@interface PWFViewController ()

@end

@implementation PWFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"TopicVC"]];
	[self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"WeiboNavC"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
