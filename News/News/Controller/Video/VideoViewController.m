//
//  VideoViewController.m
//  News
//
//  Created by ZZG on 16/7/7.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "VideoViewController.h"

#import "DPScrollPageController.h"
#import "DPScrollPageTitleView.h"

#import "VideoVC.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface VideoViewController () <DPScrollPageControllerDelegate, DPScrollPageTitleViewDelegate>

@property (nonatomic, strong) DPScrollPageController *scrollPageController;
@property (nonatomic, strong) DPScrollPageTitleView  *scrollTitleView;
@property (nonatomic, strong) NSArray                *newsViewControllers;
@property (nonatomic, strong) NSArray                *titles;
@property (nonatomic, strong) NSArray                *urlStrings;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     DPScrollPageController和DPScrollPageTitleView 是我自己封装的两个控件
     DPScrollPageController 用来控制滚动页的，是ViewController
     DPScrollPageTitleView  是用来显示标题栏的，是View
     
     别的项目也可以直接那来用
     */
    UIView *View=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    View.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    [self.view addSubview:View];
    
    // 添加标题栏，标题栏是用Getter方法创建的，详情见Getter方法
    [View addSubview:self.scrollTitleView];
    
    // 添加滚动页控件，也是用Getter方法创建的，是一个ViewController，所以用ChildViewController的方式创建
    [self addChildViewController:self.scrollPageController];
    [self.view addSubview:self.scrollPageController.view];
    [self.scrollPageController didMoveToParentViewController:self];
    
    // 设置要显示的各个ViewController的数组
    self.scrollPageController.viewControllers = [NSMutableArray arrayWithArray:self.newsViewControllers];
    
    // 设置自动调整ScrollView的ContentInset
    self.automaticallyAdjustsScrollViewInsets = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden=YES;
}
#pragma mark - DPScrollPageControllerDelegate

// DPScrollPage的代理方法，滚动的时候调用
- (void)scrollPage:(DPScrollPageController *)scrollPage didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex scale:(CGFloat)scale
{
    UILabel *fromTitleLabel = [self.scrollTitleView titleLabelForIndex:fromIndex];
    UILabel *toTitleLabel = [self.scrollTitleView titleLabelForIndex:toIndex];
    
    // 滚动的时候调整TitleLabel的颜色
    fromTitleLabel.textColor = [UIColor colorWithRed:233/255.0f green:186/255.0f blue:189/255.0f alpha:1];
    toTitleLabel.textColor = [UIColor whiteColor];
    
    // 滚动的时候调整TitleLabel的大小
    CGFloat p = 0.1*scale;
    fromTitleLabel.transform = CGAffineTransformMakeScale(1.1-p, 1.1-p);
    toTitleLabel.transform = CGAffineTransformMakeScale(1+p, 1+p);
}

// DPScrollPage的代理方法，滚动停止是调用
- (void)scrollPage:(DPScrollPageController *)scrollPage didEndScrollToIndex:(NSInteger)toIndex
{
    // 让对应的标题在屏幕上可见
    [self.scrollTitleView scrollToCenterForTitleLabelAtIndex:toIndex];
}


#pragma mark - DPScrollPageTitleViewDelegate

- (void)scrollPageTitleView:(DPScrollPageTitleView *)titleView titleDidTap:(UILabel *)titleLabel atIndex:(NSInteger)index
{
    
    NSInteger currentIndex = self.scrollPageController.currentIndex;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"IDPage" object:nil userInfo:@{@"index":@(index)}];
    
    UILabel *currentLabel = [self.scrollTitleView titleLabelForIndex:currentIndex];
    currentLabel.textColor =[UIColor colorWithRed:233/255.0f green:186/255.0f blue:189/255.0f alpha:1];
    currentLabel.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    
    [self.scrollPageController scrollToPageAtIndex:index animated:NO];
}


#pragma mark - Getter

- (DPScrollPageController *)scrollPageController
{
    if (_scrollPageController == nil) {
        _scrollPageController = [[DPScrollPageController alloc] init];
        _scrollPageController.view.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-44);
        _scrollPageController.delegate = self;
    }
    
    return _scrollPageController;
}

- (DPScrollPageTitleView *)scrollTitleView
{
    if (_scrollTitleView == nil) {
        _scrollTitleView = [[DPScrollPageTitleView alloc] initWithFrame:CGRectMake(0, 24, kScreenWidth, 30) titles:self.titles itemWidth:55];
        _scrollTitleView.delegate = self;
        
        UILabel *firstLabel = [_scrollTitleView titleLabelForIndex:0];
        firstLabel.textColor = [UIColor whiteColor];
        firstLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }
    
    return _scrollTitleView;
}

- (NSArray *)newsViewControllers
{
    if (_newsViewControllers == nil) {
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (int i=0; i<self.titles.count; i++) {
            VideoVC *newsVC = [[VideoVC alloc] initWithNibName:@"VideoVC" bundle:nil];
            newsVC.urlString = self.urlStrings[i%self.titles.count];
            
            [tempArr addObject:newsVC];
        }
        
        _newsViewControllers = [[NSArray alloc] initWithArray:tempArr];
    }
    
    return _newsViewControllers;
}
- (NSArray *)titles
{
    if (_titles == nil) {
        _titles = @[@"推荐",@"搞笑",@"猎奇",@"新闻",@"女神", @"八卦", @"体育",@"黑科技", @"宠物",@"宝宝",@"涨姿势",@"男神",@"旅行",@"美妆",@"美食",@"明星"];
        
    }
    return _titles;
}

- (NSArray *)urlStrings
{
    
    if (_urlStrings == nil) {
        _urlStrings = @[@"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=0",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=1",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=13",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=11",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=3",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=12",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=14",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=15",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=10",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=9",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=8",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=7",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=6",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=5",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=4",
                        @"http://wz.lefei.com/?m=Api&c=video&a=getList&c_id=2"];
    }
    
    return _urlStrings;
}

@end
