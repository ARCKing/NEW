//
//  PersonViewController.m
//  News
//
//  Created by ZZG on 16/5/29.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "PersonViewController.h"

#import "ZGPromptView.h"
#import "ZGManagerHUD.h"
#import "MallViewController.h"
#import "NikeNameView.h"
#import "ZGNetAPI.h"
#import "AFNetworking.h"
#import "PassWordView.h"
#import "PersonViewCell.h"
#import "PersonManager.h"
#import "UIImageView+WebCache.h"
#import "PersonManager.h"
#import "NSString+MD5.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)


//判断键盘弹起
static int i=1;

static int number=0;

@interface PersonViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>


@property (nonatomic ,strong)NSArray *titleArr;
@property (nonatomic ,strong) NikeNameView *NameView;
@property (weak, nonatomic) IBOutlet UITableView *MytableView;
@property (nonatomic ,strong)UIImageView *IMgView;
@property (nonatomic ,strong)UIImagePickerController *picker;
@property (nonatomic ,strong)PassWordView *passwordview;
@property (nonatomic ,strong)UIView *Myview;


@property (nonatomic ,copy)NSString  *member_id;
@end

@implementation PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建一个通知
    [self postNotification];
    // 注册键盘回收 与 弹起的通知
    [self addNotification];
    
    self.automaticallyAdjustsScrollViewInsets=YES;
    self.titleArr=@[@"头像",@"ID",@"昵称",@"手机号码",@"我的等级",@"修改密码"];

    [self.MytableView registerNib:[UINib nibWithNibName:@"PersonViewCell" bundle:nil] forCellReuseIdentifier:@"PersonViewCell"];
    
    //线条的颜色
    self.MytableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    
    //去除多余的Cell
    self.MytableView.tableFooterView=[UIView new];
    [self.MytableView setContentInset:UIEdgeInsetsMake(15, 0, 0, 0)];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    PersonManager *manager=[PersonManager shareManager];
    //读取，查询
    FMResultSet *rs=[manager.PersonDataBase executeQuery:@"select * from Person"];
    
    //遍历查询的结果  用模型装起来
    while ([rs next]) {
        if([rs stringForColumn:@"nickname"].length!=0){
          
            self.member_id=[rs stringForColumn:@"member_id"];
        }
    }
    
    [self.MytableView reloadData];
    
    self.navigationController.navigationBar.hidden=YES;
}

#pragma mark--UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 70;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PersonViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"PersonViewCell" forIndexPath:indexPath];
    
    Cell.TitleLabel.text=self.titleArr[indexPath.row];
    
        PersonManager *manager=[PersonManager shareManager];
        //读取，查询
        FMResultSet *rs=[manager.PersonDataBase executeQuery:@"select * from Person"];
    
    //遍历查询的结果  用模型装起来
            while ([rs next]) {
                    if (indexPath.row==0) {
                        Cell.NumberLabel.hidden=YES;
                        Cell.PersonImg.hidden=NO;
                        [Cell.PersonImg sd_setImageWithURL:[NSURL URLWithString:[rs stringForColumn:@"headimgurl"]] placeholderImage:[UIImage imageNamed:@"headicon_default"]];
                    }else if (indexPath.row==1){
                        Cell.NumberLabel.text=[rs stringForColumn:@"member_id"];
                    }else if (indexPath.row==2){
                        Cell.NumberLabel.text=[rs stringForColumn:@"nickname"];
                    }else if (indexPath.row==3){
                        Cell.NumberLabel.text=[rs stringForColumn:@"phone"];
                    }else if(indexPath.row==4){
                        Cell.NumberLabel.text=[NSString stringWithFormat:@"%@级", [rs stringForColumn:@"level"]];
                    }else if (indexPath.row==5){
                    Cell.NumberLabel.hidden=YES;
                    }
            }
    
    return Cell;
}


