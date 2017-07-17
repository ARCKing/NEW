//
//  RegisViewController.m
//  
//
//  Created by siyue on 16/5/24.
//
//

#import "RegisViewController.h"
#import "ZGPromptView.h"

#import "NSString+MD5.h"
#import "ZGNetAPI.h"
#import "Helper.h"
#import "AFNetworking.h"

#import "ZGManagerHUD.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

static int number;

@interface RegisViewController ()

{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UITextField *AccountTF;
@property (weak, nonatomic) IBOutlet UITextField *CodeTF;
@property (weak, nonatomic) IBOutlet UITextField *PassWord1TF;
@property (weak, nonatomic) IBOutlet UITextField *PassWord2TF;
@property (weak, nonatomic) IBOutlet UITextField *InViteTF;

@property (weak, nonatomic) IBOutlet UIButton *CodeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayout;
@end

@implementation RegisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self changeUITextField];
    
    self.view.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    self.WidthLayout.constant=kScreenWidth;
    self.heightLayout.constant=kScreenHeight-63.5;
}


-(void)changeUITextField
{
    
    //切圆
    self.CodeBtn.layer.cornerRadius=2;
    self.CodeBtn.layer.masksToBounds=YES;
    
    self.CodeBtn.layer.cornerRadius=3;
    self.CodeBtn.layer.masksToBounds=YES;
    
    
    self.PassWord1TF.layer.cornerRadius=5;
    self.PassWord1TF.layer.masksToBounds=YES;
    
    self.AccountTF.layer.cornerRadius=5;
    self.AccountTF.layer.masksToBounds=YES;
    
    
    self.PassWord2TF.layer.cornerRadius=5;
    self.PassWord2TF.layer.masksToBounds=YES;
    
    self.CodeTF.layer.cornerRadius=5;
    self.CodeTF.layer.masksToBounds=YES;
    
    
    self.InViteTF.layer.cornerRadius=5;
    self.InViteTF.layer.masksToBounds=YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.AccountTF.leftView = view;
    self.AccountTF.leftViewMode = UITextFieldViewModeAlways;
    
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.PassWord1TF.leftView = view1;
    self.PassWord1TF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.PassWord2TF.leftView = view2;
    self.PassWord2TF.leftViewMode = UITextFieldViewModeAlways;
    
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.CodeTF.leftView = view3;
    self.CodeTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.InViteTF.leftView = view4;
    self.InViteTF.leftViewMode = UITextFieldViewModeAlways;
}

-(void)viewWillAppear:(BOOL)animated
{
    number=120;
}

//页面消失  定时器销毁
-(void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
    [_timer setFireDate:[NSDate distantFuture]];
}

- (IBAction)BtnClicked:(UIButton *)sender {
    //返回
    if (sender.tag==10) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    //点击获取验证码
    if (sender.tag==11){
    //URL 
       
        // 号码为空
        if (self.AccountTF.text.length==0) {
            
            
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"请输入手机号码"];
           
        }else{
            
            //  号码不为空
            [ZGManagerHUD showHUDViewController:self];
            //1秒执行
            [self performSelector:@selector(createmobile) withObject:self afterDelay:1];
        }
    }
    //点击注册
    if (sender.tag==12){
        
        if (self.AccountTF.text.length==0){
            //手机号码为空
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"请输入手机号码"];
        }else{
            //手机号码不为空
            if(self.CodeTF.text.length==0){
            //验证码为空
                ZGPromptView  *prompView =[ZGPromptView new] ;
                [prompView addToWithController:self withString:@"请输入手机验证码"];
            }else{
            //验证码不为空
                if(self.PassWord1TF.text.length==0||self.PassWord2TF.text.length==0){
                    ZGPromptView  *prompView =[ZGPromptView new] ;
                    [prompView addToWithController:self withString:@"请输入密码"];

                }else{
                    if (![self.PassWord1TF.text isEqualToString:self.PassWord2TF.text]) {
                        //密码不相同
                        ZGPromptView  *prompView =[ZGPromptView new] ;
                        [prompView addToWithController:self withString:@"两次密码输入不一致"];
                    }else{
                       
                        //判断注册是否成功

                        [self regisAccount];
                    
                    
                    }
                }
            
            }
        
        }
    
    }
}

