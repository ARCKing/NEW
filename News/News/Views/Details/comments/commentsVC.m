//
//  commentsVC.m
//  News
//
//  Created by ZZG on 16/7/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "commentsVC.h"
#import "commentsCell.h"
#import "CommentModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "ZGNetAPI.h"
#import "ZGManagerHUD.h"
#import "ChatView.h"

#import "ZGPromptView.h"
#import "MJRefresh.h"
#import "MJRefreshGifHeader.h"
#import "MJRefreshAutoFooter.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

static int page=1;
static int i=1;


@interface commentsVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *MyTableView;
@property (nonatomic ,strong)NSMutableArray *DataSource;
@property (nonatomic ,strong)MJRefreshGifHeader *header;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (nonatomic ,strong)ChatView *chatView;

@property (nonatomic ,strong)UIView *MyView;
@property (weak, nonatomic) IBOutlet UITextField *commentTF;
@property (nonatomic ,copy)NSString *UserID;
@end

@implementation commentsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化Cell
    [self CreateCell];
    
    //从网络上获取数据
    [self getDataFromNet];
    //下拉刷新
    [self Createheader];
    
    [ZGManagerHUD showHUDwithMessage:@"正在加载" inViewController:self.tabBarController];
    
    self.MyTableView.hidden=YES;
//    //下拉加载更多
//    [self createFoot];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.customView.layer.borderWidth=0.5;
    self.customView.layer.borderColor=[UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1].CGColor;
    self.customView.layer.masksToBounds=YES;
    
    self.UserID=@"0";
    //创建一个通知
    [self postNotification];
    // 注册键盘回收 与 弹起的通知
    [self addNotification];
}

#pragma mark--helper Methods
-(void)Createheader
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getDataFromNet)];
    self.header.mj_h=60;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (int j= 0; j<=49; j++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"gif_earth_%d", j]];
        [idleImages addObject:image];
    }
    [self.header setImages:idleImages forState:MJRefreshStateIdle];
    [self.header setImages:idleImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [self.header setImages:idleImages forState:MJRefreshStateRefreshing];
    // 马上进入刷新状态
    [self.header beginRefreshing];
    // 设置header
    self.MyTableView.mj_header = self.header;
}
-(void)createFoot
{
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.MyTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //页码++ ,再次请求数据
        page ++;
        [self getDataFromNet];
    }];
}

-(void)CreateCell
{
    [self.MyTableView registerNib:[UINib nibWithNibName:@"commentsCell" bundle:nil] forCellReuseIdentifier:@"commentsCell"];
    
    self.MyTableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    
    //    自动计算Cell
    self.MyTableView.estimatedRowHeight=103;
    self.MyTableView.rowHeight=UITableViewAutomaticDimension;
}

-(void)getDataFromNet
{
     AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager POST:KURL_publishedList parameters:@{@"article_id":self.DetailID,@"page":@(page)} success:^(NSURLSessionDataTask *task, id responseObject) {
        [ZGManagerHUD hidesHUDComplection:nil];
        
        NSArray *dataArr=responseObject[@"data"];
        if (dataArr.count==0) {
            [self.MyTableView.mj_footer endRefreshingWithNoMoreData];
            
        }
        //清空数据源
        if (page==1) {
            [self.DataSource removeAllObjects];
        }
    
        for (NSDictionary *dict in responseObject[@"data"]) {
             CommentModel *model=[[CommentModel alloc]init];
            model.user_name=dict[@"user_name"];
            model.user_avatar=dict[@"user_avatar"];
            model.message=dict[@"message"];
            model.created_at=dict[@"created_at"];
            model.post_id=dict[@"post_id"];
            
            [self.DataSource addObject:model];
        }
        if (self.DataSource.count!=0) {
            self.MyTableView.hidden=NO;
        }else{
            //列表为空
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.3*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                 [self createImage];
            });
           
        }
        [self.MyTableView reloadData];
        [self.MyTableView.mj_header endRefreshing];
        [self.MyTableView.mj_footer endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.MyTableView.mj_header endRefreshing];
        [self.MyTableView.mj_footer endRefreshing];
        [ZGManagerHUD hidesHUDComplection:nil];
    }];
}

-(void)createImage
{
    UIImageView *iMGview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-30, kScreenHeight/2-50, 60, 50)];
    iMGview.image=[[UIImage imageNamed:@"ic_no_data.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.view addSubview:iMGview];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-50, kScreenHeight/2+10, 100, 30)];
    label.font=[UIFont systemFontOfSize:14];
    label.textColor=[UIColor grayColor];
    label.text=@"暂无评论";
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
}
#pragma mark--<UITableViewDelegate,UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    commentsCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"commentsCell" forIndexPath:indexPath];
    
    CommentModel *model=self.DataSource[indexPath.row];
    
    [Cell.PerSonImgView sd_setImageWithURL:[NSURL URLWithString:model.user_avatar] placeholderImage:[UIImage imageNamed:@"headicon_default"]];
    Cell.NameLabel.text=model.user_name;
    Cell.TimeLabel.text=model.created_at;
    Cell.TitleLabel.text=model.message;
    
    [Cell.CommentBtn addTarget:self action:@selector(CommentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    Cell.CommentBtn.tag=indexPath.row;
    
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.MyTableView reloadData];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
     [self CreateMyviewAndChatView];
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

//点击回复
-(void)CommentBtnClicked:(UIButton *)btn
{
    [self CreateMyviewAndChatView];
    CommentModel *model=self.DataSource[btn.tag];
    
    self.UserID=model.post_id;
    
    self.chatView.placeLabel.text=[NSString stringWithFormat:@"回复：%@",model.user_name];
}
- (IBAction)BtnClicked:(UIButton *)sender {
    if (sender.tag==10) {
       [self.navigationController popViewControllerAnimated:YES];
    }else if(sender.tag==11){
    [self CreateMyviewAndChatView];
    }
}
-(void)CreateMyviewAndChatView
{
    self.MyView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    self.MyView.backgroundColor=[UIColor blackColor];
    self.MyView.alpha=0;
    [self.view addSubview:self.MyView];
    
    [UIView transitionWithView:self.MyView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.MyView.alpha=0.7;
    } completion:NULL];
    
    
   /*
    UITextView 实现placeholder的方法
    */
    //聊天框
    self.chatView=[[NSBundle mainBundle]loadNibNamed:@"ChatView" owner:self options:0][0];
    self.chatView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 200);
    
    [self.chatView.cancelBtn addTarget:self action:@selector(publishedClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.chatView.publishedBtn addTarget:self action:@selector(publishedClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.chatView.MYTextView.delegate=self;
    self.chatView.placeLabel.enabled=NO;
    [self.view addSubview:self.chatView];
    
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
    NSDictionary *dict=@{@"authcode":self.Dict[@"authcode"],@"article_id":self.Dict[@"article_id"],@"parent_id":self.UserID,@"message":self.chatView.MYTextView.text,@"title":self.Dict[@"title"],@"url":self.Dict[@"url"]};
    
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
    self.commentTF.text=@"";
    [self.commentTF resignFirstResponder];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"123" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
