//
//  VideoVC.m
//  New/Users/zzg/Desktop/News/News.xcodeprojs
//
//  Created by ZZG on 16/6/12.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "VideoVC.h"
#import "LoginViewController.h"
#import "MJRefresh.h"
#import "MJRefreshGifHeader.h"
#import "ZGNetAPI.h"

#import "jubaoVC.h"
#import "VideoManager.h"
#import "UIImageView+WebCache.h"
#import "VideoModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "VideoCell.h"
#import "UIViewExt.h"
#import "HTPlayer.h"
#import "ZGPromptView.h"
#import "UCShareView.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)
#define Screen_W [UIScreen mainScreen].bounds.size.width
#define Screen_H [UIScreen mainScreen].bounds.size.height

//页码
static int page=1;

//数据库存取的id号
static int number=0;

//播放的时候是否为WiFi
static int ISNetWorking=1;

//判断是否播放
static int Login=0;

@interface VideoVC ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat poingY;
     BOOL _isb;
}
@property (weak, nonatomic) IBOutlet UITableView *MyTableview;
@property (strong, nonatomic)NSIndexPath *currentIndexPath;
@property (strong, nonatomic)VideoCell *currentCell;//当前播放的cell
@property (strong, nonatomic)HTPlayer *htPlayer;
@property (assign, nonatomic)BOOL isSmallScreen;
// 也需要做成成员变量
@property (nonatomic, strong) MPMoviePlayerController *videoPlayerController;
@property (nonatomic ,strong)NSMutableArray *DataSource;
@property (nonatomic ,strong)NSArray *array;
@property (nonatomic ,strong)UIView *Myview;
@property (nonatomic ,strong) UIActivityIndicatorView *ActivityVC;
@property (nonatomic ,strong)MJRefreshGifHeader *header;
@property (nonatomic ,strong)UIViewController *lastVC;


@property (nonatomic, strong) NSString *appKey;


@property (nonatomic,strong)UCShareView * ucShare;
@property (nonatomic,copy)NSString * shareLink;

@end

@implementation VideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    Login =[[[NSUserDefaults standardUserDefaults]objectForKey:@"Login"]intValue];

    
    //创建Cell
    [self createCell];
    self.array=@[@"video",@"video1",@"video2",@"video3",@"video4",@"video5",@"video6",@"video7",@"video8",@"video9",@"video10",@"video11",@"video12",@"video13",@"video14",@"video15"];
    
    //数据缓存的逻辑.首先读取数据库内容,刷新到表格之上.再根据网络状况来向服务器发起请求.服务器数据返回,将本地数据库清空,再插入一次.
    [self getDataFromDataBase];
    [self performSelector:@selector(Createheader) withObject:self afterDelay:0.1];
    [self createFoot];
    //通知
    [self addObserver];
}

-(void)Createheader
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(observeNetStatus)];
    self.header.mj_h=60;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 0; i<=49; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"gif_earth_%ld", i]];
        [idleImages addObject:image];
    }
    [self.header setImages:idleImages forState:MJRefreshStateIdle];
    [self.header setImages:idleImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [self.header setImages:idleImages forState:MJRefreshStateRefreshing];
    // 马上进入刷新状态
    [self.header beginRefreshing];
    
    // 设置header
    self.MyTableview.mj_header = self.header;
}
-(void)createFoot
{
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.MyTableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //页码++ ,再次请求数据
        page ++;
        [self Updata];
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    Login =[[[NSUserDefaults standardUserDefaults]objectForKey:@"Login"]intValue];
    
    
    NSLog(@"Login = %d",Login);
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabbarClicked) name:@"DidSelectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popDetail:)name:kHTPlayerPopDetailNotificationKey object:nil];
}

