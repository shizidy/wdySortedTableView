//
//  BaseSortedTableView.h
//  wdySortedTableView
//
//  Created by Macmini on 2019/7/30.
//  Copyright © 2019 Macmini. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BaseSortedTableView;
@protocol BaseSortedTableViewDataSource <NSObject>
/**
 DataSource数据来源

 @param tableView BaseSortedTableView
 @return 数据来源
 */
- (NSMutableArray *)dataSourceArrayInTableView:(BaseSortedTableView *)tableView;

@end

@protocol BaseSortedTableViewDelegate <NSObject>
@optional
/**
 移动不允许移动的cell 在此方法中可做提醒之类操作

 @param tableView BaseSortedTableView
 @param indexPath indexPath
 */
- (void)tableView:(BaseSortedTableView *)tableView tryMoveUnmovableCellAtIndexPath:(NSIndexPath *)indexPath;
/**
 将要移动cell时

 @param tableView BaseSortedTableView
 @param indexPath indexPath
 */
- (void)tableView:(BaseSortedTableView *)tableView willMoveCellAtIndexPath:(NSIndexPath *)indexPath;
/**
 自定义cell的snapshot样式

 @param tableView BaseSortedTableView
 @param movableCellsnapshot movableCellsnapshot
 */
- (void)tableView:(BaseSortedTableView *)tableView customizeMovalbeCell:(UIImageView *)movableCellsnapshot;
/**
 自定义移动动画

 @param tableView BaseSortedTableView
 @param movableCellsnapshot movableCellsnapshot
 @param fingerPoint fingerPoint
 */
- (void)tableView:(BaseSortedTableView *)tableView customizeStartMovingAnimation:(UIImageView *)movableCellsnapshot fingerPoint:(CGPoint)fingerPoint;
/**
 从fromIndexPath移动到toIndexPath

 @param tableView BaseSortedTableView
 @param fromIndexPath fromIndexPath
 @param toIndexPath toIndexPath
 */
- (void)tableView:(BaseSortedTableView *)tableView didMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
/**
 结束移动

 @param tableView BaseSortedTableView
 @param fromIndexPath fromIndexPath
 @param toIndexPath toIndexPath
 */
- (void)tableView:(BaseSortedTableView *)tableView endMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
@end

@interface BaseSortedTableView : UITableView <UITableViewDelegate, UITableViewDataSource>
/**
 协议 baseDataSource
 */
@property (nonatomic, weak) id <BaseSortedTableViewDataSource> baseDataSource;
/**
 协议 baseDelegate
 */
@property (nonatomic, weak) id <BaseSortedTableViewDelegate> baseDelegate;
/**
 长按手势
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;
/**
 是否可以屏幕边缘滑动
 */
@property (nonatomic, assign) BOOL canEdgeScrolled;
/**
 边缘滑动触发范围
 */
@property (nonatomic, assign) CGFloat edgeScrollTriggerRange;
/**
 最大滑动速度
 */
@property (nonatomic, assign) CGFloat maxScrollSpeedPerFrame;

- (void)setAttributes;

@end

NS_ASSUME_NONNULL_END
