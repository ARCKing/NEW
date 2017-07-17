//
//  MoneyViewController.m
//  News
//
//  Created by ZZG on 16/5/31.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "MoneyViewController.h"
#import "WithDrawalVC.h"
#import "weixinView.h"
#import "AlipayView.h"
#import "ZGNetAPI.h"
#import "AFNetworking.h"
#import "ZGManagerHUD.h"
#import "settingCell.h"
#import "InvitationViewController.h"
#import "IncomeViewController.h"
#import "RecordViewController.h"
#import "ZGPromptView.h"
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

static int i=1;
static float HearViewOriginHight =280;

@interface MoneyViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *MytableView;

@property (nonatomic ,strong)NSArray *IMGArr;
@property (nonatomic ,strong)NSArray *TitleArr;
@property (nonatomic ,strong)weixinView *weixin;
@property (nonatomic ,strong)UIView *Myview;
@property (nonatomic ,strong)AlipayView *alipay;
@property (nonatomic ,strong)UIView *redView;
@property (nonatomic ,strong)UIView *whiteView;


@property (nonatomic ,strong)UIButton *duihuanBtn;
@property (nonatomic ,strong)UIButton *jiluBtn;
@property (nonatomic ,strong)UILabel *TitleLabel;
@property (nonatomic ,strong)UILabel *number1Label;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIButton *fanhuiBtn;
@property (nonatomic ,strong)UILabel *label;
//存取历史收入的
@property (nonatomic ,copy)NSString  *sum_money;
@end

@implementation MoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
    self.TitleArr=@[@"历史记录",@"收支明细",@"我的邀请",@"支付宝绑定",@"微信绑定"];
    self.IMGArr=@[@"ic_usr_page_item_integral_history",@"bonus_earn_detail_ic",@"bonus_myf",@"ic_alipay",@"ic_wxpay"];
    [self.MytableView registerNib:[UINib nibWithNibName:@"settingCell" bundle:nil] forCellReuseIdentifier:@"settingCell"];
    
    self.MytableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    //去除多余的Cell
    self.MytableView.tableFooterView=[UIView new];
    //创建一个通知
    [self postNotification];
    // 注册键盘回收 与 弹起的通知
    [self addNotification];
    [ZGManagerHUD showHUDViewController:self.tabBarController];
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    //延迟执行
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
    [self UpmoneyData];
    });
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.MytableView setContentOffset:CGPointMake(0, -HearViewOriginHight) animated:NO];
}

#pragma mark -- 滚动视图的代理方法
- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
    //     self.navigationController.navigationBar.alpha=0;
    /**
     *  关键处理：通过滚动视图获取到滚动偏移量从而去改变图片的变化
     */
    //获取滚动视图y值的偏移量
    CGFloat yOffset  = scrollView.contentOffset.y;
    CGFloat xOffset = (yOffset +HearViewOriginHight)/2;
    if(yOffset < -HearViewOriginHight) {
        
        CGRect f =self.redView.frame;
        f.origin.x= 0;
        f.origin.y= yOffset ;
        f.size.height=  -yOffset;
        f.size.width=kScreenHeight + fabs(xOffset)*2;
        
        self.number1Label.frame=CGRectMake(0, 60-xOffset, kScreenWidth, 30);
        self.TitleLabel.frame=CGRectMake(0, 100-xOffset, kScreenWidth, 24);
        self.duihuanBtn.frame=CGRectMake(0, -yOffset-127, kScreenWidth/2-1, 47);
        self.jiluBtn.frame=CGRectMake(kScreenWidth/2, -yOffset-127, kScreenWidth/2-1, 47);
        self.whiteView.frame= CGRectMake(0, -yOffset-80, kScreenWidth, 80);
        self.redView.frame= f;
        
    }else{
        self.imageView.frame=CGRectMake(8, 24, 24,24);
        self.fanhuiBtn.frame=CGRectMake(0, 24, 60, 40);
        self.label.frame=CGRectMake(0, 24, kScreenWidth, 24);
    }
}

