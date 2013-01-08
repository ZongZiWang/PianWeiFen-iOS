//
//  PWFWeiboViewController.h
//  PianWeiFen
//
//  Created by ZongZiWang on 13-1-4.
//  Copyright (c) 2013年 WebDataMining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@interface PWFWeiboViewController : UITableViewController

@property (strong, nonatomic) NSArray *weibos;
@property (strong, nonatomic) SinaWeibo *sinaWeibo;

- (void)refreshWeibo;

@end
