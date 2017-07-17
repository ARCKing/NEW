//
//  DetailsViewController.m
//  
//
//  Created by siyue on 16/5/21.
//
//

#import "DetailsViewController.h"
#import "NJKWebViewProgressView.h"

#import "AFNetworking.h"
#import "ChatView.h"
#import "ZGNetAPI.h"
#import "ZGPromptView.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "CollectionManager.h"
#import "newsViewController.h"
#import "commentsVC.h"
#import "UCShareView.h"

static int i=1;
#define isiOS8 __IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_8_0

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface DetailsViewController ()<UITextFieldDelegate,UITextViewDelegate,UIWebViewDelegate>

{
    UIWebView *webView;
    //判断是收藏YES 还是取消收藏NO  默认是NO
    BOOL _isb;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

//背景
@property (nonatomic ,strong)UIView *MyView;

@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UIButton *btn;
@property (nonatomic,strong)UIButton *btn2;
@property (nonatomic,strong)UIButton *btn3;
@property (nonatomic,strong)UIButton *btn4;
@property (nonatomic ,strong)UIButton *shareBtn;

//存取从数据库中提取的数据
@property (nonatomic,strong)NSMutableArray *DataSource;

//要分享的内容
@property (nonatomic ,copy)NSString *textToShare;
@property (nonatomic ,copy)NSString *imageToShare;
@property (nonatomic ,copy)NSString *URLToshare;
@property (nonatomic ,strong)ChatView *chatView;
@property (nonatomic ,strong)UITextField *commentsTF;
@property (nonatomic ,copy)NSString  *autcode;


//小标显示多少条信息
@property (nonatomic ,strong)UILabel *numberLabel;
@property (nonatomic ,strong)UIView *customView;


//==============================
@property (nonatomic,strong)UCShareView * ucShare;
@property (nonatomic,copy)NSString * ucShareLink;
@property (nonatomic,copy)NSString * sharelink;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWebView];
    
    //获取评论数目
    [self UpdataFromcommentsNumber];
    
    [self createUI];
    
    //监测网络状态
    [self observeNetStatus];
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_progressView removeFromSuperview];
    webView.delegate = nil;
    [webView loadHTMLString:@"" baseURL:nil];
    [webView stopLoading];
    [webView removeFromSuperview];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

-(void)createWebView
{
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 46, kScreenWidth, kScreenHeight-46-44)];
    webView.delegate=self;
    webView.delegate = _progressProxy;
    webView.scrollView.backgroundColor=[UIColor whiteColor];
    _progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, 20+navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //如何加载链接
    //1.添加请求网址类
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://wz.lefei.com/?m=api&c=article&a=app_article_info&article_id=%@",self.DetailID]];
    
    NSString * urlstr =[NSString stringWithFormat:@"http://wz.lefei.com/?m=api&c=article&a=app_article_info&article_id=%@",self.DetailID];
    
    NSLog(@"%@",urlstr);
    
    
       //将网址转换成请求类
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    //3.加载请求
    [webView loadRequest:request];
    
    //属性
    //1.设置网页自适应视图大小
    webView.scalesPageToFit=YES;
   
    webView.dataDetectorTypes =UIDataDetectorTypeAll;
    //  监测网页加载进度  需要遵循协议 设置代理
    
    [self.view addSubview:webView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    
    
    
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
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"请检查网络是否断开"];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else
        {
            //其他三种情况,都从网络上获取数据
            [self UPdataNetWoring];
        }
    }];
}

