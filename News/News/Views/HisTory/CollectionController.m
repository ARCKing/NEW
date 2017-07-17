//
//  CollectionController.m
//  
//
//  Created by siyue on 16/5/25.
//
//

#import "CollectionController.h"
#import "CollectionCell.h"
#import "DetailsViewController.h"
#import "HistoryManager.h"
#import "ZGPromptView.h"
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)
//记录数组是否为空
static int number=1;

@interface CollectionController ()


@property (nonatomic ,strong)HistoryManager *manager;


//存放数据库中提取出来的数据
@property (nonatomic , strong) NSMutableArray *TitleArr;
@property (nonatomic , strong) NSMutableArray *DetailIDArr;

@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UIButton *btn;
@property (nonatomic,strong)UIButton *btn1;
@property (nonatomic,strong)UIButton *btn2;


@property (nonatomic ,copy)NSString *Title;
@property (nonatomic ,copy)NSString *DetailID;

@property (weak, nonatomic) IBOutlet UITableView *MyTableView;
@end

@implementation CollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;

    [self.MyTableView registerNib:[UINib nibWithNibName:@"CollectionCell" bundle:nil] forCellReuseIdentifier:@"CollectionCell"];
    
    self.MyTableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    //去除多余的Cell
    self.MyTableView.tableFooterView=[UIView new];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden=YES;
}
- (IBAction)BtnClicked:(UIButton *)sender {
    if (sender.tag==10) {
        //返回按钮
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        
        if (self.TitleArr.count==0||number==0) {
            ZGPromptView *prompView =[ZGPromptView new] ;
            [prompView addToWithController:self withString:@"暂无记录"] ;
        }else{
            //清除记录
            UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"温馨提示" message:@"你确定要清空历史记录吗？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *Cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // 取消清空数据库
            }];
            UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // 清空数据库
                NSString *str=@"DELETE FROM history";
                
                if ([self.manager.HistoryDataBase executeUpdate:str]) {
                    
                    self.MyTableView.hidden=YES;
                    number=0;
                }
            }];
            [alertController addAction:Cancel];
            [alertController addAction:confirm];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

//将数据库中的数据读取出来
-(void)viewDidAppear:(BOOL)animated
{
    [self.TitleArr removeAllObjects];
    [self.DetailIDArr removeAllObjects];
    
    //读取，查询
    self.manager=[HistoryManager shareManager];
    FMResultSet *rs=[self.manager.HistoryDataBase executeQuery:@"select * from history"];
    
    //遍历查询的结果  用模型装起来
    while ([rs next]) {
        
        self.Title=[rs stringForColumn:@"title"];
        self.DetailID=[rs stringForColumn:@"HistoryID"];
        
        [self.DetailIDArr addObject:self.DetailID];
        [self.TitleArr addObject:self.Title];
    }
    
    [self.MyTableView reloadData];
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
//跳转到详情页
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DetailsViewController *detail=[[DetailsViewController alloc]init];
    detail.DetailID=self.DetailIDArr[indexPath.row];
    detail.Title=self.TitleArr[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
