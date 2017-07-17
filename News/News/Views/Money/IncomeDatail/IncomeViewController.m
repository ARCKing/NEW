//
//  IncomeViewController.m
//  News
//
//  Created by ZZG on 16/6/1.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "IncomeViewController.h"

#import "AFNetworking.h"
#import "ZGNetAPI.h"
#import "ZGManagerHUD.h"
#import "IncomeCell.h"
#import "Incomemodel.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface IncomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *IncomeBtn;
@property (weak, nonatomic) IBOutlet UITableView *MyTableView;

@property (nonatomic ,strong)NSDictionary *dict;

@property (weak, nonatomic) IBOutlet UIButton *SpeedingBtn;
@property (nonatomic ,strong)NSMutableArray *dataSource;


@property (nonatomic ,strong) UIImageView *iMGview;
@property (nonatomic ,strong)UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeightLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout;
@end

@implementation IncomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self Updata];
    
    [self.MyTableView registerNib:[UINib nibWithNibName:@"IncomeCell" bundle:nil] forCellReuseIdentifier:@"IncomeCell"];
     [ZGManagerHUD showHUDViewController:self.tabBarController];
    //线条变细
    self.MyTableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    self.HeightLayout.constant=0.5;
    self.WidthLayout.constant=0.5;
    
    //自适应高度
    self.MyTableView.estimatedRowHeight=44;
    self.MyTableView.rowHeight=UITableViewAutomaticDimension;
    
    //去除多余的Cell
    self.MyTableView.tableFooterView=[UIView new];
    
    
    UIView *Myview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    Myview.backgroundColor=[UIColor whiteColor];
    
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-75, 5, 150, 20)];
    label.text=@"只显示每月前两百条";
    label.font=[UIFont systemFontOfSize:15];
    label.textColor=[UIColor grayColor];
    
    [Myview addSubview:label];
    
    self.MyTableView.tableFooterView=Myview;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.dict=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"type":@(0)};
}
- (IBAction)BtnClicked:(UIButton *)sender {
    if (sender.tag==10) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (sender.tag==11){
        [ZGManagerHUD showHUDViewController:self.tabBarController];
    //收入
        [self.IncomeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         [self.SpeedingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        self.dict=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"type":@"收入"};
        [self Updata];
    }else if (sender.tag==12){
        [ZGManagerHUD showHUDViewController:self.tabBarController];
    //支出
        [self.IncomeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.SpeedingBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.dict=@{@"authcode":[[[NSUserDefaults standardUserDefaults]objectForKey:@"authcode"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"type":@"支出"};
         [self Updata];
    }
    
}

#pragma mark--UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IncomeCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"IncomeCell" forIndexPath:indexPath];
    Incomemodel *model=self.dataSource[indexPath.row];
    
    Cell.TitleLabel.text=model.text;
    Cell.timeLabel.text=model.time;
    Cell.moneyLabel.text=model.money;

    return Cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark--helper Methods



#pragma mark - Event Handlers

-(void)Updata
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];

    [manager POST:KURL_Income parameters:self.dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.dataSource removeAllObjects];
        
        
        for (NSDictionary *dict in responseObject[@"data"]) {
            Incomemodel *model=[[Incomemodel alloc]init];
            
            model.text=dict[@"text"];
            model.time=dict[@"time"];
            model.money=dict[@"money"];
            
            [self.dataSource addObject:model];
        }
        [self.MyTableView reloadData];
        [ZGManagerHUD hidesHUDComplection:nil];
        
        if (self.dataSource.count==0) {
            [self performSelector:@selector(createImage) withObject:nil afterDelay:1];
        }else{
            self.label.hidden=YES;
            self.iMGview.hidden=YES;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ZGManagerHUD hidesHUDComplection:nil];
    }];
}

-(void)createImage
{
    self.iMGview=[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-30, kScreenHeight/2-50, 60, 50)];
    self.iMGview.image=[[UIImage imageNamed:@"ic_no_data.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.view addSubview:self.iMGview];
    
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-50, kScreenHeight/2+10, 100, 30)];
    self.label.font=[UIFont systemFontOfSize:14];
    self.label.textColor=[UIColor grayColor];
    self.label.text=@"暂无记录";
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.label];
    
}

#pragma mark--Setter &Getter

-(NSMutableArray *)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
    }
    return _dataSource;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