//获取评论数目
-(void)UpdataFromcommentsNumber
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    [manager POST:KURL_publishedNumber parameters:@{@"article_id":self.DetailID} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict=responseObject[@"data"];
        
        if ([dict[@"comments"] intValue]>0) {
            [self createNumberPinglun:dict[@"comments"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

-(void)createNumberPinglun:(NSString *)str
{
    self.numberLabel=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-120, 5, 12, 12)];
    self.numberLabel.font=[UIFont systemFontOfSize:8];
    [self.numberLabel setTextAlignment:NSTextAlignmentCenter];
    self.numberLabel.text=[NSString stringWithFormat:@"%@",str];
    self.numberLabel.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    self.numberLabel.textColor=[UIColor whiteColor];
    self.numberLabel.layer.cornerRadius=6;
    self.numberLabel.layer.masksToBounds=YES;
    [self.customView addSubview:self.numberLabel];
}

-(void)UPdataNetWoring
{
     AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    [manager POST:KURL_Detail parameters:@{@"article_id":self.DetailID,@"authcode":self.autcode} success:^(NSURLSessionDataTask *task, id responseObject) {
        

        
        NSDictionary *dict=responseObject[@"data"];
        NSLog(@"detail = %@",dict);

        self.ucShareLink = dict[@"ucshare"];
        NSLog(@"_ucShareLink = %@",_ucShareLink);
        
        self.sharelink = dict[@"slink"];
        NSLog(@"_sharelink = %@",_sharelink);

        
        self.URLToshare=dict[@"link"];
        self.textToShare=dict[@"share_title"];
        self.imageToShare=dict[@"thumb"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

//视图将出现在屏幕之前，马上这个视图就会被展现在屏幕上了   用来查看刚进来的图标
-(void)viewWillAppear:(BOOL)animated
{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Login"] intValue]==1) {
        self.autcode=[[[NSUserDefaults standardUserDefaults] objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        self.autcode=@"";
    }
    //创建一个通知
    [self postNotification];
    // 注册键盘回收 与 弹起的通知
    [self addNotification];
    
    [self.view addSubview:_progressView];
    
    [super viewWillAppear:animated];
    //清空数组
    [self.DataSource removeAllObjects];
    
    CollectionManager *manager=[CollectionManager shareManager];
    
    // FMResultSet结果集，用来表示查询到的数据
    FMResultSet *rs = [manager.CollectionDataBase executeQuery:@"select * from Collection"];
    
    // 遍历结果集，next让结果集的指针指向下一条记录(下一行数据)，如果有数据，就返回YES，没有数据，就返回NO
    while ([rs next]) {
        // stringForColumn 取到当前指针指向的记录中，对应的字段的值，把取出来的值转成String
        NSString *sidStr = [rs stringForColumn:@"title"];
        [self.DataSource addObject:sidStr];
    }
    
    for (NSString *titlestr in self.DataSource) {
        if ([titlestr isEqualToString:self.Title]) {
           [self.btn setImage:[UIImage imageNamed:@"favorite_yes"] forState:UIControlStateNormal];
            [self.shareBtn setImage:[UIImage imageNamed:@"new_love_tabbar_selected"] forState:UIControlStateNormal];
            //程序启动   就来查看数据库中是否收藏过  这里有相同的也就是YES
            _isb=YES;
        }
    }
}
-(void)createUI
{
    
    UIView *view=[[UIView alloc ]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    view.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    [self.view addSubview:view];

    //    返回
    self.button=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setImage:[[UIImage imageNamed:@"setting_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    self.button.frame=CGRectMake(10, 30, 25 , 25);
    [view addSubview:self.button];
    
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 20, 60, 40);
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=10;
    [view addSubview:button];
    
    
    //    收藏
    self.btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn setImage:[UIImage imageNamed:@"favorite_no"] forState:UIControlStateNormal];
    self.btn.frame=CGRectMake(self.view.bounds.size.width-120, 28, 23, 23);
    [self.btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];

    self.btn.tag=11;
    [view  addSubview:self.btn];
    
    //    分享
    self.btn2=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn2 setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    self.btn2.frame=CGRectMake(self.view.bounds.size.width-80, 28, 25, 25);
    [view  addSubview:self.btn2];
    
    self.btn3=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn3 setImage:[UIImage imageNamed:@"ic_getbonus"] forState:UIControlStateNormal];
    self.btn3.frame=CGRectMake(self.view.bounds.size.width-54, 30, 40, 14);
    [view  addSubview:self.btn3];
    
    
    self.btn4=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn4.frame=CGRectMake(self.view.bounds.size.width-90, 20, 80, 40);
    [self.btn4 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.btn4.tag=12;
    [view  addSubview:self.btn4];
    
    
    self.customView=[[UIView alloc]initWithFrame:CGRectMake(-0.5, kScreenHeight-44, kScreenWidth+1, 44)];
    self.customView.layer.borderWidth=0.5;
    self.customView.layer.borderColor=[UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1].CGColor;
    self.customView.layer.masksToBounds=YES;
    self.customView.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame=CGRectMake(kScreenWidth-45, 7, 26, 26);
    [btn1 setImage:[UIImage imageNamed:@"new_share_tabbar_normal"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn1.tag=12;
    [self.customView addSubview:btn1];

    
    self.shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.shareBtn.frame=CGRectMake(kScreenWidth-90, 7, 26, 26);
    [self.shareBtn setImage:[UIImage imageNamed:@"new_love_tabbar"] forState:UIControlStateNormal];
    [self.shareBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.shareBtn.tag=11;
    [self.customView addSubview:self.shareBtn];
    
    
    
    UIButton *commentsBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    commentsBtn.frame=CGRectMake(kScreenWidth-145, 7, 26, 26);
    [commentsBtn setImage:[UIImage imageNamed:@"new_review_tabbar"] forState:UIControlStateNormal];
    [commentsBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    commentsBtn.tag=13;
    [self.customView addSubview:commentsBtn];
    
    
    self.commentsTF=[[UITextField alloc]initWithFrame:CGRectMake(15, 8, kScreenWidth-170, 28)];
    self.commentsTF.layer.cornerRadius=15;
    self.commentsTF.layer.masksToBounds=YES;
    self.commentsTF.placeholder=@"写评论...";
    self.commentsTF.font=[UIFont systemFontOfSize:13];
    self.commentsTF.enabled=YES;
    [self.customView addSubview:self.commentsTF];
    self.commentsTF.backgroundColor=[UIColor whiteColor];
    self.commentsTF.delegate=self;
    UIView *offsetview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 5)];
    self.commentsTF.leftView = offsetview;
    self.commentsTF.leftViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:self.customView];
    
    
    UIButton *pinglunBtn=[[UIButton alloc]initWithFrame:CGRectMake(15, 0, kScreenWidth-170, 44)];
    [pinglunBtn addTarget:self action:@selector(pinglunClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.customView addSubview:pinglunBtn];
}


-(void)pinglunClicked:(UIButton *)btn
{
    //
    self.MyView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    self.MyView.backgroundColor=[UIColor blackColor];
    self.MyView.alpha=0;
    [self.view addSubview:self.MyView];
    
    [UIView transitionWithView:self.MyView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.MyView.alpha=0.7;
    } completion:NULL];
    
    
    //聊天框
    self.chatView=[[NSBundle mainBundle]loadNibNamed:@"ChatView" owner:self options:0][0];
    
    self.chatView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 200);
    
    [self.chatView.cancelBtn addTarget:self action:@selector(publishedClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.chatView.publishedBtn addTarget:self action:@selector(publishedClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chatView];
    self.chatView.MYTextView.delegate=self;
    self.chatView.placeLabel.enabled = NO;
    
    [self.chatView.MYTextView becomeFirstResponder];
}
-(void)textViewDidChange:(UITextView *)textView
{

    if (self.chatView.MYTextView.text.length == 0) {
        self.chatView.placeLabel.hidden=NO;
    }else{
        self.chatView.placeLabel.hidden=YES;
    }
}

-(void)publishedClicked:(UIButton *)btn
{
    if (btn.tag==10) {
        //慢慢画下聊天框
        [self DeclineinView];
    }else if (btn.tag==11){
    //发表评论
    
        if (self.chatView.MYTextView.text.length!=0) {
           [self POSTData];
        }
        
    }
}

-(void)POSTData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    NSDictionary *dict=@{@"authcode":self.autcode,@"article_id":self.DetailID,@"parent_id":@"0",@"message":self.chatView.MYTextView.text,@"title":self.textToShare,@"url":self.URLToshare};

    [manager POST:KURL_published parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        //慢慢画下聊天框
        [self DeclineinView];
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //慢慢画下聊天框
    [self DeclineinView];
}

-(void)DeclineinView
{
    [self.commentsTF resignFirstResponder];
    self.commentsTF.text=@"";
    [self.chatView.MYTextView resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.chatView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 200);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            [UIView transitionWithView:self.MyView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.MyView.alpha=0.0;
                self.MyView.hidden=YES;
            } completion:NULL];
        }];
    }];
}

-(void)btnClicked:(UIButton *)btn
{
    if(btn.tag==10){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (btn.tag==12){
        NSLog(@"分享");
//         //分享  先把图片转换成二进制
//         NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageToShare]];
//        UIImage *Image=[UIImage imageWithData:data scale:1];
//        NSArray *activityItems = @[self.textToShare,Image,[NSURL URLWithString:self.URLToshare]] ;
//
        NSLog(@"URLToshare = %@",self.URLToshare);
//        NSLog(@"=[%@]=",self.URLToshare);
//        
//        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
//        [self presentViewController:activity animated:YES completion:nil];
        
//        =======================================
//        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        
        self.ucShare = [[UCShareView alloc]initWithFrame:self.view.bounds];
        self.ucShare.backgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.9];
        [self.view addSubview:_ucShare];
        
        [self.ucShare.weixinFriend addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.ucShare.weixin addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.ucShare.QQ addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.ucShare.QZone addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
//        [self.ucShare.sinaWeiBo addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.ucShare.URLCopy addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.ucShare.exitShare addTarget:self action:@selector(shareExitButtonAction) forControlEvents:UIControlEventTouchUpInside];

        
        
        
        
        
        
        
    }else if (btn.tag==11) {
        //收藏
        //清空数组
        [self.DataSource removeAllObjects];
        
        _isb=!_isb;
        
        if (_isb==NO) {
            [self endFocus];
        // 防止一边删除一边添加
            return;
        }
 
        CollectionManager *manager=[CollectionManager shareManager];
        // FMResultSet结果集，用来表示查询到的数据
        FMResultSet *rs = [manager.CollectionDataBase executeQuery:@"select * from Collection"];
        
        // 遍历结果集，next让结果集的指针指向下一条记录(下一行数据)，如果有数据，就返回YES，没有数据，就返回NO
        while ([rs next]) {
            // stringForColumn 取到当前指针指向的记录中，对应的字段的值，把取出来的值转成String
            NSString *sidStr=[rs stringForColumn:@"renwuID"];
            [self.DataSource addObject:sidStr];
        }
        for (NSString *titlestr in self.DataSource) {
            if ([titlestr isEqualToString:self.DetailID]) {
                //如果收藏过  就不能再收藏
                return;
            }
        }
        //插入数据
        if(! [manager.CollectionDataBase executeUpdate:@"insert into Collection (renwuID,title) values(?,?)",self.DetailID
              ,self.Title])
        {
            NSLog(@"数据插入失败");
        }
        _isb=YES;
        //将提示框加载到webView上   显示收藏成功
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"收藏成功" withImage:[UIImage imageNamed:@"show_ok"]];
        if (_isb) {
           [self.btn setImage:[UIImage imageNamed:@"favorite_yes"] forState:UIControlStateNormal];
             [self.shareBtn setImage:[UIImage imageNamed:@"new_love_tabbar_selected"] forState:UIControlStateNormal];
        }
    }else if (btn.tag==13){
    
        commentsVC *CommentVC=[[commentsVC alloc]initWithNibName:@"commentsVC" bundle:nil];
        
        CommentVC.Dict=@{@"authcode":self.autcode,@"article_id":self.DetailID,@"parent_id":@"0",@"title":self.textToShare,@"url":self.URLToshare};
        CommentVC.DetailID=self.DetailID;
        [self.navigationController pushViewController:CommentVC animated:YES];
        
    }
}


#pragma mark- uc分享buttonAction
- (void)shareButtonAction:(UIButton *)bt{
    
    NSArray *cutArray = [_sharelink componentsSeparatedByString:@"="];
    
    NSLog(@"%@",cutArray);
    
    if (cutArray.count >2) {
        
        NSString * uID = cutArray[2];
        
        NSString * newLink = [NSString stringWithFormat:@"%@/u/%@",_ucShareLink,uID];

        _ucShareLink = newLink;
        NSLog(@"newLink= %@",_ucShareLink);

    }
    
    
    //判断是否安装有UC
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ucbrowser://"]] && bt.tag != 1114){
        
        NSLog(@"没有安装UC");
        
        UIAlertController * alertControll = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有安装UC浏览器，无法分享" preferredStyle: UIAlertControllerStyleAlert];
        
        [alertControll addAction:[UIAlertAction actionWithTitle:@"去下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"现在去下载");
            
            
            static NSString * const reviewURL = @"https://itunes.apple.com/cn/app/uc-liu-lan-qi-6yi-ren-shang/id586871187?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
            

            
        }]];
        
        [alertControll addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"取消");
            
        }]];

        
        [self presentViewController:alertControll animated:YES completion:^{
            
            NSLog(@"提示框来了!");
            
        }];
        
        [self.ucShare removeFromSuperview];
        return;
        
    }
    
    if (bt.tag == 1110) {
        NSLog(@"微信朋友圈分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/wechat_moments",_ucShareLink]]];
        
        NSLog(@"%@",[NSString stringWithFormat:@"ucbrowser://%@/sharetype/weixinFriend",_ucShareLink]);
        
    }else if (bt.tag == 1111) {
        NSLog(@"微信好友分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/wechat_friend",_ucShareLink]]];
        
        NSLog(@"%@",[NSString stringWithFormat:@"ucbrowser://%@/sharetype/wechat_moments",_ucShareLink]);

    }