// 视图已经被从屏幕上移除，用户看不到这个视图了
-(void)viewDidDisappear:(BOOL)animat
{
    [_htPlayer.player pause];
    [_htPlayer removeFromSuperview];
    [self releaseWMPlayer];
    //视图消失  移除所有的通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//点击Tabbar回到顶部刷新
-(void)tabbarClicked
{
    if (self.tabBarController.selectedViewController==self.lastVC) {
        
        [self.MyTableview setContentOffset:CGPointMake(0, 0) animated:NO];
        [self Createheader];
        //让播放暂停
        [_htPlayer.player pause];
        [_htPlayer removeFromSuperview];
        [_htPlayer releaseWMPlayer];
    }
    //记录点击的是不是同一个TabbarController.selectedViewController
    self.lastVC=self.tabBarController.selectedViewController;
}

-(void)IDpage:(NSNotification *)noti
{
    number=[noti.userInfo[@"index"] intValue];
}
-(void)StopPlayer:(NSNotification *)noti
{
    //让播放暂停
    [_htPlayer removeFromSuperview];
    [self releaseWMPlayer];
}

- (void)addObserver
{
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(IDpage:) name:@"IDPage" object:nil];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(StopPlayer:) name:@"Video" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabbarClicked) name:@"DidSelectNotification" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:) name:kHTPlayerFinishedPlayNotificationKey object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:kHTPlayerFullScreenBtnNotificationKey object:nil];
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
            [_htPlayer.player pause];
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"请检查网络状态"];
            ISNetWorking=0;
            [self.MyTableview.mj_header endRefreshing];
            //没网
        }else{
            if (status==AFNetworkReachabilityStatusReachableViaWiFi){
                ISNetWorking=2;
            }//其他三种情况,都从网络上获取数据
            [self getDataFromNet];
        }
    }];
}
- (void)getDataFromDataBase
{
    [self.DataSource removeAllObjects];
    //读取,查询
    VideoManager *manager = [VideoManager shareManager];
    NSString *SQLStr=[NSString stringWithFormat:@"select * from %@ ",self.array[number]];
    FMResultSet *rs = [manager.VideoDataBase executeQuery:SQLStr];
    //遍历查询的结果,用模型装起来
    while ([rs next])
    {
        VideoModel *model = [[VideoModel alloc]init];
        model.caption = [rs stringForColumn:@"caption"];
        model.user_name=[rs stringForColumn:@"user_name"];
        model.likes_count=[rs stringForColumn:@"likes_count"];
        model.video=[rs stringForColumn:@"video"];
        model.user_avatar=[rs stringForColumn:@"user_avatar"];
        model.video_id=[rs stringForColumn:@"video_id"];
        model.cover_pic=[rs stringForColumn:@"cover_pic"];
        [self.DataSource addObject:model];
    }
    //加载数据库里面的东西直接加载不用动画
    _isb=NO;
    if (self.DataSource.count!=0) {
        self.MyTableview.hidden=NO;
    }else{
        self.MyTableview.hidden=YES;
    }
    //刷表
    [self.MyTableview reloadData];
}
-(void)videoDidFinished:(NSNotification *)notice{
    
    if (_htPlayer.screenType == UIHTPlayerSizeFullScreenType){
        [self toCell];//先变回cell
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _htPlayer.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_htPlayer removeFromSuperview];
        [self releaseWMPlayer];
    }];
}
-(void)fullScreenBtnClick:(NSNotification *)notice{
    
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        if (_isSmallScreen) {
            [_htPlayer releaseWMPlayer];
            _htPlayer = nil;
            _currentIndexPath = nil;
            
        }else{
            [self toCell];
        }
    }
}
-(void)releaseWMPlayer{
    
    [_htPlayer releaseWMPlayer];
    _htPlayer = nil;
    _currentIndexPath = nil;
}

//结束的时候触发
#pragma mark--MJRefreshBaseViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //如果下拉超过60个像素或者上拉到底部   播放器停止
    if (scrollView.contentOffset.y < -60||scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height-100)
    {
        //让播放暂停
        [_htPlayer removeFromSuperview];
        [self releaseWMPlayer];
    }
}
#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    if (poingY>=scrollView.contentOffset.y) {
        _isb=NO;
    }else{
        _isb=YES;
    }
    if(scrollView ==self.MyTableview){
        if (_htPlayer==nil) return;
        
        if (_htPlayer.superview) {
            CGRect rectInTableView = [self.MyTableview rectForRowAtIndexPath:_currentIndexPath];
            CGRect rectInSuperview = [self.MyTableview convertRect:rectInTableView toView:[self.MyTableview superview]];
            
            
            if (rectInSuperview.origin.y<-self.currentCell.backView.height||rectInSuperview.origin.y>self.view.height) {//往上拖动
                
                if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:_htPlayer]) {
   
                    //让播放暂停
                    [_htPlayer.player pause];
                    [_htPlayer removeFromSuperview];
                }
                
            }else{
                if (![self.currentCell.backView.subviews containsObject:_htPlayer]) {
                    [self toCell];
                }
            }
        }
        
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (poingY<scrollView.contentOffset.y) {
        poingY=scrollView.contentOffset.y;
    }
}
//结束的时候触发
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (poingY<scrollView.contentOffset.y) {
        poingY=scrollView.contentOffset.y;
    }
}

