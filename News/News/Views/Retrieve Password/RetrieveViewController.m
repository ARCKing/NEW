
//
//  RetrieveViewController.m
//  
//
//  Created by siyue on 16/5/24.
//
//

#import "RetrieveViewController.h"
#import "ZGPromptView.h"
#import "AFNetworking.h"
#import "ZGNetAPI.h"
#import "ZGManagerHUD.h"
#import "Helper.h"
#import "NSString+MD5.h"

static int number=120;


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface RetrieveViewController ()<UITextFieldDelegate>
{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UITextField *AccountTF;
@property (weak, nonatomic) IBOutlet UITextField *PassWord1TF;
@property (weak, nonatomic) IBOutlet UITextField *PassWord2TF;
@property (weak, nonatomic) IBOutlet UITextField *CodeTF;

@property (weak, nonatomic) IBOutlet UIButton *CodeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;

@end

@implementation RetrieveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self changeUITextField];
    
    self.view.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    
    self.WidthLayout.constant=kScreenWidth;
    self.HeightLayout.constant=kScreenHeight-63.5;
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
}

- (IBAction)BtnClicked:(UIButton *)sender {
    
    if (sender.tag==10) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (sender.tag==11){
        if (self.AccountTF.text.length==0) {
            //手机号码为空
            ZGPromptView *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"请输入手机号码"] ;
          
        }else{
            
            [ZGManagerHUD showHUDViewController:self];
            
            //让HUD旋转一秒在结束
            [self performSelector:@selector(createmobile) withObject:self afterDelay:1];
        }
    }else if (sender.tag==12){

        
                if (self.AccountTF.text.length==0){
        
                    //手机号码为空
                    ZGPromptView *prompView =[ZGPromptView new] ;
                    [prompView addToWithController:self withString:@"请输入手机号码"] ;
                    
                }else{
                    //手机号码不为空
                    if(self.PassWord1TF.text.length==0||self.PassWord2TF.text.length==0){
                    //密码为空
                        ZGPromptView *prompView =[ZGPromptView new] ;
                        [prompView addToWithController:self withString:@"请输入密码" ];
                        
                    }else{
                        //密码不为空 密码不相同
                        if (![self.PassWord1TF.text isEqualToString:self.PassWord2TF.text]) {
                            
                            ZGPromptView *prompView =[ZGPromptView new] ;
                            [prompView addToWithController:self withString:@"两次密码输入不一致" ];
                           
                        }else{
                            //密码不为空 密码相同
                            if (self.CodeTF.text.length==0) {
                                //验证码为空
                                ZGPromptView *prompView =[ZGPromptView new] ;
                                [prompView addToWithController:self withString:@"请输入短信验证码"];
                               
                            }else{
                                //验证码不为空
                                
                                [ZGManagerHUD showHUDViewController:self];
                                
                                //验证成功 失败 调用这个方法
                                //让HUD旋转一秒在结束
                                [self performSelector:@selector(Validation) withObject:self afterDelay:1];
                            }
                            
                        }
                    }
                    
                    
                }
        }
}

//判断验证成功还是失败
-(void)Validation
{
    
    [ZGManagerHUD hidesHUDComplection:nil];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *parame=@{@"password":self.PassWord1TF.text,@"repassword":self.PassWord2TF.text,@"phone_yzm":self.CodeTF.text,@"tel":self.AccountTF.text};
    [manager POST:KURL_FindPassword parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
        
        ZGPromptView  *prompView =[ZGPromptView new] ;
        
       
        //成功 返回登入界面
        if ([responseObject[@"message"] isEqualToString:@"修改成功"]) {
            [prompView addToWithController:self withString:responseObject[@"message"] withImage:[UIImage imageNamed:@"show_ok"]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
        [prompView addToWithController:self withString:responseObject[@"message"] withImage:[UIImage imageNamed:@"show_no"]];
        }
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
        //获取数据
        [self UpCode];
        
    }
}

-(void)UpCode
{
    //identifierForVendor 作为唯一标识
    //获取手机标识
    NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *Key=[NSString stringWithFormat:@"gxtc888%@%@",self.AccountTF.text,identifierStr];
     NSString *endKey=[Key md5];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *Parame=@{@"phone":self.AccountTF.text,@"mi":identifierStr,@"key":endKey};
    [manager POST:KURL_FindPasswordCode parameters:Parame success:^(NSURLSessionDataTask *task, id responseObject) {
        
        ZGPromptView  *prompView =[ZGPromptView new] ;
        if ([responseObject[@"data"][@"message"]isEqualToString:@"发送成功"]) {
            //发送成功 成功创建定时器
            [self createTimer];
             [prompView addToWithController:self withString:responseObject[@"data"][@"message"] withImage:[UIImage imageNamed:@"show_ok"]];
        }else{
             [prompView addToWithController:self withString:responseObject[@"data"][@"message"] withImage:[UIImage imageNamed:@"show_no"]];
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
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES] ;
    
    [_timer fire] ;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
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
