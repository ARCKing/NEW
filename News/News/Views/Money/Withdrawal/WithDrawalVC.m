//
//  WithDrawalVC.m
//  News
//
//  Created by ZZG on 16/6/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "WithDrawalVC.h"
#import "ZGManagerHUD.h"
#import "ZGNetAPI.h"

#import "settingCell.h"
#import "AFNetworking.h"
#import "ZGNetAPI.h"
#import "ZGPromptView.h"

//微信View与支付宝View
#import "WithDrawalAlipay.h"
#import "WxPayView.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)


static int i=1;

static int pagenum=0;

@interface WithDrawalVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *MyTableView;
@property (nonatomic ,strong)NSArray *ImgViewArr;
@property (nonatomic ,strong)NSArray *TitleViewArr;

//判断是绑定了几个账户
@property (nonatomic ,assign)NSInteger number;

//背景阴影
@property (nonatomic ,strong)UIView *MyView;
@property (nonatomic ,strong)WithDrawalAlipay *WDAlipayView;
@property (nonatomic ,strong)WxPayView *wxPayView;
@property (nonatomic ,strong)NSDictionary *Dict;

@end

@implementation WithDrawalVC

- (void)viewDidLoad {
    [super viewDidLoad];
   

    [self.MyTableView registerNib:[UINib nibWithNibName:@"settingCell" bundle:nil] forCellReuseIdentifier:@"settingCell"];
    
    //去除多余的Cell
    self.MyTableView.tableFooterView=[UIView new];
    self.MyTableView.contentInset=UIEdgeInsetsMake(15, 0, 0, 0);
     self.MyTableView.separatorColor=[UIColor groupTableViewBackgroundColor];
     [ZGManagerHUD showHUDViewController:self.tabBarController];
    
    //加载数据  判段是否绑定账户
    [self Updata];
}

-(void)viewWillAppear:(BOOL)animated
{
    //创建一个通知
    [self postNotification];
    // 注册键盘回收 与 弹起的通知
    [self addNotification];
}
#pragma mark--UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.number;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    settingCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    
    Cell.ImgView.image=[UIImage imageNamed:self.ImgViewArr[indexPath.row]];
    Cell.NameLabel.text=self.TitleViewArr[indexPath.row];
    
    //cell右侧小箭头
    Cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self createMyView];
    
    [UIView transitionWithView:self.MyView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.MyView.alpha=0.7;
    } completion:NULL];
    
    if (pagenum==1) {
        [self createwxPayView];
        
        [UIView transitionWithView:self.wxPayView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.wxPayView.frame=CGRectMake(0,kScreenHeight - 213, kScreenWidth, 213);
        } completion:NULL];
    }else{

    if (indexPath.row==0) {
        //创建弹出的View
        [self createAlipayView];

        [UIView transitionWithView:self.WDAlipayView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.WDAlipayView.frame=CGRectMake(0,kScreenHeight - 268, kScreenWidth, 268);
        } completion:NULL];
    }else if (indexPath.row==1){
        [self createwxPayView];

        [UIView transitionWithView:self.wxPayView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.wxPayView.frame=CGRectMake(0,kScreenHeight - 213, kScreenWidth, 213);
        } completion:NULL];
    }
    
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark--helper Methods
-(void)Updata
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    
    [manager POST:KURL_WithDrawal parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.Dict=responseObject[@"data"];
        //有支付宝
        if (![self.Dict[@"ali_name"] isEqualToString:@""]) {
            self.number=1;
            self.ImgViewArr=@[@"ic_alipay",@"ic_wxpay"];
            self.TitleViewArr=@[@"提现到支付宝",@"提现到微信"];
            //有微信
            if (![self.Dict[@"wx_openid"] isEqualToString:@""]) {
                self.number=2;
            }else{
                //没有微信
                self.number=1;
            }
        }else{
            
            //没有支付宝有微信
            if (![self.Dict[@"wx_openid"] isEqualToString:@""]) {
                
                pagenum=1;
                self.number=1;
                self.ImgViewArr=@[@"ic_wxpay"];
                self.TitleViewArr=@[@"提现到微信"];
                
            }else{
                //没有支付宝 没有微信
                self.number=0;
                //停止加载
                [ZGManagerHUD hidesHUDComplection:nil];
                //弹出警告框
                ZGPromptView  *prompView =[ZGPromptView new] ;
                [prompView addToWithController:self withString:@"请先绑定提现账户" withImage:[UIImage imageNamed:@"show_no"]];
                return ;
            }
        }
        
        [self.MyTableView reloadData];
        [ZGManagerHUD hidesHUDComplection:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ZGManagerHUD hidesHUDComplection:nil];
    }];
}