-(void)toCell{
    
    self.currentCell = (VideoCell *)[self.MyTableview cellForRowAtIndexPath:_currentIndexPath];
    [_htPlayer reductionWithInterfaceOrientation:self.currentCell.backView];
    _isSmallScreen = NO;
    [self.MyTableview reloadData];
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [_htPlayer toFullScreenWithInterfaceOrientation:interfaceOrientation];
}
-(void)toSmallScreen{
    //放widow上
    _isSmallScreen = YES;
}

- (void)popDetail:(NSNotification *)obj
{
    _htPlayer = (HTPlayer *)obj.object;
    
    if (_htPlayer) {
        if (_isSmallScreen) {

            [_htPlayer releaseWMPlayer];
            _htPlayer = nil;
            _currentIndexPath = nil;
        }else{
            [self toCell];
        }
    }
    [self addObserver];
}
#pragma mark--helper Methods

-(void)createCell
{
    [self.MyTableview registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    self.MyTableview.separatorColor=[UIColor groupTableViewBackgroundColor];
}

//获取数据   和刷新数据
-(void)getDataFromNet
{
    
    NSLog(@"%@",self.urlString);
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager POST:self.urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
         NSArray * dict =  responseObject[@"data"];
        
        NSLog(@"%@",dict);
        
        //清空数组
        [self.DataSource removeAllObjects];
        VideoManager *manager=[VideoManager shareManager];
        NSString *str=[NSString stringWithFormat:@"delete from %@",self.array[number]];
        //数据库清空
        if (![manager.VideoDataBase executeUpdate:str]) {
            NSLog(@"删除失败");
        }
        for (NSDictionary *dict in responseObject[@"data"]) {
            VideoModel *model=[[VideoModel alloc]init];
            
//            =========================
            model.ucshare = dict[@"ucshare"];
            
            model.caption=dict[@"caption"];
            model.cover_pic=dict[@"cover_pic"];
            model.likes_count=dict[@"likes_count"];
            model.user_name=dict[@"user_name"];
            model.video_id=dict[@"video_id"];
            model.video=dict[@"video"];
            model.user_avatar=dict[@"user_avatar"];
            model.link=dict[@"link"];
            [self.DataSource addObject:model];
            
            NSString *SQLStr=[NSString stringWithFormat:@"insert into %@ (caption,cover_pic,user_name,video_id,likes_count,user_avatar,video) values(?,?,?,?,?,?,?)",self.array[number]];
            //插入数据
            if(! [manager.VideoDataBase executeUpdate:SQLStr,dict[@"caption"]
                  ,dict[@"cover_pic"],dict[@"user_name"],dict[@"video_id"],dict[@"likes_count"],dict[@"user_avatar"],dict[@"video"] ])
            {
                NSLog(@"数据插入失败");
            }
        }
        
        if (self.DataSource.count!=0) {
            self.MyTableview.hidden=NO;
        }
            // 刷新表格
        [self.MyTableview reloadData];
        [self.MyTableview.mj_header endRefreshing];
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.MyTableview.mj_header endRefreshing];
    }];
}

//加载更多
-(void)Updata
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSString *URLstr=[NSString stringWithFormat:@"%@&p=%d",self.urlString,page];
    [manager POST:URLstr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *dataArr=responseObject[@"data"];
        if (dataArr.count==0) {
            [self.MyTableview.mj_footer endRefreshingWithNoMoreData];
            return ;
        }
        
        for (NSDictionary *dict in responseObject[@"data"]) {
            
            VideoModel *model=[[VideoModel alloc]init];
            
            model.caption=dict[@"caption"];
            model.cover_pic=dict[@"cover_pic"];
            model.likes_count=dict[@"likes_count"];
            model.user_name=dict[@"user_name"];
            model.video_id=dict[@"video_id"];
            model.user_avatar=dict[@"user_avatar"];
            model.video=dict[@"video"];
            model.link=dict[@"link"];
            [self.DataSource addObject:model];
            
        }
        [self.MyTableview reloadData];
        _isb=NO;
        [self.MyTableview.mj_footer endRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.MyTableview.mj_footer endRefreshing];
    }];
}

