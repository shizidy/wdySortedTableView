//
//  BaseSortedTableView.m
//  wdySortedTableView
//
//  Created by Macmini on 2019/7/30.
//  Copyright © 2019 Macmini. All rights reserved.
//

#import "BaseSortedTableView.h"
#define MovableCellAnimationTime 0.25
@interface BaseSortedTableView ()
/**
 长按手势
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
/**
 长按手势最小生效时间
 */
@property (nonatomic, assign) CGFloat gestureMinimumPressDuration;
/**
 记录选择的cell的indexPath
 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
/**
 记录开始拖动时的cell的indexPath
 */
@property (nonatomic, strong) NSIndexPath *startIndexPath;
/**
 记录结束拖动时的cell的indexPath
 */
@property (nonatomic, strong) NSIndexPath *endIndexPath;
/**
 cell快照
 */
@property (nonatomic, strong) UIImageView *snapshot;
/**
 保存dateSource
 */
@property (nonatomic, strong) NSMutableArray *tempDataSource;
/**
 edgeScrollLink
 */
@property (nonatomic, strong) CADisplayLink *edgeScrollLink;
/**
 当前滑动速度
 */
@property (nonatomic, assign) CGFloat currentScrollSpeedPerFrame;
@end

@implementation BaseSortedTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        //设置属性
        [self setAttributes];
        //初始化
        [self initData];
    }
    return self;
}

#pragma mark ========== 设置属性 ==========
- (void)setAttributes {
    self.backgroundColor = [UIColor whiteColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.estimatedRowHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
}

#pragma mark ========== 初始化 ==========
- (void)initData {
    self.gestureMinimumPressDuration = 1.f;
    self.canEdgeScrolled = YES;
    self.edgeScrollTriggerRange = 150.f;
    self.maxScrollSpeedPerFrame = 20;
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:self.longPressGesture];
}

#pragma mark ========== longPressGesture ==========
- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture {
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self longPressGestureBegan:longPressGesture];//开始
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self longPressGestureChanged:longPressGesture];//变化中
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self longPressGestureCancelled:longPressGesture];//取消
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self longPressGestureCancelled:longPressGesture];//和取消一样的操作
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ========== 手势拖动开始 ==========
- (void)longPressGestureBegan:(UILongPressGestureRecognizer *)longPressGesture {
    //获取point
    CGPoint point = [longPressGesture locationInView:longPressGesture.view];
    //获取selectedIndexPath
    NSIndexPath *selectIndexPath = [self indexPathForRowAtPoint:point];
    self.startIndexPath = selectIndexPath;
    self.selectedIndexPath = selectIndexPath;
    if (!selectIndexPath) {
        return;
    }
    //获取cell
    UITableViewCell *cell = [self cellForRowAtIndexPath:selectIndexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        //设置了不允许拖动的row时，给出动画提示
        if (![self.dataSource tableView:self canMoveRowAtIndexPath:selectIndexPath]) {
            CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"tranform.translation.x"];
            shakeAnimation.duration = MovableCellAnimationTime;
            shakeAnimation.values = @[@(-20), @(20), @(-10), @(10), @(0)];
            [cell.layer addAnimation:shakeAnimation forKey:@"shake"];
            //移动不允许移动的cell 在此方法中可做提醒之类操作
            if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(tableView:tryMoveUnmovableCellAtIndexPath:)]) {
                [self.baseDelegate tableView:self tryMoveUnmovableCellAtIndexPath:selectIndexPath];
            }
            return;
        }
    }
    //将要移动cell时
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(tableView:willMoveCellAtIndexPath:)]) {
        [self.baseDelegate tableView:self willMoveCellAtIndexPath:selectIndexPath];
    }
    //startEdgeScroll
    if (self.canEdgeScrolled) {
        [self startEdgeScroll];
    }
    //获取数据源
    if (self.baseDataSource && [self.baseDataSource respondsToSelector:@selector(dataSourceArrayInTableView:)]) {
        self.tempDataSource = [self.baseDataSource dataSourceArrayInTableView:self];
    }
    //获取cell快照
    self.snapshot = [self snapshotViewWithInputView:cell];
    self.snapshot.frame = cell.frame;
    [self addSubview:self.snapshot];
    //隐藏当前cell真身
    cell.hidden = YES;
    //自定义snapshot样式
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(tableView:customizeMovalbeCell:)]) {
        [self.baseDelegate tableView:self customizeMovalbeCell:self.snapshot];
    } else {
        //默认样式
        self.snapshot.layer.shadowColor = [UIColor grayColor].CGColor;
        self.snapshot.layer.masksToBounds = NO;
        self.snapshot.layer.cornerRadius = 0;
        self.snapshot.layer.shadowOffset = CGSizeMake(-5, 0);
        self.snapshot.layer.shadowOpacity = 0.4;
        self.snapshot.layer.shadowRadius = 5;
    }
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(tableView:customizeStartMovingAnimation:fingerPoint:)]) {
        [self.baseDelegate tableView:self customizeStartMovingAnimation:self.snapshot fingerPoint:point];
    } else {
        //默认动画
        [UIView animateWithDuration:MovableCellAnimationTime animations:^{
            self.snapshot.center = CGPointMake(self.snapshot.center.x, point.y);
        }];
    }
}

