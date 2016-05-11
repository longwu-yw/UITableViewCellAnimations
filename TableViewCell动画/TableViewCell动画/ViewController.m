//
//  ViewController.m
//  TableViewCell动画
//
//  Created by 叶旺 on 16/5/11.
//  Copyright © 2016年 YW. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doPan:)];
    [self.view addGestureRecognizer:pan];
    // Do any additional setup after loading the view, typically from a nib.
}

// 左滑分享还是右滑收藏
- (CATextLayer *)createTextLayerWithRight:(BOOL)isRight superView:(UIView *)superview {
    
    CATextLayer *textlayer = [CATextLayer layer];
    textlayer = [CATextLayer layer];
    textlayer.bounds = CGRectMake(0, 0, 40, 30);
    textlayer.fontSize = 17;
    textlayer.foregroundColor = (__bridge CGColorRef _Nullable)(isRight ? [UIColor blueColor]:[UIColor redColor]);
    textlayer.string = isRight ? @"分享" : @"收藏";
    
    CGFloat y = (superview.frame.size.height) / 2;
    textlayer.position = CGPointMake(isRight ? self.view.frame.size.width + 30: - 30, y);
    return textlayer;
}


- (void)doPan:(UIPanGestureRecognizer *)pan {
    CGPoint movePoint = [pan translationInView:_tableView];
    CGPoint locPoint = [pan locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:locPoint];
    static UIView *snaphot = nil;
    snaphot.layer.masksToBounds = NO;
    snaphot.layer.cornerRadius = 0.0;
    snaphot.layer.shadowOffset = CGSizeMake(- 5.0, 5.0);
    snaphot.layer.shadowRadius = 5.0;
    snaphot.layer.shadowOpacity = 0.4;
    static CATextLayer *leftTextLayer = nil;
    static CATextLayer *rightTextLayer = nil;
    static BOOL isFirstTouch;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            snaphot = [cell snapshotViewAfterScreenUpdates:YES];
            isFirstTouch = YES;
            CGPoint center = cell.center;
            snaphot.center = center;
            snaphot.alpha = 0.0;
            [_tableView addSubview:snaphot];
            [UIView animateWithDuration:0.25 animations:^{
                snaphot.alpha = 1.0;
                cell.alpha = 0.0;
            } completion:^(BOOL finished) {
                cell.hidden = YES;
            }];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (isFirstTouch) {
                leftTextLayer = [self createTextLayerWithRight:NO superView:snaphot];
                [snaphot.layer addSublayer:leftTextLayer];
                
                rightTextLayer = [self createTextLayerWithRight:YES superView:snaphot];
                [snaphot.layer addSublayer:rightTextLayer];
                
                snaphot.layer.shadowOffset = CGSizeMake(movePoint.x < 0 ? - 5.0 : 5.0, 5.0);
                isFirstTouch = NO;
            }
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformRotate(transform, M_PI / 180.0 * (movePoint.x / self.view.frame.size.width) * 20);
            transform = CGAffineTransformTranslate(transform, movePoint.x, 0);
            snaphot.transform = transform;
        }
            break;
        default: {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            [UIView animateWithDuration:0.5 animations:^{
                [snaphot setTransform:CGAffineTransformIdentity];
                [snaphot setAlpha:1];
            } completion:^(BOOL finished) {
                cell.alpha  = 1.0;
                cell.hidden = NO;
                leftTextLayer  = nil;
                rightTextLayer = nil;
                [snaphot removeFromSuperview];
                snaphot = nil;
            }];
        }
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"tableview";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"第 %02ld 行", indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"第 %02ld 行", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        return 60;
    } else {
        return 100;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
