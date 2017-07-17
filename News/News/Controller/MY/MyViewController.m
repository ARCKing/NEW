//
//  MyViewController.m
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "MyViewController.h"

#import "MyNavigationController.h"
#import "CreditWebViewController.h"
#import "CreditNavigationController.h"
#import "InviteCodeViewController.h"
#import "ZGManagerHUD.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "PersonManager.h"

#import "settingCell.h"

#import "LoginViewController.h"
#import "HistoryViewController.h"
#import "SettingViewController.h"
#import "CollectionController.h"
#import "PersonViewController.h"
#import "MoneyViewController.h"


#import "TWMessageBarManager.h"
#import <YWFeedbackFMWK/YWFeedbackKit.h>

static float HearViewOriginHight =280;

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

static int Login=0;

@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *MytableView;
@property (nonatomic ,copy)NSString  *URLStr;
@property (nonatomic ,copy)NSString  *url;
@property (nonatomic ,strong)NSArray *ImageArr;
@property (nonatomic ,strong)NSArray *TitleArr;
@property (nonatomic, strong) YWFeedbackKit *feedbackKit;
@property (nonatomic, assign) YWEnvironment environment;
@property (nonatomic, strong) NSString *appKey;

@property (nonatomic ,strong)UIView *redView;
@property (nonatomic ,strong)UIView *whiteView;
@property (nonatomic ,strong)UIImageView *PersonImg;
@property (nonatomic ,strong)UILabel *nameLabel;
@property (nonatomic ,strong)UILabel *TitleLabel;
@property (nonatomic ,strong)UIImageView *ToPersonImage;
@property (nonatomic ,strong)UIBlurEffect *effect;
@property (nonatomic ,strong)UIVisualEffectView *effectView;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    self.ImageArr=@[@"ic_usr_page_item_task_center",@"ic_usr_page_item_invite_friends",@"ic_usr_page_item_historyread",@"ic_usr_page_item_setting",@"ic_usr_page_item_feedback"];
    self.TitleArr=@[@"个人信息",@"邀请码",@"历史阅读",@"设置",@"反馈"];
    [self.MytableView registerNib:[UINib nibWithNibName:@"settingCell" bundle:nil] forCellReuseIdentifier:@"settingCell"];
  
    self.automaticallyAdjustsScrollViewInsets=NO;
    //去除多余的Cell
    self.MytableView.tableFooterView=[UIView new];
    self.MytableView.separatorColor=[UIColor groupTableViewBackgroundColor];

}