#pragma mark ========== 手势拖动中 ==========
- (void)longPressGestureChanged:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint point = [longPressGesture locationInView:longPressGesture.view];
    point = CGPointMake(self.snapshot.center.x, [self limitSnapshotCenterY:point.y]);
    //Let the screenshot follow the gesture 随手是移动self.snapshot
    self.snapshot.center = point;
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:point];
    if (!currentIndexPath) {
        return;
    }
//    UITableViewCell *selectedCell = [self cellForRowAtIndexPath:self.selectedIndexPath];
//    selectedCell.hidden = YES;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        if (![self.dataSource tableView:self canMoveRowAtIndexPath:currentIndexPath]) {
            return;
        }
    }
    if (currentIndexPath && ![self.selectedIndexPath isEqual:currentIndexPath]) {
        //交换数据源和cell
        [self updateDataSourceAndCellFromIndexPath:self.selectedIndexPath toIndexPath:currentIndexPath];
        if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(tableView:didMoveCellFromIndexPath:toIndexPath:)]) {
            [self.baseDelegate tableView:self didMoveCellFromIndexPath:self.selectedIndexPath toIndexPath:currentIndexPath];
        }
        self.selectedIndexPath = currentIndexPath;
    }
}

#pragma mark ========== 手势拖动取消 ==========
- (void)longPressGestureCancelled:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint point = [longPressGesture locationInView:longPressGesture.view];
    point = CGPointMake(self.snapshot.center.x, [self limitSnapshotCenterY:point.y]);
    //Let the screenshot follow the gesture
    self.snapshot.center = point;
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:point];
    self.endIndexPath = currentIndexPath;
    if (self.canEdgeScrolled) {
        [self stopEdgeScroll];
    }
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(tableView:endMoveCellFromIndexPath:toIndexPath:)]) {
        [self.baseDelegate tableView:self endMoveCellFromIndexPath:self.startIndexPath toIndexPath:self.endIndexPath];
    }
    //获取刚才移动的cell
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.selectedIndexPath];
    [UIView animateWithDuration:MovableCellAnimationTime animations:^{
        self.snapshot.transform = CGAffineTransformIdentity;
        self.snapshot.frame = cell.frame;
    } completion:^(BOOL finished) {
        //动画结束显示cell,并移除快照snapshot
        cell.hidden = NO;
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
    }];
}

- (void)longPressGestureEnded:(UILongPressGestureRecognizer *)longPressGesture {
    
}