//注册

-(void)regisAccount
{
    //获取手机标识
    NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *Parame=@{@"password":self.PassWord1TF.text,@"repassword":self.PassWord2TF.text,@"sms_verify":self.CodeTF.text,@"inviter":self.InViteTF.text,@"mi":identifierStr,@"username":self.AccountTF.text};
    [manager POST:KURL_Regis parameters:Parame success:^(NSURLSessionDataTask *task, id responseObject) {
        
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:responseObject[@"message"] withImage:[UIImage imageNamed:@"show_no"]];
    
        
        [ZGManagerHUD hidesHUDComplection:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ZGManagerHUD hidesHUDComplection:nil];
    }];
}



-(void)createmobile
{
    [ZGManagerHUD hidesHUDComplection:nil];
    //手机无效
    if ([Helper justMobile:self.AccountTF.text]==NO) {

        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"手机号有误" withImage:[UIImage imageNamed:@"show_no"]];
       
    }else{
        [ZGManagerHUD showHUDViewController:self];
        //获取短信验证码
        [self FindPasswordCode];
        
    }
}

-(void)FindPasswordCode
{
    //identifierForVendor 作为唯一标识
    //获取手机标识
    NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *Key=[NSString stringWithFormat:@"gxtc888%@%@",self.AccountTF.text,identifierStr];
    NSString *endKey=[Key md5];

    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *Parame=@{@"phone":self.AccountTF.text,@"type":@"register",@"mi":identifierStr,@"key":endKey};
    [manager POST:KURL_UserCode parameters:Parame success:^(NSURLSessionDataTask *task, id responseObject) {
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:responseObject[@"message"] withImage:[UIImage imageNamed:@"show_ok"]];
        
        if ([responseObject[@"message"] isEqualToString:@"发送成功"]) {
            //如果注册过创建一个定时器
            [self createTimer];
        }
        
        
        [ZGManagerHUD hidesHUDComplection:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ZGManagerHUD hidesHUDComplection:nil];
    }];

}
//创建一个定时器
-(void)createTimer
{
    /**
     *  开发定时器
     */
    _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
    [_timer setFireDate:[NSDate distantPast]];

}
//120s-0s
-(void)timerAction
{
    number--;
    if (number>0) {
        //不能点击
        self.CodeBtn.userInteractionEnabled=NO;
        [self.CodeBtn setTitle:[NSString stringWithFormat:@"%ds",number] forState:UIControlStateNormal];
    }else if(number==0){
        
        number=120;
        [_timer invalidate];
        [_timer setFireDate:[NSDate distantFuture]];
        self.CodeBtn.userInteractionEnabled=YES;
       [self.CodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
   
}

//   视图将被从屏幕上移除之前执行
-(void)viewWillDisappear:(BOOL)animated
{
    [self.AccountTF resignFirstResponder];
    [self.PassWord1TF resignFirstResponder];
    [self.PassWord2TF resignFirstResponder];
    [self.CodeTF resignFirstResponder];
}

//点击Return键盘收起
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)Tap:(UITapGestureRecognizer *)sender {
    [self.AccountTF resignFirstResponder];
    [self.PassWord1TF resignFirstResponder];
    [self.PassWord2TF resignFirstResponder];
    [self.CodeTF resignFirstResponder];
    [self.InViteTF resignFirstResponder];
    
}

//移除定时器
-(void)dealloc
{
    [_timer invalidate];
    [_timer setFireDate:[NSDate distantFuture]];
}
/**
 *  状态栏的颜色
 *
 *  @return 状态栏的颜色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