-(void)createPersonView
{
    self.MytableView.contentInset=UIEdgeInsetsMake(HearViewOriginHight, 0, 0, 0);
    self.redView=[[UIView alloc]initWithFrame:CGRectMake(0, -HearViewOriginHight, kScreenWidth, HearViewOriginHight)];
    self.redView.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    [self.MytableView addSubview:self.redView];
    
    
    self.ToPersonImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, HearViewOriginHight)];
    
    self.ToPersonImage.contentMode=UIViewContentModeScaleToFill;
    self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:self.effect];
    self.effectView.frame = CGRectMake(0, 0, kScreenWidth*3, kScreenHeight*2);
    [self.ToPersonImage addSubview:self.effectView];
    [self.redView addSubview:self.ToPersonImage];
    
    
    self.whiteView=[[UIView alloc]initWithFrame:CGRectMake(0, self.redView.frame.size.height-80  , kScreenWidth, 80)];
    self.whiteView.backgroundColor=[UIColor whiteColor];
    [self.redView addSubview:self.whiteView];
    
    
    self.PersonImg=[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-30, 57, 60, 60)];
    self.PersonImg.image=[UIImage imageNamed:@"headicon_default"];
    self.PersonImg.userInteractionEnabled=YES;
    self.PersonImg.layer.borderColor=[UIColor whiteColor].CGColor;
    self.PersonImg.layer.borderWidth=2;
    self.PersonImg.layer.cornerRadius=30;
    self.PersonImg.layer.masksToBounds=YES;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Tap:)];
    [self.PersonImg addGestureRecognizer:tap];
    [self.redView addSubview:self.PersonImg];
    
    self.nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 125, kScreenWidth, 25)];
    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    self.nameLabel.font=[UIFont systemFontOfSize:19];
    self.nameLabel.textColor=[UIColor whiteColor];
    self.nameLabel.text=@"未登入";
    [self.redView addSubview:self.nameLabel];
    
    self.TitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 155, kScreenWidth, 25)];
    [self.TitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.TitleLabel.font=[UIFont systemFontOfSize:17];
    self.TitleLabel.textColor=[UIColor colorWithRed:1 green:1 blue:0 alpha:1];
    self.TitleLabel.text=@"登入赚取积分，兑现金";
    [self.redView addSubview:self.TitleLabel];
    
    NSArray *imageArr=@[@"ic_usr_page_item_favorite",@"ic_usr_page_item_integral",@"ic_usr_page_item_mall"];
    NSArray *titleArr=@[@"收藏",@"钱包",@"商城"];
    for (int i=0; i<3; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(kScreenWidth/3*i, 0, kScreenWidth/3-1, 67);
        button.tag=11+i;
        [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteView addSubview:button];
        
        for (int k=1; k<3; k++) {
            UIView *view=[[UIView alloc]initWithFrame:CGRectMake(kScreenWidth/3*k+0.5, 0, 0.5, 67)];
            view.backgroundColor=[UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1];
            [self.whiteView addSubview:view];
        }
        
        UIImageView *imgview=[[UIImageView alloc]initWithFrame:CGRectMake(button.frame.size.width/2-12.5, 7, 25, 25)];
        imgview.image=[UIImage imageNamed:imageArr[i]];
        [button addSubview:imgview];
        
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 40, button.frame.size.width, 24)];
        label.text=titleArr[i];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        label.textColor=[UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1];
        label.font=[UIFont systemFontOfSize:14];
        
        [button addSubview:label];
    }
    
    
    UIView *grayView=[[UIView alloc]initWithFrame:CGRectMake(0, self.whiteView.frame.size.height-15    , kScreenWidth, 15)];
    grayView.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    [self.whiteView addSubview:grayView];

}
#pragma mark -- 滚动视图的代理方法
- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
    //获取滚动视图y值的偏移量
    CGFloat yOffset  = scrollView.contentOffset.y;
    CGFloat xOffset = (yOffset +HearViewOriginHight)/2;
    
    if(yOffset<=-HearViewOriginHight) {
        
        CGRect f =self.redView.frame;
        f.origin.x= xOffset;
        f.origin.y= yOffset ;
        f.size.height=  -yOffset;
        f.size.width=kScreenWidth + fabs(xOffset)*2;
        
        
        self.PersonImg.frame=CGRectMake(-xOffset + kScreenWidth/2-30, 57-xOffset, 60, 60);
        self.nameLabel.frame=CGRectMake(-xOffset, 125-xOffset, kScreenWidth, 25);
        self.TitleLabel.frame=CGRectMake(-xOffset, 155-xOffset, kScreenWidth, 24);
        self.whiteView.frame=CGRectMake(-xOffset, -yOffset-80  , kScreenWidth, 80);
        self.ToPersonImage.frame=CGRectMake(0, 0, f.size.width, -yOffset);
    
        self.redView.frame= f;
    
    }else{
    
    }
}
-(void)btnClicked:(UIButton *)sender
{
    if (sender.tag==11) {
        HistoryViewController *history=[[HistoryViewController alloc]initWithNibName:@"HistoryViewController" bundle:nil];
        history.hidesBottomBarWhenPushed=YES;
        
        [self.navigationController pushViewController:history animated:YES];
    }
    
    //没有登录跳转的界面
    if (Login==0) {
        if (sender.tag!=11) {
            LoginViewController *login=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            login.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:login animated:YES];
        }
        
    }else{
        //登录跳转的界面
        if (sender.tag==10) {
            PersonViewController *personView=[[PersonViewController alloc]initWithNibName:@"PersonViewController" bundle:nil];
            personView.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:personView animated:YES];
        }else if(sender.tag==12){
            //钱包
            MoneyViewController *money=[[MoneyViewController alloc]initWithNibName:@"MoneyViewController" bundle:nil];
            
            money.url=[NSString stringWithFormat:@"http://wz.lefei.com/?m=Api&c=Integral&a=Index&authcode=%@",self.URLStr];
            
            money.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:money animated:YES];
            
        }else if (sender.tag==13){
            
            [self UPdataUrl:@"http://wz.lefei.com/?m=Api&c=Duiba&a=dlogin&authcode"];
            [ZGManagerHUD showHUDViewController:self.tabBarController];
        }
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
   
    [self createPersonView];
    
    self.ToPersonImage.hidden=YES;
    PersonManager *manager=[PersonManager shareManager];
    //读取，查询
    FMResultSet *rs=[manager.PersonDataBase executeQuery:@"select * from Person"];
    
    //遍历查询的结果  用模型装起来
    while ([rs next]) {
        if([rs stringForColumn:@"nickname"].length!=0){
            self.nameLabel.text=[rs stringForColumn:@"nickname"];
            [self.PersonImg sd_setImageWithURL:[NSURL URLWithString:[rs stringForColumn:@"headimgurl"]] placeholderImage:[UIImage imageNamed:@"headicon_default"]];
            
            [self.ToPersonImage sd_setImageWithURL:[NSURL URLWithString:[rs stringForColumn:@"headimgurl"]] placeholderImage:[UIImage imageNamed:@"headicon_default"]];
            
            self.redView.clipsToBounds=YES;
            self.ToPersonImage.hidden=NO;
            self.TitleLabel.hidden=YES;
        }
    }
    
   self.URLStr=[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //判断登录还是没登录
    Login=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Login"] intValue];
    
    //隐藏导航栏
     self.navigationController.navigationBarHidden=YES;
     [self.MytableView setContentOffset:CGPointMake(0, -HearViewOriginHight) animated:NO];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ImageArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    settingCell *cell=[tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    if (indexPath.row==1) {
        cell.warningLabel.hidden=NO;
        cell.warningLabel.text=@"输入好友邀请码送积分";
    }
    cell.ImgView.image=[UIImage imageNamed:self.ImageArr[indexPath.row]];
    cell.NameLabel.text=self.TitleArr[indexPath.row];

    //cell右侧小箭头
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)Tap:(UITapGestureRecognizer *)sender{
    if (Login==0) {
        LoginViewController *login=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        login.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:login animated:YES];
        
    }else{
        //登录跳转的界面
        PersonViewController *personView=[[PersonViewController alloc]initWithNibName:@"PersonViewController" bundle:nil];
        personView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:personView animated:YES];
    }

}

