//
//  RecordViewController.m
//  News
//
//  Created by ZZG on 16/6/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "RecordViewController.h"

#import "MJRefresh.h"
#import "RecordModel.h"
#import "RecordCell.h"
#import "ZGNetAPI.h"
#import "AFNetworking.h"
#import "ZGManagerHUD.h"


static int page=1;

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)
@interface RecordViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *Mytableview;

@property (nonatomic ,strong)NSMutableArray *dataSource;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZGManagerHUD showHUDViewController:self.tabBarController];
    
    [self performSelector:@selector(UPdata) withObject:self afterDelay:0.2];
    
    self.Mytableview.hidden=YES;

    [self.Mytableview registerNib:[UINib nibWithNibName:@"RecordCell" bundle:nil] forCellReuseIdentifier:@"RecordCell"];
    //    自动计算Cell
    self.Mytableview.estimatedRowHeight=220;
    self.Mytableview.rowHeight=UITableViewAutomaticDimension;
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

#pragma mark--<#delegate#>

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"RecordCell" forIndexPath:indexPath];
    
    Cell.model=self.dataSource[indexPath.row];
     RecordModel *model=self.dataSource[indexPath.row];
    
    Cell.NameLabel.text=model.title;
    Cell.moneyLabel.text=model.price;
    Cell.timeLabel.text=model.time;
    Cell.titleLabel.text=model.desc;
    Cell.RefundLabel.textColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    Cell.typeImgView.image=[UIImage imageNamed:@"ic_money_back"];
    if ([model.type intValue]==1) {
       Cell.RefundLabel.textColor=[UIColor colorWithRed:231/255.0f green:194/255.0f blue:46/255.0f alpha:1];
       Cell.typeImgView.image=[UIImage imageNamed:@"ic_audit"];
    }
    Cell.RefundLabel.text=model.state;
    
    Cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return Cell;
}


#pragma mark--helper Methods
#pragma mark--Setter &Getter
#pragma mark - Event Handlers
-(void)UPdata
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];

    [manager POST:KURL_Record parameters:@{@"authcode":[[[NSUserDefaults standardUserDefaults] objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"p":@(page)} success:^(NSURLSessionDataTask *task, id responseObject) {
        [ZGManagerHUD hidesHUDComplection:nil];
        
        if (page==1) {
            [self.dataSource removeAllObjects];
        }
        for (NSDictionary *dict in responseObject[@"data"]) {
            RecordModel *model=[[RecordModel alloc]init];  
            model.title=dict[@"title"];
            model.desc=dict[@"desc"];
            model.price=dict[@"price"];
            model.time=dict[@"time"];
            model.state=dict[@"state"];
            model.bank_name=dict[@"bank_name"];
            model.type=dict[@"type"];
            [self.dataSource addObject:model];
        }
        if (self.dataSource.count==0) {
            [self performSelector:@selector(createImage) withObject:self afterDelay:0.2];
        }else{
            //有数据显示TableView
            self.Mytableview.hidden=NO;
        }
        [self.Mytableview reloadData];
        [self.Mytableview.mj_footer endRefreshingWithNoMoreData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
         [ZGManagerHUD hidesHUDComplection:nil];
        [self.Mytableview.mj_footer endRefreshingWithNoMoreData];
    }];
}
-(void)createImage
{
    UIImageView *iMGview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-30, kScreenHeight/2-50, 60, 50)];
    iMGview.image=[[UIImage imageNamed:@"ic_no_data.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.view addSubview:iMGview];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-50, kScreenHeight/2+10, 100, 30)];
    label.font=[UIFont systemFontOfSize:14];
    label.textColor=[UIColor grayColor];
    label.text=@"暂无提现记录";
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
}

-(NSMutableArray *)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
        
    }
    return _dataSource;
}

- (IBAction)ReturnBtn:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
