//
//  InvitationViewController.m
//  News
//
//  Created by ZZG on 16/6/1.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "InvitationViewController.h"
#import "MJRefresh.h"
#import "MJRefreshAutoFooter.h"


#import "MyInvitationModel.h"
#import "MyinVitationCell.h"

#import "UIImageView+WebCache.h"
#import "ZGManagerHUD.h"
#import "AFNetworking.h"
#import "ZGNetAPI.h"
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

static int page;

@interface InvitationViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)NSMutableArray *datasource;
@property (weak, nonatomic) IBOutlet UITableView *Mytableview;

@end

@implementation InvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.Mytableview registerNib:[UINib nibWithNibName:@"MyinVitationCell" bundle:nil] forCellReuseIdentifier:@"MyinVitationCell"];
    self.Mytableview.separatorColor=[UIColor groupTableViewBackgroundColor];
    page=1;
    //去掉多余的Cell
    self.Mytableview.tableFooterView=[UIView new];
    
    [ZGManagerHUD showHUDViewController:self.tabBarController];
    
    [self UPdata];
    [self createFoot];
}
-(void)createFoot
{
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.Mytableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //页码++ ,再次请求数据
        page ++;
        [self UPdata];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.Mytableview.hidden=YES;
}
#pragma mark - Event Handlers

-(void)UPdata
{
    
    NSString *str=[NSString stringWithFormat:@"http://wz.lefei.com/Api/Integral/getMyFriend?authcode=%@&p=%d",[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],page];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager GET:str parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (page==1) {
           [self.datasource removeAllObjects];
        }
        
        NSArray *dataArr=responseObject[@"data"];
        if (dataArr.count==0) {
            [self.Mytableview.mj_footer endRefreshingWithNoMoreData];
            return ;
        }
        
        for (NSDictionary *dict in responseObject[@"data"]) {
            
            MyInvitationModel *model=[[MyInvitationModel alloc]init];
            model.avatar=dict[@"avatar"];
           
            model.nickname=dict[@"nickname"];
            model.addtime=dict[@"addtime"];
            model.desc=dict[@"desc"];
            model.residue_money=dict[@"residue_money"];
            model.is_inviter_re=dict[@"is_inviter_re"];
            [self.datasource addObject:model];
        }
        if (self.datasource.count==0) {
            [self performSelector:@selector(createImage) withObject:self afterDelay:0.2];
        }else{
            self.Mytableview.hidden=NO;
        }
        
        [self.Mytableview reloadData];
        [self.Mytableview.mj_footer endRefreshing];
        
        [ZGManagerHUD hidesHUDComplection:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.Mytableview.mj_footer endRefreshing];
        [ZGManagerHUD hidesHUDComplection:nil];
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyinVitationCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"MyinVitationCell" forIndexPath:indexPath];
    
    MyInvitationModel *model=self.datasource[indexPath.row];
    
    Cell.NikeLabel.text=model.nickname;
    Cell.TimeLabel.text=model.addtime;
    Cell.MoneyLabel.text=model.residue_money;
     Cell.RewardLabel.textColor=[UIColor colorWithRed:238/255.0f green:50/255.0f blue:63/255.0f alpha:1];
    if ([model.is_inviter_re intValue]==1) {
         Cell.RewardLabel.textColor=[UIColor colorWithRed:52/255.0f green:185/255.0f blue:153/255.0f alpha:1];
    }
    
    Cell.RewardLabel.text=model.desc;
    [Cell.ImgView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"headicon_default"]];
    return Cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//当没有数据的时候显示图片
-(void)createImage
{
    UIImageView *iMGview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-30, kScreenHeight/2-50, 60, 50)];
    iMGview.image=[[UIImage imageNamed:@"ic_no_data.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.view addSubview:iMGview];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-40, kScreenHeight/2+10, 80, 30)];
    label.font=[UIFont systemFontOfSize:14];
    label.textColor=[UIColor grayColor];
    label.text=@"暂无好友";
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
}

#pragma mark - Event Handlers

- (IBAction)ReturnBtnClicked:(UIButton *)sender {    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark--Setter &Getter

-(NSMutableArray *)datasource
{
    if (_datasource==nil) {
        _datasource=[[NSMutableArray alloc]init];
    }
    return _datasource;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