//获取商城的URL
-(void)UPdataUrl:(NSString *)str
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@=%@",str,self.URLStr] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
       self.url = responseObject[@"data"][@"url"];
        [ZGManagerHUD hidesHUDComplection:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        [ZGManagerHUD hidesHUDComplection:nil];
    }];

    [self performSelector:@selector(shoping) withObject:self afterDelay:1];
}
-(void)shoping
{
    CreditWebViewController *web=[[CreditWebViewController alloc]initWithUrlByPresent:self.url];
    CreditNavigationController *nav=[[CreditNavigationController alloc]initWithRootViewController:web];
    [nav setNavColorStyle:[UIColor colorWithRed:211/255.0 green:33/255.0f blue:33/255.0 alpha:1]];
    [self presentViewController:nav animated:NO completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
            //没登录
            if (Login==0) {
            LoginViewController *login=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            login.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:login animated:YES];
            }else{
                //登录
                PersonViewController *personView=[[PersonViewController alloc]initWithNibName:@"PersonViewController" bundle:nil];
                personView.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:personView animated:YES];
            }
    }
    if (indexPath.row==1) {
        if (Login==0) {
            LoginViewController *login=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            login.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:login animated:YES];
        }else{
            //登录过  邀请码
            InviteCodeViewController *invitecode=[[InviteCodeViewController alloc]initWithNibName:@"InviteCodeViewController" bundle:nil];
           
            invitecode.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:invitecode animated:YES];
        }
    }
    if (indexPath.row==2){
        //历史阅读
        CollectionController *collection=[[CollectionController alloc]initWithNibName:@"CollectionController" bundle:nil];
       
        
        collection.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:collection animated:YES];
    }
    if (indexPath.row==3){
        //设置
        SettingViewController *setting=[[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
        
        setting.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:setting animated:YES];
    }if (indexPath.row==4) {
        //反馈
         [self _tryLogin];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)_tryLogin
{
    self.appKey = @"23356517";
    self.feedbackKit=[[YWFeedbackKit alloc]initWithAppKey:self.appKey];
    _feedbackKit.environment = self.environment;
    _feedbackKit.customUIPlist = @{@"bgColor":@"#00bfff"};
    
    [self _openFeedbackViewController];
}

- (void)_openFeedbackViewController
{
    __weak typeof(self) weakSelf = self;
    
    [_feedbackKit makeFeedbackViewControllerWithCompletionBlock:^(YWFeedbackViewController *viewController, NSError *error) {
        if ( viewController != nil ) {
            //#warning 这里可以设置你需要显示的标题
            viewController.title = @"反馈";
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
            nav.navigationBar.barTintColor=[UIColor colorWithRed:211/255.0f green:33/255.0f blue:33/255.0f alpha:1];
            
            [weakSelf presentViewController:nav animated:NO completion:nil];
            
            
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[[UIImage imageNamed:@"setting_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            btn.frame=CGRectMake(10, 5, 25, 25);
            [btn addTarget:self action:@selector(actionCleanMemory:) forControlEvents:UIControlEventTouchUpInside];
            
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
            
            __weak typeof(nav) weakNav = nav;
            
            [viewController setOpenURLBlock:^(NSString *aURLString, UIViewController *aParentController) {
                UIViewController *webVC = [[UIViewController alloc] initWithNibName:nil bundle:nil];
                UIWebView *webView = [[UIWebView alloc] initWithFrame:webVC.view.bounds];
                webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                
                [webVC.view addSubview:webView];
                [weakNav pushViewController:webVC animated:YES];
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aURLString]]];
            }];
        } else {
            NSString *title = [error.userInfo objectForKey:@"msg"]?:@"接口调用失败，请保持网络通畅！";
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:title description:nil
                                                                  type:TWMessageBarMessageTypeError];
        }
    }];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // 初始化
        self.environment = YWEnvironmentRelease;
        //#warning 这里设置你的AppKey
        self.appKey = @"23356517";
    }
    return self;
}
-(void)actionCleanMemory:(UIBarButtonItem *)BBI
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