//    else if (bt.tag == 1112) {
////        NSLog(@"新浪分享");
////        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=sinaweibo"]];
////        
//    }
    else if (bt.tag == 1112) {
        NSLog(@"QQ分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_mobile",_ucShareLink]]];
        
        NSLog(@"%@",[NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_mobile",_ucShareLink]);
        
    }else if (bt.tag == 1113) {
        
        NSLog(@"QQ空间分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_zone",_ucShareLink]]];
        
        NSLog(@"%@",[NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_zone",_ucShareLink]);

        
    }else if (bt.tag == 1114) {
        NSLog(@"复制分享链接");
        //       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixin"]];
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _ucShareLink;
        
        if (pasteboard.string != nil) {
            
            UIAlertController * alertControll = [UIAlertController alertControllerWithTitle:@"复制成功" message:nil preferredStyle: UIAlertControllerStyleAlert];
            
            [self presentViewController:alertControll animated:YES completion:^{
                
                NSLog(@"提示框来了!");
                
            }];
            
            [self performSelector:@selector(removeAlerateFromSuperView:) withObject:self afterDelay:1];
            
            
        }else {
            UIAlertController * alertControll = [UIAlertController alertControllerWithTitle:@"复制失败" message:nil preferredStyle: UIAlertControllerStyleAlert];
            
            [self presentViewController:alertControll animated:YES completion:^{
                
                NSLog(@"提示框来了!");
                
            }];
            
            [self performSelector:@selector(removeAlerateFromSuperView:) withObject:self afterDelay:1];
            
        }
        
        [self.ucShare removeFromSuperview];
        
    }
    [self.ucShare removeFromSuperview];

}


