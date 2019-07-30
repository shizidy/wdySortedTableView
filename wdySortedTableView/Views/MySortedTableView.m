//
//  MySortedTableView.m
//  wdySortedTableView
//
//  Created by Macmini on 2019/7/30.
//  Copyright © 2019 Macmini. All rights reserved.
//

#import "MySortedTableView.h"

@interface MySortedTableView ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation MySortedTableView
- (void)setAttributes {
    [super setAttributes];
    self.longPressGesture.minimumPressDuration = 1.0;//长按手势最小生效时间
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}
#pragma mark ========== UITableViewDataSource ==========
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    NSArray *array = self.dataArray[indexPath.section];
    cell.textLabel.text = array[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}

#pragma mark ========== UITableViewDelegate ==========
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@[@"cell1", @"cell2", @"cell3", @"cell4", @"cell5", @"cell6", @"cell7", @"cell8", @"cell9", @"cell10", @"cell11", @"cell12", @"cell13", @"cell14", @"cell15",@"cell16", @"cell17", @"cell18", @"cell19", @"cell20"].mutableCopy, nil];
    }
    return _dataArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
