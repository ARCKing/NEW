//
//  SettingViewController.m
//  News
//
//  Created by HPmac on 16/5/24.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "SettingViewController.h"

#import "ZGPromptView.h"
#import "PersonManager.h"
#import "settingCell.h"
#import "SDImageCache.h"


static int num=0;
static int login=0;

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *MyTableView;

//存放图片的数组
@property (nonatomic ,strong)NSArray *ImageArr;
//存放文字的数组
@property (nonatomic ,strong)NSArray *TitleArr;
@property (nonatomic ,assign)NSInteger FontSize;
//哪一种字体
@property (nonatomic ,copy)NSString *Title;
//存放缓存的大小
@property (nonatomic ,assign)CGFloat Cache;
//创建退出登录控件
@property (nonatomic ,strong)UIButton *button;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数据源
    self.ImageArr=@[@"ic_setting_font_size",@"ic_setting_clear_buffer",@"ic_setting_send_message"];
    self.TitleArr=@[@"字体大小",@"清除缓存",@"滚动加载"];

    [self createCell];
    
    self.Cache=0;
    

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //程序进入就计算缓存大小
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSLog(@"%@",paths);
        
        NSString *cachesDir = [paths objectAtIndex:0];
        self.Cache = [self folderSizeAtPath:cachesDir];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.MyTableView reloadData];
        });
    });
}
-(void)createCell
{
    //Cell复用
    [self.MyTableView registerNib:[UINib nibWithNibName:@"settingCell" bundle:nil] forCellReuseIdentifier:@"settingCell"];
    
    //去除多余的Cell
    self.MyTableView.tableFooterView=[UIView new];
    self.MyTableView.separatorColor=[UIColor groupTableViewBackgroundColor];
}

// 状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


