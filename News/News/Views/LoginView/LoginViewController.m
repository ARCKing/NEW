//
//  LoginViewController.m
//  
//
//  Created by siyue on 16/5/24.
//
//

#import "LoginViewController.h"
#import "ZGPromptView.h"
#import "PersonModel.h"

#import "PersonManager.h"
#import "AFNetworking.h"
#import "ZGNetAPI.h"
#import "RegisViewController.h"
#import "RetrieveViewController.h"
#import "ZGManagerHUD.h"
#import "Helper.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *AccountTF;
@property (weak, nonatomic) IBOutlet UITextField *PassWordTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;

@property (nonatomic ,strong)NSDictionary  *dict;

@property (nonatomic ,strong) NSArray *Arr;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    //改变UitextField样式
    [self changeUITextField];
    
    self.WidthLayout.constant=kScreenWidth;
    self.HeightLayout.constant=kScreenHeight-63.5;
    
   self.view.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
}

-(void)changeUITextField
{
    self.AccountTF.leftView.userInteractionEnabled=NO;
    self.AccountTF.layer.cornerRadius=5;
    self.AccountTF.layer.masksToBounds=YES;
    
    self.PassWordTF.layer.cornerRadius=5;
    self.PassWordTF.layer.masksToBounds=YES;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.AccountTF.leftView = view;
    self.AccountTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 5)];
    self.PassWordTF.leftView = view1;
    self.PassWordTF.leftViewMode = UITextFieldViewModeAlways;
}


- (IBAction)BtnClicked:(UIButton *)sender {
    
    if (sender.tag==10) {
        //返回
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }else if (sender.tag==11){
        //Login
        if (self.AccountTF.text.length==0) {
            //  手机为空
           
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"请输入手机号码"];
        }else{
            if (self.PassWordTF.text.length==0) {
                
                //  手机不为空 密码为空
                ZGPromptView  *prompView =[ZGPromptView new] ;
                [prompView addToWithController:self withString:@"请输入密码"];
                
            }else{
                [ZGManagerHUD showHUDwithMessage:@"正在登录" inViewController:self];
                
                [self performSelector:@selector(Updatanetwork) withObject:nil afterDelay:1];
            }
        }
    }else if (sender.tag==12){
        //找回密码
        RetrieveViewController *retrieve=[[RetrieveViewController alloc]initWithNibName:@"RetrieveViewController" bundle:nil];
        [self presentViewController:retrieve animated:YES completion:nil];
    }else if (sender.tag==13){
        //手机注册
        RegisViewController *regis=[[RegisViewController alloc]initWithNibName:@"RegisViewController" bundle:nil];
        [self presentViewController:regis animated:YES completion:nil];
    }
    
}

-(void)Updatanetwork
{
    [ZGManagerHUD hidesHUDComplection:nil];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSDictionary *Parame=@{@"username":self.AccountTF.text,
                           @"password":self.PassWordTF.text};
    
    [manager POST:KURL_Login parameters:Parame success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[NSUserDefaults standardUserDefaults]setObject:responseObject[@"authcode"] forKey:@"authcode"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        
//        NSLog(@"authcode = %@",responseObject[@"authcode"]);
//        NSLog(@"authcode = %@",responseObject);//uc_id" = 2716900 "uc_id" = 2698797
        NSDictionary * memberDic =  responseObject[@"member"];
        NSString * uID = memberDic[@"uc_id"];
        
        NSLog(@"ID = %@",uID);
        
        PersonManager *manager=[PersonManager shareManager];
        //数据库清空
        if (![manager.PersonDataBase executeUpdate:@"delete from Person"]) {
            NSLog(@"删除失败");
        }

        //判断登陆成功还是失败
        //成功
        if ([responseObject[@"message"] isEqualToString:@"登录成功"]) {
            [self.navigationController popViewControllerAnimated:YES];
            //保存到本地
            [[NSUserDefaults standardUserDefaults]setObject:@(1) forKey:@"Login"];
            
//            =========================
            
            
            //用户ID
            [[NSUserDefaults standardUserDefaults]setObject:uID forKey:@"uID"];

//            =========================
            
        }else{
            // 失败
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:responseObject[@"message"]];
        }
        NSDictionary *dict=responseObject[@"member"];
        
        //积分  integral
        
        //插入数据
        if(! [manager.PersonDataBase executeUpdate:@"insert into Person (headimgurl,nickname,member_id,phone,level) values(?,?,?,?,?)",dict[@"headimgurl"]
              ,dict[@"nickname"],dict[@"member_id"],dict[@"phone"],dict[@"level"]])
        {
            NSLog(@"数据插入失败");
        }
    
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
    
}
//   视图将被从屏幕上移除之前执行
-(void)viewWillDisappear:(BOOL)animated
{
    [self.AccountTF resignFirstResponder];
    [self.PassWordTF resignFirstResponder];
}

//点击Return键盘收起
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)Tap:(UITapGestureRecognizer *)sender {
    [self.AccountTF resignFirstResponder];
    [self.PassWordTF resignFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