- (IBAction)ReturnBtnClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        //更换头像
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (TARGET_IPHONE_SIMULATOR) {
                self.picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            }else{
                //真机摄像头
                self.picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            }
            //推出图片选择器
            [self presentViewController:self.picker animated:YES completion:nil];

        }];
        UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            //推出图片选择器
            [self presentViewController:self.picker animated:YES completion:nil];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [alertController addAction:archiveAction];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else if (indexPath.row==2){
        //更换昵称
        [self createView];
        [self createNameView];
        [UIView transitionWithView:self.NameView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.NameView.frame=CGRectMake(0,kScreenHeight - 148, kScreenWidth, 148);
        } completion:NULL];
    }else if (indexPath.row==4){
        //我的等级
        MallViewController *mallVC=[[MallViewController alloc]initWithNibName:@"MallViewController" bundle:nil];
        
        [self.navigationController pushViewController:mallVC animated:YES];
    }else if (indexPath.row==5){
        //修改密码
        [self createView];
        [self createPassword];
        [UIView transitionWithView:self.passwordview duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.passwordview.frame=CGRectMake(0,kScreenHeight - 270, kScreenWidth, 270);
        } completion:NULL];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark--UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{    
    //使用PNG格式转换
    NSData *data=UIImagePNGRepresentation(info[@"UIImagePickerControllerEditedImage"]);
    NSString *path=[NSHomeDirectory() stringByAppendingString:@"/Documents/123.png"];
    
    //相册
    [self changePersonImage:path imagedata:data];
    //写二进制
    [data writeToFile:path atomically:YES];
     number=1;
    [ZGManagerHUD showHUDwithMessage:@"正在上传" inViewController:self];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}
//修改头像
-(void)changePersonImage:(NSString *)phoneURL imagedata:(NSData *)data
{
    //获取手机标识
    NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *Key=[NSString stringWithFormat:@"gxtc888%@%@",self.member_id,identifierStr];
    NSString *endKey=[Key md5];
    
    NSDictionary *parame=@{@"mi":identifierStr,@"key":endKey,@"uu":self.member_id};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:KURL_changepersonImage parameters:parame constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        // 上传图片，以文件流的格式
            [formData appendPartWithFileData:data name:@"avatar" fileName:fileName mimeType:@"jpg/png"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        PersonManager *manager=[PersonManager shareManager];
        
        NSString *str=[NSString stringWithFormat:@"UPDATE Person SET headimgurl='%@'",responseObject[@"member"][@"headimgurl"]];
        
        if (![manager.PersonDataBase executeUpdate:str]) {
            NSLog(@"修改失败");
        }
        
        if ([responseObject[@"message"]isEqualToString:@"上传成功"]) {
            
            
            ZGPromptView  *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
            
            
            [ZGManagerHUD hidesHUDComplection:nil];
        }
        
        
        //刷新
        [self.MytableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [ZGManagerHUD hidesHUDComplection:nil];
    }];
}
//创建弹出修该昵称的View
-(void)createNameView
{
    self.NameView.backgroundColor=[UIColor whiteColor];
    self.NameView=[[NSBundle mainBundle]loadNibNamed:@"NikeNameView" owner:nil options:0][0];
    [self.NameView.ChangeNameBtn addTarget:self action:@selector(ChangeTheName:) forControlEvents:UIControlEventTouchUpInside];
    self.NameView.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 130);
    [self.view addSubview:self.NameView];
}

//修改昵称
-(void)ChangeTheName:(UIButton *)btn
{
    //创建警告框
     ZGPromptView  *prompView =[ZGPromptView new] ;

    if (self.NameView.NameTF.text.length==0) {
        
        [prompView addToWithController:self withLabel:@"请输入昵称" AndHeight:0];
        
    }else{
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        
        NSDictionary *dict=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"nickname":self.NameView.NameTF.text};
        [manager POST:KURL_changename parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
            
            
           
            [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
            
            
            if ([responseObject[@"message"] isEqualToString:@"修改成功"]) {
                PersonManager *manager=[PersonManager shareManager];
                
                NSString *str=[NSString stringWithFormat:@"UPDATE Person SET nickname='%@'",self.NameView.NameTF.text];
                [self hidinWXViewAndAlipayView];
                if (![manager.PersonDataBase executeUpdate:str]) {
                    NSLog(@"修改失败");
                }
            }
            [self.MytableView reloadData];
            

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        }];
    }
    
    [self.NameView.NameTF resignFirstResponder];
}

//创建一个背景阴影
-(void)createView
{
    self.Myview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.Myview.backgroundColor=[UIColor blackColor];
    self.Myview.alpha=0.7;
    [self.view addSubview:self.Myview];
}

