//
//  InviteCodeViewController.m
//  News
//
//  Created by ZZG on 16/6/3.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "InviteCodeViewController.h"

#import "ZGPromptView.h"

#import "AFNetworking.h"
#import "PersonManager.h"
#import "ZGNetAPI.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)
@interface InviteCodeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *CodeTF;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;


//分享的三个内容
@property (nonatomic ,copy)NSString *textToShare;
@property (nonatomic ,copy)NSString *urlToShare;
@property (nonatomic ,copy)NSString *imageToShare;

@end

@implementation InviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.CodeTF.layer.cornerRadius=5;
    self.CodeTF.layer.masksToBounds=YES;
    
    self.view.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    self.WidthLayout.constant=kScreenWidth;
    self.HeightLayout.constant=kScreenHeight-64;
}

//添加右视图
-(void)TFrightView
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.frame=CGRectMake(0, 0, 40, 30);
    [btn addTarget:self action:@selector(Clicked:) forControlEvents:UIControlEventTouchUpInside];
    self.CodeTF.rightView=btn;
    self.CodeTF.rightViewMode=UITextFieldViewModeAlways;
}

-(void)viewWillAppear:(BOOL)animated
{
    PersonManager *manager=[PersonManager shareManager];
    //读取，查询
    FMResultSet *rs=[manager.PersonDataBase executeQuery:@"select * from Person"];
    
    //遍历查询的结果  用模型装起来
    while ([rs next]) {
        
        self.IDLabel.text=[rs stringForColumn:@"member_id"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self UpmoneyData];

}
//获取钱包数据
-(void)UpmoneyData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
  
    [manager POST:KURL_Invitation parameters:@{@"authcode":[[[NSUserDefaults standardUserDefaults] objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} success:^(NSURLSessionDataTask *task, id responseObject) {

       self.textToShare= responseObject[@"data"][@"abstract"];
        self.imageToShare=responseObject[@"data"][@"thumb"];
        self.urlToShare=responseObject[@"data"][@"link"];

        self.TitleLabel.text=responseObject[@"data"][@"text_1"];
        self.TitleLabel2.text=responseObject[@"data"][@"text_2"];
        if ([responseObject[@"data"][@"invite"] intValue]==0) {
            [self TFrightView];
            self.CodeTF.placeholder=@"填写好友邀请码";
        }else {
            self.CodeTF.placeholder=@"邀请码已填写,奖励已发出";
            self.CodeTF.userInteractionEnabled=NO;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}
-(void)Clicked:(UIButton *)btn
{

    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    [manager POST:KURL_UPInvitation parameters:@{@"authcode":[[[NSUserDefaults standardUserDefaults] objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"yqm":self.CodeTF.text} success:^(NSURLSessionDataTask *task, id responseObject) {
        
    
        //点击邀请码
        ZGPromptView *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:responseObject[@"message"]] ;
        
        if ([responseObject[@"message"]isEqualToString:@"操作成功"]) {
            
           self.CodeTF.placeholder=@"   邀请码已填写,奖励已发送";
            self.CodeTF.userInteractionEnabled=NO;
            self.CodeTF.rightView.hidden=YES;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}



- (IBAction)BtnClicked:(UIButton *)sender {
    
    if (sender.tag==10) {
         [self.navigationController popViewControllerAnimated:YES];
    }else if (sender.tag==11){
    //复制
        
        UIPasteboard *pab = [UIPasteboard generalPasteboard];
        NSString *string = self.IDLabel.text;
        [pab setString:string];
        ZGPromptView *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"复制成功" withImage:[UIImage imageNamed:@"show_ok"]];
        
    }else if (sender.tag==12){
    //立即分享
        
        UIImage *Image = [UIImage imageNamed:@"ic_launcher"];
        //分享  先把图片转换成二进制
       
        NSArray *activityItems = @[self.textToShare,Image,[NSURL URLWithString:self.urlToShare]] ;
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        [self presentViewController:activity animated:YES completion:nil];
    }
}


- (IBAction)TapClicked:(id)sender {
    [self.CodeTF resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
