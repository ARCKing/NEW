//
//  newsViewController.m
//  
//
//  Created by siyue on 16/5/20.
//
//
#import "newsViewController.h"

//刷新
#import "MJRefreshGifHeader.h"
#import "MJRefresh.h"
#import "MJRefreshAutoFooter.h"

#import "HistoryManager.h"
#import "DetailsViewController.h"


#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "NewsCell.h"
#import "News2Cell.h"
#import "NewsModel.h"
#import "DataMansger.h"
#import "ZGPromptView.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

//页码
static int page=1;

//数据库存取的id号
static int number=0;

@interface newsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat poingY;
    BOOL _isb;
}
@property (weak, nonatomic) IBOutlet UITableView *MyTableview;
@property (nonatomic ,strong )NSMutableArray *DataSource;
@property (nonatomic ,strong )NSMutableArray *HistoryArr;
@property (nonatomic ,strong)NSMutableArray *TitleArr;
//字体的大小
@property (nonatomic ,assign)NSInteger FontSize;
@property (nonatomic ,strong)NSArray *array;
//下拉刷新控件
@property (nonatomic ,strong)MJRefreshGifHeader *header;
@property (nonatomic ,strong)UIViewController   *lastVC;

@end

@implementation newsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self CReateCell];
    self.array=@[@"NetworkDat",@"NetworkDat1",@"NetworkData2",@"NetworkData3",@"NetworkData4",@"NetworkData5",@"NetworkData6",@"NetworkDat7",@"NetworkDat8",@"NetworkDat9",@"NetworkDat10",@"NetworkDat11",@"NetworkDat12",@"NetworkDat13",@"NetworkDat14",@"NetworkDat15",@"NetworkDat16",@"NetworkDat17"];
    
    //数据缓存的逻辑.首先读取数据库内容,刷新到表格之上.再根据网络状况来向服务器发起请求.服务器数据返回,将本地数据库清空,再插入一次.
    
    if (_FoundVCnumber!=18) {
        [self getDataFromDataBase];
    }else{
        self.MyTableview.hidden=YES;
    }
    [self performSelector:@selector(Createheader) withObject:self afterDelay:0.1];
    [self createFoot];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(push:) name:@"deviceToken" object:nil];
}

-(void)push:(NSNotification *)noti
{
    DetailsViewController *detail=[[DetailsViewController alloc]init];
    detail.DetailID=noti.userInfo[@"keyid"];
    detail.Title=noti.userInfo[@"title"];
   
    detail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)Createheader
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(observeNetStatus)];
    self.header.mj_h=60;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (int i = 0; i<=49; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"gif_earth_%d", i]];
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
//视图即将加载
-(void)viewWillAppear:(BOOL)animated
{
    self.FontSize =[[[NSUserDefaults standardUserDefaults]objectForKey:@"FontSize"]integerValue];
    if (self.FontSize==0) {
        self.FontSize=17;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(IDPage:) name:@"IDPage" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tabbarClicked) name:@"DidSelectNotification" object:nil];
}
-(void)tabbarClicked
{
    if (self.tabBarController.selectedViewController==self.lastVC) {
        
        [self.MyTableview setContentOffset:CGPointMake(0, 0) animated:NO];
        [self Createheader];
    }
    self.lastVC=self.tabBarController.selectedViewController;
}

-(void)IDPage:(NSNotification *)noti
{
    number = [noti.userInfo[@"index"] intValue];
}
-(void)CReateCell
{
    [self.MyTableview registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:@"NewsCell"];
    [self.MyTableview registerNib:[UINib nibWithNibName:@"News2Cell" bundle:nil] forCellReuseIdentifier:@"News2Cell"];
    //    自动计算Cell
    self.MyTableview.estimatedRowHeight=151;
    self.MyTableview.rowHeight=UITableViewAutomaticDimension;
}