-(void)createUI
{
    self.MytableView.contentInset=UIEdgeInsetsMake(HearViewOriginHight, 0, 0, 0);
    self.redView=[[UIView alloc]initWithFrame:CGRectMake(0, -HearViewOriginHight, kScreenWidth, HearViewOriginHight)];
    self.redView.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    [self.MytableView addSubview:self.redView];
    
    self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 24, 24,24)];
    self.imageView.image=[UIImage imageNamed:@"setting_back"];
    [self.view addSubview:self.imageView];
    
    self.fanhuiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.fanhuiBtn.frame=CGRectMake(0, 24, 60, 40);
    self.fanhuiBtn.tag=10;
    [self.fanhuiBtn addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fanhuiBtn];
    
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(0, 24, kScreenWidth, 24)];
    self.label.text=@"钱包";
    self.label.textColor=[UIColor whiteColor];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.label];

    self.duihuanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.duihuanBtn.frame=CGRectMake(0, self.redView.frame.size.height-127, kScreenWidth/2-1, 47);
    self.duihuanBtn.backgroundColor=[UIColor colorWithRed:197/255.0f green:66/255.0f blue:73/255.0f alpha:1];
    [self.duihuanBtn setTitle:@"立即兑换" forState:UIControlStateNormal];
    self.duihuanBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [self.duihuanBtn addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.duihuanBtn.tag=11;
    [self.redView addSubview:self.duihuanBtn];
    self.jiluBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.jiluBtn.frame=CGRectMake(kScreenWidth/2, self.redView.frame.size.height-127, kScreenWidth/2-1, 47);
    self.jiluBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    self.jiluBtn.backgroundColor=[UIColor colorWithRed:197/255.0f green:66/255.0f blue:73/255.0f alpha:1];
    [self.jiluBtn setTitle:@"兑换记录" forState:UIControlStateNormal];
    [self.jiluBtn addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.jiluBtn.tag=12;
    [self.redView addSubview:self.jiluBtn];
    
    self.whiteView=[[UIView alloc]initWithFrame:CGRectMake(0, self.redView.frame.size.height-80  , kScreenWidth, 80)];
    self.whiteView.backgroundColor=[UIColor whiteColor];
    [self.redView addSubview:self.whiteView];
    
    UIView *grayView=[[UIView alloc]initWithFrame:CGRectMake(0, self.whiteView.frame.size.height-15    , kScreenWidth, 15)];
    grayView.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    [self.whiteView addSubview:grayView];
}
//获取钱包数据
-(void)UpmoneyData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager GET:self.url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [ZGManagerHUD hidesHUDComplection:nil];

        NSDictionary *dict=responseObject[@"data"];
        
        NSLog(@"%@",responseObject);
        
        //获取到数据就创建相应的Label
        self.number1Label=[[UILabel alloc]initWithFrame:CGRectMake(0, 60, kScreenWidth, 30)];
        self.number1Label.font =[UIFont systemFontOfSize:23];
        self.number1Label.textColor=[UIColor whiteColor];
        [self.number1Label setTextAlignment:NSTextAlignmentCenter];
        self.number1Label.text=dict[@"huolizhi"];
        [self.redView addSubview:self.number1Label];
        
        self.TitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 100, kScreenWidth, 24)];
        self.TitleLabel.textColor=[UIColor whiteColor];
        self.TitleLabel.text=@"当前可兑换积分";
        self.TitleLabel.text=dict[@"str_1"];
        [self.TitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.redView addSubview:self.TitleLabel];
        
        
        NSArray *arr=@[dict[@"str_2"],dict[@"str_4"],dict[@"str_5"],dict[@"str_3"],dict[@"jr_huolizhi"],dict[@"jrst"],dict[@"tdzs"],dict[@"residue_money"]];
        
        for (int i=0; i<arr.count; i++) {
            UILabel *Title2Label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/4*(i%4), 5+30*(i/4), kScreenWidth/4, 24)];
            Title2Label.text=arr[i];
            
            [Title2Label setTextAlignment:NSTextAlignmentCenter];
            Title2Label.font=[UIFont systemFontOfSize:14];
            if (i>3) {
                 Title2Label.textColor=[UIColor colorWithRed:242/255.0f green:72/255.0f blue:80/255.0f alpha:1];
            }else{
                Title2Label.textColor=[UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1];
            }
            
            [self.whiteView addSubview:Title2Label];
        }
        self.sum_money=dict[@"sum_money"];
        [self.MytableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ZGManagerHUD hidesHUDComplection:nil];
    }];
}

