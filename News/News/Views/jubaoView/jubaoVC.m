//
//  jubaoVC.m
//  News
//
//  Created by ZZG on 16/7/16.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "jubaoVC.h"
#import "jubaoCell.h"
#import "AFNetworking.h"
#import "ZGPromptView.h"

static NSInteger number=0;

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface jubaoVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *MytableView;
@property (nonatomic ,copy)NSString *Title;
@property (nonatomic ,strong)NSArray *DataSource;
@end

@implementation jubaoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self createHeadView];
    [self createFootView];
    [self.MytableView registerNib:[UINib nibWithNibName:@"jubaoCell" bundle:nil] forCellReuseIdentifier:@"jubaoCell"];
    self.MytableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    
}
-(void)createHeadView
{
    UIView *View=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    View.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(16, 10, kScreenWidth-10, 20)];
    label.text=@"选择举报原因";
    label.textColor=[UIColor grayColor];
    label.font=[UIFont systemFontOfSize:14];
    
    [View addSubview:label];
    
    self.MytableView.tableHeaderView=View;
    
}

-(void)createFootView
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    view.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    
    NSArray *titleArr=@[@"如果内容侵犯了您的其他合法权益,请登录",@"http://wz.lefei.com/api/video/jb投诉"];
    for (int i=0; i<2; i++) {
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(8, 10+20*i, kScreenWidth-10, 20)];
        label.text=titleArr[i];
        label.textColor=[UIColor grayColor];
        label.font=[UIFont systemFontOfSize:12];
        
        [view addSubview:label];
    }
    
    
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(50, 60, kScreenWidth-100, 40);
    [button addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    button.layer.cornerRadius=5;
    button.layer.masksToBounds=YES;
    [view addSubview:button];
    self.MytableView.tableFooterView=view;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.DataSource=@[@"广告",@"重复",@"标题夸张",@"色情低俗",@"播放不了",@"视频播放卡顿",@"视频声音和画面不同步，视频无声音",@"内容不完整",@"内容质量差",@"仇恨.暴力等令人反感的内容"];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    jubaoCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"jubaoCell" forIndexPath:indexPath];
    

    if (indexPath.row!=number) {
        Cell.TitleLabel.textColor=[UIColor grayColor];
        Cell.ImgView.image=[UIImage imageNamed:@"noselected"];
    }
    Cell.TitleLabel.text=self.DataSource[indexPath.row];
    Cell.selectionStyle=UITableViewCellStyleDefault;
    return Cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    jubaoCell *Cell=[self.MytableView cellForRowAtIndexPath:indexPath];
    Cell.TitleLabel.textColor=[UIColor redColor];
    Cell.ImgView.image=[UIImage imageNamed:@"selected"];
    number=indexPath.row;
    [self.MytableView reloadData];
    
    self.Title=self.DataSource[indexPath.row];
}

-(void)BtnClicked:(UIButton *)btn
{
    
    if (self.Title.length==0) {
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"请选择举报原因" withImage:[UIImage imageNamed:@"cuowu"]];
    }else{
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        [manager POST:@"http://wz.lefei.com/api/video/jb" parameters:@{@"ID":self.video_id,@"desc":self.Title} success:^(NSURLSessionDataTask *task, id responseObject) {
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:responseObject[@"message"] withImage:[UIImage imageNamed:@"zhengque"]];
    
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        }];
    }
}

- (IBAction)btn:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