#pragma maark- 取消分享
- (void)shareExitButtonAction{
    NSLog(@"取消分享");
    [self.ucShare removeFromSuperview];
    
}

//提示框消失
- (void)removeAlerateFromSuperView:(UIAlertController *)alertControll{
    
    [alertControll dismissViewControllerAnimated:YES completion:nil];
    
}



//取消关注
-(void)endFocus
{
    _isb=NO;

    NSString *str=[NSString stringWithFormat:@"DELETE FROM Collection WHERE renwuID ='%@'",self.DetailID];
    CollectionManager *manager=[CollectionManager shareManager];
    if ([manager.CollectionDataBase executeUpdate:str]) {
        
        [self.btn setImage:[UIImage imageNamed:@"favorite_no"] forState:UIControlStateNormal];
         [self.shareBtn setImage:[UIImage imageNamed:@"new_love_tabbar"] forState:UIControlStateNormal];
    }
}

#pragma make--

-(NSMutableArray *)DataSource
{
    if (_DataSource==nil) {
        _DataSource=[[NSMutableArray alloc]init];
    }
    return _DataSource;
}

#pragma mark--键盘弹起与回落

// 创建一个通知
- (void)postNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:@"123" object:nil];
}
-(void)notification:(NSNotification *)noti
{
}
// 监控键盘弹起与回收
- (void)addNotification
{
    // 注册两个通知 监听键盘弹起 和 回收
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
}

// 键盘弹起
- (void)showKeyBoard:(NSNotification *)noti
{
    i++;
    if (i==2) {
        // 获取键盘弹起时间
        float duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey]  floatValue];
        // 获得键盘的高度
        NSValue * value = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
        float height = value.CGRectValue.size.height;
        
        
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.chatView.frame;
            // y值增加  视图下降
            frame.origin.y =kScreenHeight - height-200;
            self.chatView.frame = frame;
        }];
    }
}

// 回收键盘
- (void)hiddenKeyBoard:(NSNotification *)noti
{
    i=1;
    // 获取键盘弹起时间
    float duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey]  floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.chatView.frame;
        // y值增加  视图下降
        frame.origin.y = kScreenHeight;
        self.chatView.frame = frame;
    }];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