-(void)viewDidDisappear:(BOOL)animated
{
    //移除所有的通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
            [prompView addToWithController:self withString:@"请检查网络状态"];
           [self.MyTableview.mj_header endRefreshing];
        }else
        {
            //其他三种情况,都从网络上获取数据
            [self getDataFromNet];
        }
    }];
}
- (void)getDataFromDataBase
{
    //读取,查询
    DataMansger *manager = [DataMansger shareManager];
    NSString *SQLStr=[NSString stringWithFormat:@"select * from %@",self.array[number]];
    FMResultSet *rs = [manager.NetWorkDataBase executeQuery:SQLStr];
    //遍历查询的结果,用模型装起来
    while ([rs next])
    {
        NewsModel *model = [[NewsModel alloc]init];
        model.title = [rs stringForColumn:@"title"];
        model.addtime=[rs stringForColumn:@"addtime"];
        model.view_count=[rs stringForColumn:@"view_count"];
        model.thumb=[rs stringForColumn:@"thumb"];
        
        //在数据库中存数组
        NSData *data=[rs dataForColumn:@"img"];
        model.img=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        model.NewsID=[rs stringForColumn:@"NewsID"];
        model.is_hot=[rs stringForColumn:@"is_hot"];
        model.is_rec=[rs stringForColumn:@"is_rec"];
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

//只要Scrollview滑动就触发
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"keyboard" object:nil];
    if (poingY>=scrollView.contentOffset.y) {
        _isb=NO;
    }else{
        _isb=YES;
    }
}
#pragma mark--MJRefreshBaseViewDelegate
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

#pragma mark--helper Methods
//获取数据
-(void)getDataFromNet
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager GET:self.urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        
        NSLog(@"%@",self.urlString);
        
        [self.DataSource removeAllObjects];
        DataMansger *manager=[DataMansger shareManager];
        NSString *str=[NSString stringWithFormat:@"delete from %@",self.array[number]];
        //数据库清空
        if (![manager.NetWorkDataBase executeUpdate:str]) {
            NSLog(@"删除失败");
        }
        for (NSDictionary *dict in responseObject[@"data"]) {
            NewsModel *model=[[NewsModel alloc]init];
            
            if (![dict[@"title"] isKindOfClass:[NSNull class]]) {
                model.title=dict[@"title"];
            }
            if (![dict[@"addtime"] isKindOfClass:[NSNull class]]) {
                model.addtime=dict[@"addtime"];
            }
            if (![dict[@"view_count"] isKindOfClass:[NSNull class]]) {
                model.view_count=dict[@"view_count"];
            }
            if (![dict[@"thumb"] isKindOfClass:[NSNull class]]) {
                model.thumb=dict[@"thumb"];
            }
            if (![dict[@"img"] isKindOfClass:[NSNull class]]) {
                model.img=dict[@"img"];
            }
            if (![dict[@"id"] isKindOfClass:[NSNull class]]) {
                model.NewsID=dict[@"id"];
            }
            if (![dict[@"is_hot"] isKindOfClass:[NSNull class]]) {
                model.is_hot=dict[@"is_hot"];
            }
            if (![dict[@"is_rec"] isKindOfClass:[NSNull class]]) {
                model.is_rec=dict[@"is_rec"];
            }
            [self.DataSource addObject:model];
            NSData *dataImageUrls = [NSKeyedArchiver archivedDataWithRootObject:model.img];
            NSString *SQLStr=[NSString stringWithFormat:@"insert into %@ (title,addtime,img,view_count,thumb,NewsID,is_hot,is_rec) values(?,?,?,?,?,?,?,?)",self.array[number]];
            //插入数据
            if(! [manager.NetWorkDataBase executeUpdate:SQLStr,dict[@"title"]
                  ,dict[@"addtime"],dataImageUrls,dict[@"view_count"],dict[@"thumb"],dict[@"id"],dict[@"is_hot"],dict[@"is_rec"] ])
            {
                NSLog(@"数据插入失败");
            }
        }
        if (self.DataSource.count!=0) {
            self.MyTableview.hidden=NO;
        }else{
            if (_FoundVCnumber!=18) {
                [self createImage];
            }else{
                ZGPromptView  *prompView =[ZGPromptView new] ;
                [prompView addToWithController:self withString:@"无相关内容"];
            }
        }
        // 刷新表格
        [self.MyTableview reloadData];
        [self.MyTableview.mj_header endRefreshing];
        if (_FoundVCnumber!=18&&_FoundVCnumber!=19) {
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        [self.MyTableview.mj_header endRefreshing];
    }];
}
-(void)createImage
{
    UIImageView *iMGview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-30, kScreenHeight/2-50, 60, 50)];
    iMGview.image=[[UIImage imageNamed:@"ic_no_data"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.view addSubview:iMGview];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-50, kScreenHeight/2+10, 100, 30)];
    label.font=[UIFont systemFontOfSize:14];
    label.textColor=[UIColor grayColor];
    label.text=@"暂无记录";
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
}