#pragma mark--Setter &Getter
#pragma mark - Event Handlers
- (IBAction)ReturnBtnClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//创建一个wxPay
-(void)createwxPayView
{
    self.wxPayView=[[NSBundle mainBundle]loadNibNamed:@"WxPayView" owner:nil options:0][0];
    self.wxPayView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 180);
    [self.wxPayView.Updatabtn addTarget:self action:@selector(UpBtnWXClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.wxPayView.TitleLabel.text=[NSString stringWithFormat:@" %@",self.Dict[@"wx_desc"]];
    self.wxPayView.nameLabel.text=[NSString stringWithFormat:@"   openID: %@",self.Dict[@"wx_openid"]];
    self.wxPayView.moneyTF.placeholder=self.Dict[@"ali_ht"];
    
    [self.view addSubview:self.wxPayView];
}

//微信提现
-(void)UpBtnWXClicked:(UIButton *)btn
{
    ZGPromptView  *prompView =[ZGPromptView new] ;
    if (self.wxPayView.moneyTF.text.length==0) {
        [prompView addToWithController:self withLabel:@"请输入兑换金额" AndHeight:0];
    }else{
        [ZGManagerHUD showHUDwithMessage:@"正在提交" inViewController:self];
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"price":@([self.wxPayView.moneyTF.text intValue])};
        [manager POST:KURL_WithDrawalWxpay parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
            [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
          
            if ([responseObject[@"message"] isEqualToString:@"提交成功"]) {
                [self DeclineinView];
            }
            
             [self.MyTableView reloadData];
            [ZGManagerHUD hidesHUDComplection:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [ZGManagerHUD hidesHUDComplection:nil];
        }];
    }
    [self.wxPayView.moneyTF resignFirstResponder];
    
}

//创建一个alipay
-(void)createAlipayView
{
    self.WDAlipayView=[[NSBundle mainBundle]loadNibNamed:@"WithDrawalAlipay" owner:nil options:0][0];
    self.WDAlipayView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 230);
    
    [self.WDAlipayView.Updata addTarget:self action:@selector(UpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.WDAlipayView.TitleLabel.text=[NSString stringWithFormat:@"  %@",self.Dict[@"ali_desc"]];
    self.WDAlipayView.NameLabel.text=[NSString stringWithFormat:@"  支付宝账号: %@",self.Dict[@"ali_name"]];
    self.WDAlipayView.NickNameLabel.text=[NSString stringWithFormat:@"  支付宝名称: %@",self.Dict[@"ali_nick"]];
    self.WDAlipayView.moneyTF.placeholder=self.Dict[@"ali_ht"];
    
    [self.view addSubview:self.WDAlipayView];
}

//提交支付宝提现申请
-(void)UpBtnClicked:(UIButton *)btn
{
   
    ZGPromptView  *prompView =[ZGPromptView new] ;

    if (self.WDAlipayView.moneyTF.text.length==0) {
        [prompView addToWithController:self withLabel:@"请输入兑换金额" AndHeight:0];
    }else{

    [ZGManagerHUD showHUDwithMessage:@"正在提交" inViewController:self];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"alipay":self.Dict[@"ali_name"],@"price":@([self.WDAlipayView.moneyTF.text integerValue]),@"realname":self.Dict[@"ali_nick"]};
        [manager POST:KURL_WithDrawalAlipay parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
            
            
             [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
            if ([responseObject[@"message"] isEqualToString:@"提交成功"]) {
                [self DeclineinView];
            }
            [self.MyTableView reloadData];
            [ZGManagerHUD hidesHUDComplection:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [ZGManagerHUD hidesHUDComplection:nil];
        }];
    }
    [self.WDAlipayView.moneyTF resignFirstResponder];
    
}

//创建阴影背景
-(void)createMyView
{
    //背景阴影
    self.MyView=[[UIView alloc]initWithFrame:self.view.bounds];
    self.MyView.backgroundColor=[UIColor blackColor];
    self.MyView.alpha=0;
    [self.view addSubview:self.MyView];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //慢慢下滑支付宝与微信View
    [self DeclineinView];
}

-(void)DeclineinView
{
    [self.WDAlipayView.moneyTF resignFirstResponder];
    [self.wxPayView.moneyTF resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.wxPayView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 180);
        self.WDAlipayView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 230);
        
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
            CGRect frame = self.WDAlipayView.frame;
            // y值减小  视图上升
            frame.origin.y -= height;
            self.WDAlipayView.frame = frame;
        }];
        
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.wxPayView.frame;
            // y值减小  视图上升
            frame.origin.y -= height;
            self.wxPayView.frame = frame;
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
        CGRect frame = self.WDAlipayView.frame;
        // y值增加  视图下降
        frame.origin.y += height;
        self.WDAlipayView.frame = frame;
    }];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.wxPayView.frame;
        // y值减小  视图上升
        frame.origin.y += height;
        self.wxPayView.frame = frame;
    }];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"123" object:nil];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
