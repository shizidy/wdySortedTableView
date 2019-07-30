//
//  ViewController.m
//  wdySortedTableView
//
//  Created by Macmini on 2019/7/30.
//  Copyright © 2019 Macmini. All rights reserved.
//

#import "ViewController.h"
#import "MySortedTableView.h"
#define Screenwidth [UIScreen mainScreen].bounds.size.width
#define Screenheight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <BaseSortedTableViewDelegate, BaseSortedTableViewDataSource>
@property (nonatomic, strong) MySortedTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

#pragma mark ========== BaseSortedTableViewDataSource ==========
- (NSMutableArray *)dataSourceArrayInTableView:(BaseSortedTableView *)tableView {
    return self.dataArray;
}
#pragma mark ========== BaseSortedTableViewDelegate ==========

- (MySortedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MySortedTableView alloc] initWithFrame:CGRectMake(0, 0, Screenwidth, Screenheight) style:UITableViewStylePlain];
        _tableView.baseDelegate = self;
        _tableView.baseDataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@[@"cell1", @"cell2", @"cell3", @"cell4", @"cell5", @"cell6", @"cell7", @"cell8", @"cell9", @"cell10", @"cell11", @"cell12", @"cell13", @"cell14", @"cell15",@"cell16", @"cell17", @"cell18", @"cell19", @"cell20"].mutableCopy, nil];
    }
    return _dataArray;
}

@end