//加载更多
-(void)Updata
{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSString *url=[NSString stringWithFormat:@"%@&p=%d",self.urlString,page];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *dataArr=responseObject[@"data"];
        
        NSLog(@"%@",dataArr);
        
        if (dataArr.count==0) {
            [self.MyTableview.mj_footer endRefreshingWithNoMoreData];
            return ;
        }
        
        for (NSDictionary *dict in responseObject[@"data"]) {
            NewsModel *model=[[NewsModel alloc]init];

            if (![dict[@"title"] isKindOfClass:[NSNull class]]) {
                model.title=dict[@"title"];
            }
            if (![dict[@"addtime"] isKindOfClass:[NSNull class]]) {
                model.addtime=dict[@"addtime"];
            }
            if (![dict[@"view_count"] isKindOfClass:[NSNull class]]) {
                model.view_count=dict[@"view_count"];
            }
            if (![dict[@"thumb"] isKindOfClass:[NSNull class]]) {
                model.thumb=dict[@"thumb"];
            }
            if (![dict[@"img"] isKindOfClass:[NSNull class]]) {
                model.img=dict[@"img"];
            }
            if (![dict[@"id"] isKindOfClass:[NSNull class]]) {
                model.NewsID=dict[@"id"];
            }
            if (![dict[@"is_hot"] isKindOfClass:[NSNull class]]) {
                model.is_hot=dict[@"is_hot"];
            }
            if (![dict[@"is_rec"] isKindOfClass:[NSNull class]]) {
                model.is_rec=dict[@"is_rec"];
            }
           [self.DataSource addObject:model];
        }
        
        //判断没有更多的情况
        
        
        [self.MyTableview reloadData];
        _isb=NO;
        [self.MyTableview.mj_footer endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.MyTableview.mj_footer endRefreshing];
    }];
}
#pragma mark--UITableViewDataSource,UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *resultCell=nil;
    NewsModel *model=self.DataSource[indexPath.row];

    if (model.img.count==0) {
       News2Cell  *Cell=[tableView dequeueReusableCellWithIdentifier:@"News2Cell" forIndexPath:indexPath];
        Cell.HotLabel.hidden=YES;
        Cell.WidthLAyout.constant=0;
        
        if ([model.is_hot intValue]==1) {
            Cell.HotLabel.hidden=NO;
            Cell.HotLabel.text=@"热门";
            Cell.WidthLAyout.constant=35;
        }if([model.is_rec intValue]==1){
            Cell.HotLabel.hidden=NO;
            Cell.HotLabel.text=@"推荐";
            Cell.WidthLAyout.constant=35;
        }
        Cell.TitleLabel.text=model.title;
        Cell.TitleLabel.font=[UIFont systemFontOfSize:self.FontSize];
        Cell.Timelabel.text=model.addtime;
        Cell.NumberLabel.text=@"阅读10000+";
        Cell.NumberLabel.text=[NSString stringWithFormat:@"阅读%@",model.view_count];
        if ([model.view_count intValue]>=10000) {
           Cell.NumberLabel.text=@"阅读10000+";
        }
        if (_isb==NO) {
            [Cell.Imgview sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"img_default_big"]];
        }else{
                [Cell.Imgview sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"img_default_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    Cell.Imgview.alpha = 0.0;
                    [UIView transitionWithView:Cell.Imgview
                                      duration:0.7
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [Cell.Imgview setImage:image];
                                        Cell.Imgview.alpha = 1.0;
                                    } completion:NULL];
                }];
                
        }
        resultCell=Cell;
    }
    
    else{
    
    NewsCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"NewsCell" forIndexPath:indexPath];
    Cell.HotLabel.hidden=YES;
        Cell.WidthLayoput.constant=8;
    if ([model.is_hot intValue]==1) {
        Cell.HotLabel.hidden=NO;
        Cell.WidthLayoput.constant=40;
    }if([model.is_rec intValue]==1){
        Cell.HotLabel.hidden=NO;
        Cell.HotLabel.text=@"推荐";
         Cell.WidthLayoput.constant=40;
    }
    Cell.TitleLabel.text=model.title;
    Cell.TitleLabel.font=[UIFont systemFontOfSize:self.FontSize];
    Cell.TimeLabel.text=model.addtime;
    Cell.NumberLabel.text=[NSString stringWithFormat:@"阅读%@",model.view_count];
    if ([model.view_count intValue]>=10000) {
            Cell.NumberLabel.text=@"阅读10000+";
    }
        
   
        
        if (_isb==NO) {
            [Cell.FirstImgView sd_setImageWithURL:[NSURL URLWithString:[model.img firstObject]] placeholderImage:[UIImage imageNamed:@"img_default_big"]];
            [Cell.SecondImgview sd_setImageWithURL:[NSURL URLWithString:model.img[1]] placeholderImage:[UIImage imageNamed:@"img_default_big"]];
            [Cell.ThirdImgView sd_setImageWithURL:[NSURL URLWithString:[model.img lastObject]] placeholderImage:[UIImage imageNamed:@"img_default_big"]];
        }else{
                [Cell.FirstImgView sd_setImageWithURL:[NSURL URLWithString:[model.img firstObject]] placeholderImage:[UIImage imageNamed:@"img_default_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    Cell.FirstImgView.alpha = 0.0;
                    [UIView transitionWithView:Cell.FirstImgView
                                      duration:0.7
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [Cell.FirstImgView setImage:image];
                                        Cell.FirstImgView.alpha = 1.0;
                                    } completion:NULL];
                }];
                
                
                [Cell.SecondImgview sd_setImageWithURL:[NSURL URLWithString:model.img[1]] placeholderImage:[UIImage imageNamed:@"img_default_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    Cell.SecondImgview.alpha = 0.0;
                    [UIView transitionWithView:Cell.SecondImgview
                                      duration:0.7
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [Cell.SecondImgview setImage:image];
                                        Cell.SecondImgview.alpha = 1.0;
                                    } completion:NULL];
                    
                }];
                
                
                
                [Cell.ThirdImgView sd_setImageWithURL:[NSURL URLWithString:[model.img lastObject]] placeholderImage:[UIImage imageNamed:@"img_default_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    Cell.ThirdImgView.alpha = 0.0;
                    [UIView transitionWithView:Cell.ThirdImgView
                                      duration:0.7
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [Cell.ThirdImgView setImage:image];
                                        Cell.ThirdImgView.alpha = 1.0;
                                    } completion:NULL];        }];
        }
    resultCell=Cell;
    }
    return resultCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel *model=self.DataSource[indexPath.row];
    
    DetailsViewController *detail=[[DetailsViewController alloc]init];
    detail.DetailID=model.NewsID;
    detail.Title=model.title;
    //将阅读加载到历史记录
    [self readingHistory:model.NewsID AndTitle:model.title];
    detail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:detail animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mrak--Sqlite