#pragma mark--UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.IMGArr.count;
}
//Cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    settingCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    Cell.ImgView.image=[UIImage imageNamed:self.IMGArr[indexPath.row]];
    if (indexPath.row==0) {
        
        Cell.warningLabel.text=self.sum_money;
        if (Cell.warningLabel.text.length!=0) {
           Cell.warningLabel.hidden=NO;
        }
    }
    Cell.NameLabel.text=self.TitleArr[indexPath.row];
    
    //cell右侧小箭头
    Cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return Cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        IncomeViewController *income=[[IncomeViewController alloc]initWithNibName:@"IncomeViewController" bundle:nil];
        
        income.hidesBottomBarWhenPushed=YES;
        
        [self.navigationController pushViewController:income animated:YES];
    }
    if (indexPath.row==2) {
        InvitationViewController *invitation=[[InvitationViewController alloc]initWithNibName:@"InvitationViewController" bundle:nil];

        [self.navigationController pushViewController:invitation animated:YES];
    }
    if (indexPath.row==3) {
        //支付宝绑定
        [self showMYview];
        [self createAlipayView];
        //获取绑定信息
        [self Upbindingdata];
        [UIView transitionWithView:self.alipay duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.alipay.frame=CGRectMake(0,kScreenHeight - 220, kScreenWidth, 220);
        } completion:NULL];
    }
    if (indexPath.row==4) {
        //微信绑定
        [self showMYview];
        
        [self createweixinView];
        //获取绑定信息
        [self Upbindingdata];
        
        [UIView transitionWithView:self.weixin duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.weixin.frame=CGRectMake(0,kScreenHeight - 350, kScreenWidth, 350);
        } completion:NULL];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//慢慢显示背景
-(void)showMYview
{
    [self createView];
    [UIView transitionWithView:self.Myview duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.Myview.alpha=0.7;
    } completion:NULL];
}


//获取用户绑定数据
-(void)Upbindingdata
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    [manager POST:KURL_binding parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
        self.alipay.NameTF.text=responseObject[@"data"][@"ali_name"];
        self.alipay.nikeNameTF.text=responseObject[@"data"][@"ali_nick"];
        self.weixin.TitleLabel.text=[NSString stringWithFormat:@" %@",responseObject[@"data"][@"url"]];
        self.weixin.URLTF.text=responseObject[@"data"][@"openid"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}
#pragma mark--绑定微信
//提交绑定微信数据
-(void)UpdataWeixin
{
    ZGPromptView  *prompView =[ZGPromptView new] ;
    
    if (self.weixin.URLTF.text.length==0) {
        [prompView addToWithController:self withLabel:@"请输入获取到的OPENID" AndHeight:0];

    }else{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"openid":self.weixin.URLTF.text};
    [manager POST:KURL_weixin parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
        [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
        
        [self DeclineinView];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
    }
    [self.weixin.URLTF resignFirstResponder];
}
//创建一个weixinView
-(void)createweixinView
{
    self.weixin=[[NSBundle mainBundle]loadNibNamed:@"weixinView" owner:nil options:0][0];
    self.weixin.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 340);
    [self.weixin.CopyBtn addTarget:self action:@selector(weixinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.weixin.OPweixinBtn addTarget:self action:@selector(weixinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.weixin.UpdataBtn addTarget:self action:@selector(weixinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.weixin];
}

//点击weixinView三个Btn触发的方法
-(void)weixinBtnClicked:(UIButton *)btn
{
    NSString *str=@"weixin://";
    if (btn.tag==10) {
        //复制链接
        //复制  三句代码
        UIPasteboard *pab = [UIPasteboard generalPasteboard];
        NSString *string = self.weixin.TitleLabel.text;
        [pab setString:string];

        ZGPromptView  *prompView =[ZGPromptView new] ;
         [prompView addToWithController:self withLabel:@"复制成功" AndHeight:0];
    }else if (btn.tag==11){
        //打开微信
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
    }else if (btn.tag==12){
        //提交
        [self UpdataWeixin];
    }
}

#pragma makr--绑定支付宝

//弹出绑定支付宝账号
-(void)createAlipayView
{
    self.alipay=[[NSBundle mainBundle]loadNibNamed:@"AlipayView" owner:nil options:0][0];
    self.alipay.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 190);
    [self.alipay.UPBtn addTarget:self action:@selector(UpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.alipay];
}

//绑定支付宝账号提交
-(void)UpBtnClicked:(UIButton *)btn
{
    ZGPromptView  *prompView =[ZGPromptView new] ;
    if (self.alipay.NameTF.text.length==0) {
        [prompView addToWithController:self withLabel:@"请输入支付宝账号" AndHeight:0];
        
    }else{
        if (self.alipay.nikeNameTF.text.length==0) {
            [prompView addToWithController:self withLabel:@"请输入支付宝认证昵称" AndHeight:0];
            
        }else{
            AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
            NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"ali_name":self.alipay.NameTF.text,@"ali_nick":self.alipay.nikeNameTF.text};
            [manager POST:KURL_Alipay parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
                 [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
                [self DeclineinView];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
            }];
        }
    }
    [self.alipay.NameTF resignFirstResponder];
    [self.alipay.nikeNameTF resignFirstResponder];
   
}
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
            CGRect frame = self.alipay.frame;
            // y值减小  视图上升
            frame.origin.y -= height;
            self.alipay.frame = frame;
        }];
        
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.weixin.frame;
            // y值减小  视图上升
            frame.origin.y -= height;
            self.weixin.frame = frame;
        }];
    }
}