//查看字体大小  //程序进入就计算缓存大小
-(void)viewWillAppear:(BOOL)animated
{
    num=[[[NSUserDefaults standardUserDefaults]objectForKey:@"ISON"] intValue];
    self.Title=[[NSUserDefaults standardUserDefaults]objectForKey:@"Font"];
    if (self.Title.length==0) {
         self.Title=@"中号";
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    login =[[[NSUserDefaults standardUserDefaults]objectForKey:@"Login"]intValue];
    if (login==1) {
        [self createExitLogin];
    }
}
-(void)createExitLogin
{
    //创建退出登录控件
    self.button=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"退出登录" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.frame=CGRectMake(8, 44*3+30, self.view.bounds.size.width-16, 50);
    self.button.backgroundColor=[UIColor colorWithRed:100/255.0f green:155/255.0f blue:255/255.0f alpha:1];
    
    [self.button addTarget:self action:@selector(deleteBTn:) forControlEvents:UIControlEventTouchUpInside];
    self.button.layer.cornerRadius=3;
    self.button.layer.masksToBounds=YES;
    [self.MyTableView addSubview:self.button];
}

-(void)deleteBTn:(UIButton *)btn
{
    [self CreateAlert:@"确定要退出登录？" AndNum:2];
}

#pragma makr--UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ImageArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.Title=[[NSUserDefaults standardUserDefaults]objectForKey:@"FontStr"];
    if (self.Title.length==0) {
        self.Title=@"中号";
    }
    settingCell *cell=[tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    
    cell.ImgView.image=[UIImage imageNamed:self.ImageArr[indexPath.row]];
    cell.NameLabel.text=self.TitleArr[indexPath.row];

    
    if (indexPath.row==0) {
        cell.warningLabel.hidden=NO;
        cell.warningLabel.textColor=[UIColor grayColor];
        cell.warningLabel.font=[UIFont systemFontOfSize:17];
        cell.warningLabel.text=[NSString stringWithFormat:@"%@字",self.Title];
    }else if (indexPath.row==1){
    
            cell.warningLabel.hidden=NO;
            cell.warningLabel.textColor=[UIColor grayColor];
            cell.warningLabel.font=[UIFont systemFontOfSize:14];
            cell.warningLabel.text=[NSString stringWithFormat:@"%.2fMB",self.Cache];
       
    }else if(indexPath.row==2)
    {
        if (num==1) {
            [cell.Switch setOn:YES animated:YES];
            
        }else{
            [cell.Switch setOn:NO animated:YES];
        }
        cell.Switch.hidden=NO;
        
        [cell.Switch addTarget:self action:@selector(num:) forControlEvents:UIControlEventTouchUpInside];
    }
    //cell右侧小箭头
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)num:(UISwitch *)Switch
{
    if (Switch.isOn==YES) {
        num=1;
    }else{
        num=0;
    }
    [[NSUserDefaults standardUserDefaults]setObject:@(num) forKey:@"ISON"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        //改变字体大小
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cation1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *cation2=[UIAlertAction actionWithTitle:@"小号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@(15) forKey:@"FontSize"];
            [[NSUserDefaults standardUserDefaults]setObject:@"小号" forKey:@"FontStr"];
            [self.MyTableView reloadData];
        }];
        UIAlertAction *cation3=[UIAlertAction actionWithTitle:@"中号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@(17) forKey:@"FontSize"];
            [[NSUserDefaults standardUserDefaults]setObject:@"中号" forKey:@"FontStr"];
            [self.MyTableView reloadData];
        }];
        UIAlertAction *cation4=[UIAlertAction actionWithTitle:@"大号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@(19) forKey:@"FontSize"];
            [[NSUserDefaults standardUserDefaults]setObject:@"大号" forKey:@"FontStr"];
            [self.MyTableView reloadData];
        }];
        UIAlertAction *cation5=[UIAlertAction actionWithTitle:@"超大" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@(21) forKey:@"FontSize"];
            [[NSUserDefaults standardUserDefaults]setObject:@"超大" forKey:@"FontStr"];
            [self.MyTableView reloadData];
        }];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        [alertController addAction:cation1];
        [alertController addAction:cation2];
        [alertController addAction:cation3];
        [alertController addAction:cation4];
        [alertController addAction:cation5];
        
         [self presentViewController:alertController animated:YES completion:nil];
        
    }else if (indexPath.row==1){
       //清理缓存
        [self CreateAlert:@"您确定要清理缓存吗？" AndNum:1];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)CreateAlert:(NSString *)str  AndNum:(NSInteger)num{
//创建警告框
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"温馨提示" message:str preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *Cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    
    }];

    UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    
        if (num==1) {
            //清理缓存
            [self ClearManager];
            
        }else if (num==2){
            //退出登入
            [self Signout];
        }
        
    }];
    [alertController addAction:Cancel];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)Signout
{
    ZGPromptView *prompView =[ZGPromptView new] ;
    [prompView addToWithController:self withString:@"退出成功" withImage:[[UIImage imageNamed:@"show_ok"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    [self performSelector:@selector(Exit) withObject:self afterDelay:1];
}


//清空数据库
-(void)ClearManager
{
        if (self.Cache==0) {
            ZGPromptView *prompView =[ZGPromptView new] ;
             [prompView addToWithController:self withString:@"暂无缓存"] ;
        }
        //清理缓存文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        
        [self clearCache:cachesDir];
        
         self.Cache=0;
        [self.MyTableView reloadData];
}

//计算目录大小
- (float)folderSizeAtPath:(NSString*)path
{
    NSFileManager*fileManager = [NSFileManager defaultManager];
    CGFloat folderSize;
    
    if([fileManager fileExistsAtPath:path]) {
        
        NSArray * childerFiles=[fileManager subpathsAtPath:path];
   
        for(NSString *fileName in childerFiles) {
        
            NSString*absolutePath = [path stringByAppendingPathComponent:fileName];
            // 计算单个文件大小
             folderSize += [self fileSizeAtPath:absolutePath];
        }
    }
    return folderSize;
}

//计算单个文件大小返回值是M
- (float)fileSizeAtPath:(NSString*)path
{
    NSFileManager*fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        // 返回值是字节B K M
    return size/1024.0/1024.0;
    }
    return 0;
}

//清理缓存文件
//同样也是利用NSFileManager API进行文件操作，SDWebImage框架自己实现了清理缓存操作，我们可以直接调用。
- (void)clearCache:(NSString*)path
{
    
    NSFileManager*fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]) {
        
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        
        for(NSString * fileName in childerFiles) {
            
            //如有需要，加入条件，过滤掉不想删除的文件
            
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
       
    }
    // SDImageCache 自带缓存
    [[SDImageCache sharedImageCache] cleanDisk];
    
}

- (IBAction)backClicked:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//退出登录
-(void)Exit
{
    self.button.hidden=YES;
    //保存到本地
    [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:@"Login"];
    PersonManager *manager=[PersonManager shareManager];
    //数据库清空
    if (![manager.PersonDataBase executeUpdate:@"delete from Person"]) {
        NSLog(@"删除失败");
    }
}
@end