// 浏览历史记录
-(void)readingHistory:(NSString *)DetailID AndTitle:(NSString *)title
{
    //清空数组
    [self.HistoryArr removeAllObjects];
    HistoryManager *manager=[HistoryManager shareManager];
    
    // FMResultSet结果集，用来表示查询到的数据
    FMResultSet *rs = [manager.HistoryDataBase executeQuery:@"select * from history"];
    
    // 遍历结果集，next让结果集的指针指向下一条记录(下一行数据)，如果有数据，就返回YES，没有数据，就返回NO
    while ([rs next]) {
        // stringForColumn 取到当前指针指向的记录中，对应的字段的值，把取出来的值转成String
        NSString *sidStr = [rs stringForColumn:@"HistoryID"];
        
        [self.HistoryArr addObject:sidStr];
    }
    for (NSString *historyID in self.HistoryArr) {
        if ([historyID isEqualToString:DetailID]) {
            return;
        }
    }
    //插入数据
    if(! [manager.HistoryDataBase executeUpdate:@"insert into history (HistoryID,title) values(?,?)",DetailID
          ,title])
    {
        NSLog(@"数据插入失败");
    }
}

#pragma mark--Setter &Getter

-(NSMutableArray *)DataSource
{
    if (_DataSource==nil) {
        _DataSource=[[NSMutableArray alloc]init];
    }
    return _DataSource;
}
-(NSMutableArray *)HistoryArr
{
    if (_HistoryArr==nil) {
        _HistoryArr=[[NSMutableArray alloc]init];
        
    }
    return _HistoryArr;
}

-(NSMutableArray *)TitleArr
{
    if (_TitleArr==nil) {
        _TitleArr=[[NSMutableArray alloc]init];
        
    }
    return _TitleArr;
}
@end