#pragma mark--<UITableViewDelegate,UITableViewDataSource>

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
    Cell.model=self.DataSource[indexPath.row];
    
    //分享
    [Cell.ShareBtn addTarget:self action:@selector(ShareClicked:) forControlEvents:UIControlEventTouchUpInside];
    Cell.ShareBtn.tag=indexPath.row;
    
    //点赞
    [Cell.LoveBtn addTarget:self action:@selector(LoveClicked:) forControlEvents:UIControlEventTouchUpInside];
    Cell.LoveBtn.tag=indexPath.row;
    
    [Cell.jubaoBtn addTarget:self action:@selector(jubaoClicked:) forControlEvents:UIControlEventTouchUpInside];
    Cell.jubaoBtn.tag=indexPath.row;
    
    [Cell.TapPlayBtn addTarget:self action:@selector(TapClicked:) forControlEvents:UIControlEventTouchUpInside];
    Cell.TapPlayBtn.tag=indexPath.row;
    
    
    if (_isb==NO) {
        [Cell.ImgView sd_setImageWithURL:[NSURL URLWithString:Cell.model.cover_pic] placeholderImage:nil];
    }else{
        [Cell.ImgView sd_setImageWithURL:[NSURL URLWithString:Cell.model.cover_pic] placeholderImage:[UIImage imageNamed:@"img_default_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            Cell.ImgView.alpha = 0.0;
            [UIView transitionWithView:Cell.ImgView
                              duration:0.7
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [Cell.ImgView setImage:image];
                                Cell.ImgView.alpha = 1.0;
                            } completion:NULL];
        }];
        
    }
    Cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return Cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreenWidth/16*9+60;
}

-(void)TapClicked:(UIButton *)btn
{
    _currentIndexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    self.currentCell = (VideoCell *)[self.MyTableview cellForRowAtIndexPath:_currentIndexPath];
    if (ISNetWorking==1) {
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:@"当前处于移动网络播放，是否切换" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *Cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {//确定播放
            [self Beingloaded:btn.tag];
        }];
        [alertController addAction:Cancel];
        [alertController addAction:confirm];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if(ISNetWorking==2){
        [self Beingloaded:btn.tag];
    }else if(ISNetWorking==0){
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"请检查网络状态"];
    }
}
//显示正在加载加载
-(void)Beingloaded:(NSInteger)num
{
    //确定播放
    [_htPlayer removeFromSuperview];
    [self releaseWMPlayer];
    
    self.Myview=[[UIView alloc]initWithFrame:self.currentCell.backView.bounds];
    self.Myview.backgroundColor=[UIColor blackColor];
    [self.currentCell addSubview:self.Myview];
    
    
    self.ActivityVC=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.ActivityVC.color=[UIColor whiteColor];
    self.ActivityVC.center=CGPointMake(self.currentCell.backView.center.x, self.currentCell.backView.center.y);
    [self.ActivityVC startAnimating];
    [self.Myview addSubview:self.ActivityVC];

    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self SurePlay:num];
    });
}
-(void)SurePlay:(NSInteger)num
{
    [self.Myview removeFromSuperview];
    [self.ActivityVC removeFromSuperview];
    
    _currentIndexPath = [NSIndexPath indexPathForRow:num inSection:0];
    
    self.currentCell = (VideoCell *)[self.MyTableview cellForRowAtIndexPath:_currentIndexPath];
    VideoModel *model = [self.DataSource objectAtIndex:num];
    if (_htPlayer) {
        [_htPlayer removeFromSuperview];
        [_htPlayer setVideoURLStr:model.video];
        
    }else{
        _htPlayer = [[HTPlayer alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth/48*27) videoURLStr:model.video];
    }
    
    [_htPlayer setPlayTitle:model.caption];
    
    [self.currentCell.backView addSubview:_htPlayer];
    [self.currentCell.backView bringSubviewToFront:_htPlayer];
    
    if (_htPlayer.screenType == UIHTPlayerSizeSmallScreenType) {
        [_htPlayer reductionWithInterfaceOrientation:self.currentCell.backView];
    }
    _isSmallScreen = NO;
}

#pragma mark--Setter &Getter

-(NSMutableArray *)DataSource
{
    if (_DataSource==nil) {
        _DataSource=[[NSMutableArray alloc]init];
    }
    return _DataSource;
}
#pragma mark - Event Handlers