//创建弹出修改密码
-(void)createPassword
{
    self.passwordview.layer.shadowColor=[UIColor redColor].CGColor;
     self.passwordview=[[NSBundle mainBundle]loadNibNamed:@"PassWordView" owner:nil options:0][0];
    [self.passwordview.UpdataBtn addTarget:self action:@selector(ChangeThePassword:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordview.frame=CGRectMake(0, kScreenHeight, kScreenWidth, 240);
    [self.view addSubview:self.passwordview];
}
//修改密码
-(void)ChangeThePassword:(UIButton *)btn
{
    //创建警告框
    ZGPromptView  *prompView =[ZGPromptView new] ;
    if (self.passwordview.OldPasswordTF.text.length==0) {
        
        [prompView addToWithController:self withLabel:@"请输入原密码" AndHeight:0];
        
    }else{
        if (self.passwordview.NewPasswordTF.text.length==0) {
            
            [prompView addToWithController:self withLabel:@"请输入新密码" AndHeight:0];
            
        }else{
            if (self.passwordview.NewPassword2TF.text.length==0) {
                
                [prompView addToWithController:self withLabel:@"请再次输入新密码" AndHeight:0];
                
            }else{
                if (![self.passwordview.NewPasswordTF.text isEqualToString:self.passwordview.NewPassword2TF.text]) {
                    
                    [prompView addToWithController:self withLabel:@"两次密码不相等" AndHeight:0];
                    
                }else{
                    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
                    
                    NSDictionary *parame=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"password":self.passwordview.NewPasswordTF.text,@"repassword":self.passwordview.NewPassword2TF.text,@"oldpassword":self.passwordview.OldPasswordTF.text};
                    
                    [manager POST:KURL_changePassWord parameters:parame success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        
                        
                        [prompView addToWithController:self withLabel:responseObject[@"message"] AndHeight:0];
                        if ([responseObject[@"message"] isEqualToString:@"修改成功"]) {
                            [self hidinWXViewAndAlipayView];
                        }
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                    }];
                }
            }
        }
    }

    
    //确定完键盘隐藏
    [self.passwordview.NewPasswordTF resignFirstResponder];
    [self.passwordview.NewPassword2TF resignFirstResponder];
    [self.passwordview.OldPasswordTF resignFirstResponder];
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
        // 获得textField
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.passwordview.frame;
            // y值减小  视图上升
            frame.origin.y -= height;
            self.passwordview.frame = frame;
        }];
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = self.NameView.frame;
            // y值减小  视图上升
            frame.origin.y -= height;
            self.NameView.frame = frame;
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
    
    // 获得textField
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.passwordview.frame;
        // y值增加  视图下降
        frame.origin.y += height;
        self.passwordview.frame = frame;
    }];
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.NameView.frame;
        // y值增加  视图下降
        frame.origin.y += height;
        self.NameView.frame = frame;
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"123" object:nil];
}

#pragma mark--getter&setter

//创建图片控制器
-(UIImagePickerController *)picker
{
    if (_picker==nil) {
            _picker=[[UIImagePickerController alloc]init];
            _picker.delegate=self;
            _picker.allowsEditing=YES;
    }
        return _picker;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidinWXViewAndAlipayView];
}
-(void)hidinWXViewAndAlipayView
{
    [self hiddenView];
    [UIView animateWithDuration:0.2 animations:^{
        self.NameView.frame=CGRectMake(0,kScreenHeight, kScreenWidth, 130);
        self.passwordview.frame=CGRectMake(0,kScreenHeight, kScreenWidth, 240);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.Myview.hidden=YES;
        }];
    }];
}

-(void)hiddenView
{
    [self.passwordview.NewPasswordTF resignFirstResponder];
    [self.passwordview.NewPassword2TF resignFirstResponder];
    [self.passwordview.OldPasswordTF resignFirstResponder];
    [self.NameView.NameTF resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.passwordview.NewPasswordTF resignFirstResponder];
    [self.passwordview.NewPassword2TF resignFirstResponder];
    [self.passwordview.OldPasswordTF resignFirstResponder];
    [self.NameView.NameTF resignFirstResponder];
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
