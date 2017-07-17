//
//  DPScrollPageTitleView.m
//  DPScrollPageControllerDemo
//
//  Created by DancewithPeng on 15/10/30.
//  Copyright © 2015年 dancewithpeng@gmail.com. All rights reserved.
//

#import "DPScrollPageTitleView.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)


@interface DPScrollPageTitleView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) UIScrollView   *titleScrollView;
@property (nonatomic, assign) CGFloat        titleWidth;

@end

@implementation DPScrollPageTitleView

@dynamic scrollEnable;

#pragma mark - Interface Methods

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles itemWidth:(CGFloat)itemWidth
{
    if (self = [super initWithFrame:frame]) {
        self.titleWidth = itemWidth;
        
        for (int i=0; i<titles.count; i++) {
            UILabel *label = [self newTitleLabelWithTitle:titles[i]];
            label.textColor=[UIColor colorWithRed:233/255.0f green:186/255.0f blue:189/255.0f alpha:1];
            [self.titleScrollView addSubview:label];
            [self.titleLabels addObject:label];
        }
    }
    
    return self;
}



- (UILabel *)titleLabelForIndex:(NSInteger)index
{
    NSAssert(index>=0 && index<self.titleLabels.count, @"下标：%d 越界了！！！", (int)index);
    
    return self.titleLabels[index];
}


- (UIView *)sliderView
{
    return [self.titleScrollView viewWithTag:10001];
}

- (void)scrollToVisibleTitleLabel:(UILabel *)titleLabel
{
    NSAssert(titleLabel, @"参数 titleLabel 不能为空");
    
    [self.titleScrollView scrollRectToVisible:titleLabel.frame animated:YES];
}

- (void)scrollToVisibleTitleLabelAtIndex:(NSInteger)index
{
    NSAssert(index>=0 && index<=self.titleLabels.count, @"下标：%d 越界了！！！", (int)index);
    
    UILabel *label = self.titleLabels[index];
    [self scrollToVisibleTitleLabel:label];
}

- (void)scrollToCenterForTitleLabelAtIndex:(NSInteger)index
{
    NSAssert(index>=0 && index<=self.titleLabels.count, @"下标：%d 越界了！！！", (int)index);
    
    UILabel *label = self.titleLabels[index];
    CGFloat destX = label.center.x - kScreenWidth/2;
    destX = destX < 0 ? 0 :destX;
    destX = destX > self.titleScrollView.contentSize.width-self.titleScrollView.bounds.size.width ? self.titleScrollView.contentSize.width-self.titleScrollView.bounds.size.width : destX;
    
    [self.titleScrollView setContentOffset:CGPointMake(destX, 0) animated:YES];
}


#pragma mark - Override

- (void)layoutSubviews
{
    for (int i=0; i<self.titleLabels.count; i++) {
        UILabel *label = self.titleLabels[i];
        label.frame = CGRectMake(i*self.titleWidth, 0, self.titleWidth, self.bounds.size.height);
        label.tag = 100 + i;
    }
    if (self.sliderView != nil) {
        [self.titleScrollView bringSubviewToFront:self.sliderView];
    }
    
    self.titleScrollView.contentSize = CGSizeMake(self.titleLabels.count * self.titleWidth, self.bounds.size.height);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollPageTitleView:didScrollWithOffset:)]) {
        [self.delegate scrollPageTitleView:self didScrollWithOffset:scrollView.contentOffset];
    }
}


#pragma mark - Event Handlers

- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(scrollPageTitleView:titleDidTap:atIndex:)]) {
        NSInteger index = tapGesture.view.tag - 100;
        [self.delegate scrollPageTitleView:self titleDidTap:self.titleLabels[index] atIndex:index];
    }
}


#pragma mark - Helper Methods

- (UILabel *)newTitleLabelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
    [label addGestureRecognizer:tapGesture];
    label.userInteractionEnabled = YES;
    
    return label;
}


#pragma mark - Setter & Getter

- (void)setScrollEnable:(BOOL)scrollEnable
{
    self.titleScrollView.scrollEnabled = scrollEnable;
}

- (BOOL)scrollEnable
{
    return self.titleScrollView.scrollEnabled;
}

- (NSMutableArray *)titleLabels
{
    if (_titleLabels == nil) {
        _titleLabels = [[NSMutableArray alloc] init];
    }
    
    return _titleLabels;
}

- (UIScrollView *)titleScrollView
{
    if (_titleScrollView == nil) {
        _titleScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _titleScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _titleScrollView.delegate = self;
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        _titleScrollView.showsVerticalScrollIndicator = NO;
        
        [self addSubview:_titleScrollView];
    }
    
    return _titleScrollView;
}

@end