// 回收键盘
- (void)hiddenKeyBoard:(NSNotification *)noti
{
    i=1;
    // 获取键盘弹起时间
    float duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey]  floatValue];
    // 获得键盘的高度
    NSValue * value = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
    float height = value.CGRectValue.size.height;
    
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.alipay.frame;
        // y值增加  视图下降
        frame.origin.y += height;
        self.alipay.frame = frame;
    }];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.weixin.frame;
        // y值减小  视图上升
        frame.origin.y += height;
        self.weixin.frame = frame;
    }];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"123" object:nil];
}

//创建一个背景阴影
-(void)createView
{
    self.Myview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.Myview.backgroundColor=[UIColor blackColor];
    self.Myview.alpha=0;
    [self.view addSubview:self.Myview];
}

-(void)endhiddin
{
    self.Myview.hidden=YES;
    self.alipay.hidden=YES;
    self.weixin.hidden=YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.weixin.URLTF resignFirstResponder];
    [self.alipay.NameTF resignFirstResponder];
    [self.alipay.nikeNameTF resignFirstResponder];
    return YES;
}


-(void)BtnClicked:(UIButton *)sender
{
    if(sender.tag==10){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (sender.tag==11){
        //立即兑换
        
        WithDrawalVC *WDVC=[[WithDrawalVC alloc]initWithNibName:@"WithDrawalVC" bundle:nil];
        [self.navigationController pushViewController:WDVC animated:YES];
    }else if (sender.tag==12){
        //兑换记录
        RecordViewController *Record=[[RecordViewController alloc]initWithNibName:@"RecordViewController" bundle:nil];
        
        [self.navigationController pushViewController:Record animated:YES];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //慢慢下滑支付宝与微信View
    [self DeclineinView];
}
-(void)DeclineinView
{
    [self hiddenView];
    [UIView animateWithDuration:0.2 animations:^{
        self.alipay.frame=CGRectMake(0,kScreenHeight, kScreenWidth, 190);
        self.weixin.frame=CGRectMake(0,kScreenHeight, kScreenWidth, 340);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            [UIView transitionWithView:self.Myview duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.Myview.alpha=0.0;
                self.Myview.hidden=YES;
            } completion:NULL];
        }];
    }];
}

-(void)hiddenView
{
    [self.weixin.URLTF resignFirstResponder];
    [self.alipay.NameTF resignFirstResponder];
    [self.alipay.nikeNameTF resignFirstResponder];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
