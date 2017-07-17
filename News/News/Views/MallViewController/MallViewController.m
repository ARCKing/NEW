//
//  MallViewController.m
//  News
//
//  Created by ZZG on 16/6/2.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "MallViewController.h"
#import "ZGManagerHUD.h"
#import "ZGNetAPI.h"
#import "AFNetworking.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface MallViewController ()<UIWebViewDelegate>

@property (nonatomic ,strong)UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *Myview;
@property (weak, nonatomic) IBOutlet UILabel *NAmeLabel;
@end

@implementation MallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self observeNetStatus];
}
-(void)viewWillAppear:(BOOL)animated
{
    [ZGManagerHUD showHUDViewController:self.tabBarController];
}
//监测网络状态
- (void)observeNetStatus
{
    //开始监控
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    //当网络状态发生改变时,回调的block
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            //没网
            [ZGManagerHUD hidesHUDComplection:nil];
        }else{
            [self createWEBView];
        }
    }];
}

//网页加载视图
-(void)createWEBView
{
    //网页加载视图
    self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth , kScreenHeight-64)];
    //如何加载链接
    //1.添加请求网址类
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@&authcode=%@",KURL_Level,[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    //将网址转换成请求类
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    //3.加载请求
    [self.webView loadRequest:request];
    
    //属性
    //1.设置网页自适应视图大小
    self.webView.scalesPageToFit=YES;
    self.webView.dataDetectorTypes =UIDataDetectorTypeLink;
    self.webView.delegate=self;
    //  监测网页加载进度  需要遵循协议 设置代理
    [self.view addSubview:self.webView];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ZGManagerHUD hidesHUDComplection:nil];
}
- (IBAction)BTNclicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