-(void)ShareClicked:(UIButton *)btn
{
    [_htPlayer.player pause];


    //有网络
    if (ISNetWorking!=0) {
//        //分享
        VideoModel *model=self.DataSource[btn.tag];
        
        NSLog(@"URLToshare = %@ ",model.ucshare);
        _shareLink = model.ucshare;
        
//        //分享  先把图片转换成二进制
//        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.cover_pic]];
//        UIImage *Image=[UIImage imageWithData:data scale:1];
//        
//        NSArray *activityItems = @[model.caption,Image,[NSURL URLWithString:model.link]] ;
//        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
//        [self presentViewController:activity animated:YES completion:nil];
        
//        ============================================
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

        self.ucShare.bgShareView.frame = CGRectMake(0, Screen_H * 2/3 - 49 - Screen_W/6, Screen_W, Screen_H/3);
        
    }else{
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"请检查网络状态"];
    }
}


#pragma mark- uc分享buttonAction
- (void)shareButtonAction:(UIButton *)bt{
    
    NSString * newShare = nil;

    NSLog(@"Login = %d",Login);

    
    NSLog(@"%ld",bt.tag);
    
    if (Login == 1) {
        NSLog(@"1=已登录");
        
        NSString * uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"uID"];
        
        NSString * Share1 = [_shareLink substringFromIndex:7];
        NSString * share2 = [Share1 substringToIndex:49];
        newShare = [NSString stringWithFormat:@"%@%@",share2,uid];
        NSLog(@"newShare=%@",newShare);
        
        
    }else{
        NSLog(@"0=未登录");
        NSString * Share1 = [_shareLink substringFromIndex:7];
        NSString * share2 = [Share1 substringToIndex:46];
        newShare = share2;
        NSLog(@"newShare=%@",newShare);
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
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/wechat_moments",newShare]]];
        
        NSString * ss = [NSString stringWithFormat:@"ucbrowser://%@/shareType/wechat_friend",newShare];
        
        NSLog(@"%@",ss);
        
    }else if (bt.tag == 1111) {
        NSLog(@"微信好友分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/wechat_friend",newShare]]];
        NSString * ss = [NSString stringWithFormat:@"ucbrowser://%@/sharetype/wechat_moments",newShare];
        
        NSLog(@"%@",ss);
        
    }
//        else if (bt.tag == 1112) {
//        NSLog(@"新浪分享");
////        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=sinaweibo"]];
//        
//    }
        else if (bt.tag == 1112) {
        NSLog(@"QQ分享");
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_mobile",newShare]]];
            NSString * ss = [NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_mobile",newShare];
            
            NSLog(@"%@",ss);
    }else if (bt.tag == 1113) {
        
        NSLog(@"QQ空间分享");
        
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_zone",newShare]]];
        NSString * ss = [NSString stringWithFormat:@"ucbrowser://%@/sharetype/qq_mobile",newShare];
        
        NSLog(@"%@",ss);
        
    }else if (bt.tag == 1114) {
        NSLog(@"复制分享链接");
        //       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ucbrowser://view.415003.com/ArticleContent/DynamicShare?uid=2797782&sharebrowser=1&aid=353788&shareType=weixin"]];
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = newShare;
        NSLog(@"%@",newShare);
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


#pragma mark- 取消分享
- (void)shareExitButtonAction{
    NSLog(@"取消分享");
    
    [UIView animateWithDuration:0.8 animations:^{
       
        
        self.ucShare.alpha = 0;
        

    }];
    
    
}

//提示框消失
- (void)removeAlerateFromSuperView:(UIAlertController *)alertControll{
    
    [alertControll dismissViewControllerAnimated:YES completion:nil];
    
}






//举报
-(void)jubaoClicked:(UIButton *)btn
{
    [_htPlayer.player pause];
    [_htPlayer removeFromSuperview];
    [self releaseWMPlayer];

    
    VideoModel *model=self.DataSource[btn.tag];
    jubaoVC *JBVC=[[jubaoVC alloc]initWithNibName:@"jubaoVC" bundle:nil];
    
    JBVC.video_id= model.video_id;
    JBVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:JBVC animated:YES];
}


-(void)LoveClicked:(UIButton *)btn
{
    [_htPlayer.player pause];
    [_htPlayer removeFromSuperview];
    [self releaseWMPlayer];

    //有网络
    if (ISNetWorking!=0) {
        
        if (Login==1) {
            VideoModel *model=self.DataSource[btn.tag];
            AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
            
            [manager POST:KURL_Zan parameters:@{@"id":model.video_id} success:^(NSURLSessionDataTask *task, id responseObject) {
                
                ZGPromptView  *prompView =[ZGPromptView new] ;
                [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:64];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
            }];
        }else{
            LoginViewController *login=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            login.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:login animated:YES];
        }
   
    }else{
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"请检查网络状态"];
    }
}
@end
