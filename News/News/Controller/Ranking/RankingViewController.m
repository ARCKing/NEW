//
//  RankingViewController.m
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "RankingViewController.h"
#import "HotViewController.h"
#import "UserViewController.h"
#import "AFNetworking.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

static int number=2;

@interface RankingViewController ()<UIScrollViewDelegate>

@property (nonatomic ,strong)UIScrollView * scrollView;

@property (nonatomic ,strong)UISegmentedControl *segmengedView;

@property (nonatomic ,strong) UIView *Myview;

@end

@implementation RankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.Myview=[[UIView alloc ]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    self.Myview.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    [self.view addSubview:self.Myview];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self createData];

    self.view.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
}

-(void)createData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager GET:@"http://wz.lefei.com/Api/Ban/getMemberBan?order_type=3&type=ios" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arr=responseObject[@"data"];
        if (arr.count==0) {
            number=1;
        }
       [self createUI];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden=YES;
    self.segmengedView.hidden=NO;
}
//页面即将消失
-(void)viewWillDisappear:(BOOL)animated
{
    self.segmengedView.hidden=YES;
}

// 页面滑动用户榜与热点榜切换
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentIndex = scrollView.contentOffset.x / self.view.bounds.size.width;

    if (currentIndex==0) {
         self.segmengedView.selectedSegmentIndex = 0;
    }else{
     self.segmengedView.selectedSegmentIndex = 1;
    }
    
}
//界面搭载
-(void)createUI
{
    if (number==1) {
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 24, kScreenWidth, 24)];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor whiteColor];
        label.text=@"热点榜";
        
        [self.Myview addSubview:label];
    }else{
    
        self.segmengedView=[[UISegmentedControl alloc]initWithFrame:CGRectMake(kScreenWidth/2-50, 25, 100, 25)];
        [self.segmengedView insertSegmentWithTitle:@"热点榜" atIndex:0 animated:YES];
        [self.segmengedView insertSegmentWithTitle:@"用户榜" atIndex:1 animated:YES];

    }
    
    // 开启时默认第一个选中
    self.segmengedView.selectedSegmentIndex = 0;
    // 修改颜色
    self.segmengedView.tintColor = [UIColor whiteColor];
    // 点击事件
    [self.segmengedView addTarget:self action:@selector(segmented:) forControlEvents:UIControlEventValueChanged];
    
    [self.Myview addSubview:self.segmengedView];
    
    
    self.scrollView= [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-44)];
    // 隐藏横向滚动条
    self.scrollView.showsHorizontalScrollIndicator = NO;
    // 按页翻滚
    self.scrollView.pagingEnabled = YES;
    // 内容大小
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * number, kScreenHeight-64-44);
    self.scrollView.delegate=self;
    [self.view addSubview:self.scrollView];
    
    
    HotViewController *hot=[[HotViewController alloc]initWithNibName:@"HotViewController" bundle:nil];
    hot.view.frame=CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-44);
    
    UserViewController *user=[[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil];
    user.view.frame=CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight-64-44);
    
    [self addChildViewController:hot];
    [self addChildViewController:user];
    
    [self.scrollView addSubview:hot.view];
    [self.scrollView addSubview:user.view];
    
}

- (void)segmented:(UISegmentedControl *)segmented
{
    if (segmented.selectedSegmentIndex==0) {
        self.scrollView.contentOffset=CGPointMake(0, 0);
    }else if (segmented.selectedSegmentIndex==1){
        self.scrollView.contentOffset=CGPointMake(kScreenWidth, 0);
    }
}
@end