- (void)updateDataSourceAndCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if ([self numberOfSections] == 1) {
        //only one section
        [self.tempDataSource[fromIndexPath.section] exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }else {
        //multiple sections
        id fromData = self.tempDataSource[fromIndexPath.section][fromIndexPath.row];
        id toData = self.tempDataSource[toIndexPath.section][toIndexPath.row];
        NSMutableArray *fromArray = self.tempDataSource[fromIndexPath.section];
        NSMutableArray *toArray = self.tempDataSource[toIndexPath.section];
        [fromArray replaceObjectAtIndex:fromIndexPath.row withObject:toData];
        [toArray replaceObjectAtIndex:toIndexPath.row withObject:fromData];
        
        if (@available(iOS 11.0, *)) {
            if (self.currentScrollSpeedPerFrame > 10) {
                [self reloadRowsAtIndexPaths:@[fromIndexPath, toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {//执行系统移动cell的行
                [self beginUpdates];
                [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
                [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                [self endUpdates];
            }
        } else {//执行系统移动cell的行
            [self beginUpdates];
            [self moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
            [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
            [self endUpdates];
        }
    }
}

#pragma mark ========== 创建cell快照 ==========
- (UIImageView *)snapshotViewWithInputView:(UIView *)inputView {
    //使用CGContext获取cell快照
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *snapshot = [[UIImageView alloc] initWithImage:image];
    return snapshot;
}

#pragma mark ========== EdgeScroll边缘滚动 ==========
- (void)startEdgeScroll {
    self.edgeScrollLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(processEdgeScroll)];
    [self.edgeScrollLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)processEdgeScroll {
    CGFloat minOffsetY = self.contentOffset.y + self.edgeScrollTriggerRange;
    CGFloat maxOffsetY = self.contentOffset.y + self.bounds.size.height - self.edgeScrollTriggerRange;
    CGPoint touchPoint = self.snapshot.center;
    
    if (touchPoint.y < minOffsetY) {
        //Cell is moving up
        CGFloat moveDistance = (minOffsetY - touchPoint.y)/self.edgeScrollTriggerRange*self.maxScrollSpeedPerFrame;
        self.currentScrollSpeedPerFrame = moveDistance;
        self.contentOffset = CGPointMake(self.contentOffset.x, [self limitContentOffsetY:self.contentOffset.y - moveDistance]);
    }else if (touchPoint.y > maxOffsetY) {
        //Cell is moving down
        CGFloat moveDistance = (touchPoint.y - maxOffsetY)/self.edgeScrollTriggerRange*self.maxScrollSpeedPerFrame;
        self.currentScrollSpeedPerFrame = moveDistance;
        self.contentOffset = CGPointMake(self.contentOffset.x, [self limitContentOffsetY:self.contentOffset.y + moveDistance]);
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self longPressGestureChanged:self.longPressGesture];
}

- (void)stopEdgeScroll {
    self.currentScrollSpeedPerFrame = 0;
    if (self.edgeScrollLink) {
        [self.edgeScrollLink invalidate];
        self.edgeScrollLink = nil;
    }
}

- (CGFloat)limitContentOffsetY:(CGFloat)targetOffsetY {
    CGFloat minContentOffsetY;
    if (@available(iOS 11.0, *)) {
        minContentOffsetY = -self.adjustedContentInset.top;
    } else {
        minContentOffsetY = -self.contentInset.top;
    }
    
    CGFloat maxContentOffsetY = minContentOffsetY;
    CGFloat contentSizeHeight = self.contentSize.height;
    if (@available(iOS 11.0, *)) {
        contentSizeHeight += self.adjustedContentInset.top + self.adjustedContentInset.bottom;
    } else {
        contentSizeHeight += self.contentInset.top + self.contentInset.bottom;
    }
    if (contentSizeHeight > self.bounds.size.height) {
        maxContentOffsetY += contentSizeHeight - self.bounds.size.height;
    }
    return MIN(maxContentOffsetY, MAX(minContentOffsetY, targetOffsetY));
}

- (CGFloat)limitSnapshotCenterY:(CGFloat)targetY {
    CGFloat minValue = self.snapshot.bounds.size.height*0.5 + self.contentOffset.y;//最小
    CGFloat maxValue = self.contentOffset.y + self.bounds.size.height - self.snapshot.bounds.size.height*0.5;
    return MIN(maxValue, MAX(minValue, targetY));
}

#pragma mark ========== UITableViewDataSource ==========
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
