//
//  HistoryViewController.m
//  News
//
//  Created by HPmac on 16/5/24.
//  Copyright © 2016年 siyue. All rights reserved.
//


        /*收藏    CollectionManager数据库    HistoryViewController页面*/

#import "HistoryViewController.h"
#import "CollectionManager.h"
#import "CollectionCell.h"
#import "DetailsViewController.h"
#import "ZGPromptView.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

//记录数组是否为空
static int number=1;

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *Mytableview;
@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UIButton *btn;
@property (nonatomic,strong)UIButton *btn1;
@property (nonatomic ,copy)NSString *Title;
@property (nonatomic ,copy)NSString *DetailID;
@property (nonatomic , strong) NSMutableArray *TitleArr;
@property (nonatomic , strong) NSMutableArray *DetailIDArr;

//数据库
@property (nonatomic ,strong)CollectionManager *manager;
//阴影效果
@property (nonatomic ,strong)UIView *Myview;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    [self.Mytableview registerNib:[UINib nibWithNibName:@"CollectionCell" bundle:nil] forCellReuseIdentifier:@"CollectionCell"];
    
    self.Mytableview.separatorColor=[UIColor groupTableViewBackgroundColor];
    //去除多余的Cell
    self.Mytableview.tableFooterView=[UIView new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=YES;
}


- (IBAction)BtnClicked:(UIButton *)sender {
    
    if (sender.tag==10) {
        //返回按钮
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        
        if (self.TitleArr.count==0||number==0) {
            
            ZGPromptView *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"暂无收藏"] ;
        }else{
            
            //清除记录
            UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"温馨提示" message:@"你确定要清空收藏列表吗？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *Cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // 取消清空数据库
            }];
            
            UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // 清空数据库
                // 清空数据库
                NSString *str=@"DELETE FROM Collection";
                
                if ([self.manager.CollectionDataBase executeUpdate:str]) {
                    
                    self.Mytableview.hidden=YES;
                    number=0;
                }
            }];
            [alertController addAction:Cancel];
            [alertController addAction:confirm];
            [self presentViewController:alertController animated:YES completion:nil];    }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.TitleArr removeAllObjects];
    [self.DetailIDArr removeAllObjects];
    
    //读取，查询
    self.manager=[CollectionManager shareManager];
    
    FMResultSet *rs=[self.manager.CollectionDataBase executeQuery:@"select * from Collection"];
    
    //遍历查询的结果  用模型装起来
    while ([rs next]) {
        
        self.Title=[rs stringForColumn:@"title"];
        self.DetailID=[rs stringForColumn:@"renwuID"];
        [self.DetailIDArr addObject:self.DetailID];
        [self.TitleArr addObject:self.Title];
    }
    
    [self.Mytableview reloadData];
    if (self.TitleArr.count!=0) {
        number=1;
    }
    
    
}

#pragma makr--UITableViewDataSource,UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.TitleArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    Cell.TitleLabel.text=self.TitleArr[indexPath.row];
    
    //选中Cell的样式
    Cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return Cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到详情页
    DetailsViewController *detail=[[DetailsViewController alloc]init];
    detail.DetailID=self.DetailIDArr[indexPath.row];
    detail.Title=self.TitleArr[indexPath.row];
    
    
    [self.navigationController pushViewController:detail animated:YES];
    
}





//点击屏幕任意位置隐藏提示框
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.Myview.hidden=YES;
}

#pragma mark--getter&setter

-(NSMutableArray *)TitleArr
{
    if (_TitleArr==nil) {
        _TitleArr=[[NSMutableArray alloc]init];
    }
    return _TitleArr;
}
-(NSMutableArray *)DetailIDArr
{
    if (_DetailIDArr==nil) {
        _DetailIDArr=[[NSMutableArray alloc]init];
    }
    return _DetailIDArr;
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
