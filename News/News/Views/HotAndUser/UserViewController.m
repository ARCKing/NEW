//
//  UserViewController.m
//  
//
//  Created by siyue on 16/5/23.
//
//

#import "UserViewController.h"

#import "AFNetworking.h"
#import "UserCell.h"
#import "UIImageView+WebCache.h"
#import "ZGManagerHUD.h"

@interface UserViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;
@property (weak, nonatomic) IBOutlet UIButton *Wbtn;
@property (weak, nonatomic) IBOutlet UIButton *Mbtn;
@property (weak, nonatomic) IBOutlet UIButton *totalBtn;
@property (weak, nonatomic) IBOutlet UITableView *Mytableview;


//线条约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeigheLayout;


@property (nonatomic ,copy)NSString *url;

@property (nonatomic ,strong )NSMutableArray *dataSource;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
     [self.Mytableview registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
    //默认为月榜
    self.url=@"http://wz.lefei.com/Api/Ban/getMemberBan?order_type=3";
    [self createData];
}

//视图即将加载
-(void)viewWillAppear:(BOOL)animated
{
   
    [super viewWillAppear:animated];
    //设置线条宽度
    self.WidthLayout1.constant=0.5;
    self.WidthLayout2.constant=0.5;
    self.WidthLayout3.constant=0.5;
    self.HeigheLayout.constant=0.5;
}

- (IBAction)BtnClicked:(UIButton *)sender {
    
    [ZGManagerHUD showHUDViewController:self.tabBarController];
    
    self.url=[NSString stringWithFormat:@"http://wz.lefei.com/Api/Ban/getMemberBan?order_type=%ld",sender.tag-9];
    if (sender.tag==10) {
        
        [self.dayBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.Wbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.Mbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.totalBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else if (sender.tag==11){
        
        [self.dayBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.Wbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.Mbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.totalBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else if (sender.tag==12){
        
        [self.dayBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.Wbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.Mbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.totalBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else{
        [self.dayBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.Wbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.Mbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.totalBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    [self createData];
    
}
//创建数据
-(void)createData
{
   AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@",self.url] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.dataSource=responseObject[@"data"];
        [self.Mytableview reloadData];
        [ZGManagerHUD hidesHUDComplection:nil];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
       [ZGManagerHUD hidesHUDComplection:nil];
    }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    NSDictionary *dict=self.dataSource[indexPath.row];
    
    Cell.NumberLabel.textColor=[UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1];
    
    if ([dict[@"num"] intValue]==1) {
        Cell.NumberLabel.textColor=[UIColor redColor];
    }else if ([dict[@"num"] intValue]==2){
        Cell.NumberLabel.textColor=[UIColor purpleColor];
    }else if ([dict[@"num"] intValue]==3){
        Cell.NumberLabel.textColor=[UIColor orangeColor];
    }
    
    Cell.NumberLabel.text=[NSString stringWithFormat:@"%@",dict[@"num"]];
    
    Cell.NameLabel.text=dict[@"nickname"];
    [Cell.ImgView sd_setImageWithURL:[NSURL URLWithString:dict[@"avatar"]] placeholderImage:[UIImage imageNamed:@"headicon_default"]];
    
    

    Cell.jifenLabel.text=dict[@"jifen"];
    Cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return Cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSMutableArray *)dataSource
{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
    }
    return _dataSource;
}
@end
