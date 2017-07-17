//
//  FoundViewController.m
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "FoundViewController.h"
#import "newsViewController.h"
#import "SearchhistoryManager.h"
#import "SecordHistoryModel.h"
#import "ZGPromptView.h"
#import "SearchHistoryCell.h"
#import "ZGManagerHUD.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface FoundViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong ) UITextField *TextF;
//搜索按钮
@property (nonatomic ,strong ) UIButton *foundBtn;
//X按钮
@property (nonatomic ,strong ) UIButton *ClearBtn;

@property (nonatomic ,strong)newsViewController *NewVC;

@property (nonatomic ,strong)NSMutableArray *DataSource;
@property (nonatomic ,strong)NSMutableArray *Arr;
@property (weak, nonatomic) IBOutlet UITableView *MyTableView;

@end

@implementation FoundViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.TextF becomeFirstResponder];
    
    //界面
    [self createUI];
    
    //初始化Cell
    [self createCell];
}

-(void)createCell
{
    [self.MyTableView registerNib:[UINib nibWithNibName:@"SearchHistoryCell" bundle:nil] forCellReuseIdentifier:@"SearchHistoryCell"];
    self.MyTableView.contentInset=UIEdgeInsetsMake(44, 0, 0, 0);
    self.MyTableView.separatorColor=[UIColor groupTableViewBackgroundColor];
    
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    view.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(8, 5, 100, 20)];
    label.text=@"搜索记录";
    label.textColor=[UIColor grayColor];
    label.font=[UIFont systemFontOfSize:14];
    [view addSubview:label];
    self.MyTableView.tableHeaderView=view;
    
    UIButton *cleatebutton=[UIButton buttonWithType:UIButtonTypeCustom];
    cleatebutton.frame=CGRectMake(0, 0, kScreenWidth, 30);
    cleatebutton.backgroundColor=[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    [cleatebutton addTarget:self action:@selector(ClearManager:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-60, 5, 120, 20)];
    titleLabel.text=@"清空历史记录";
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.font=[UIFont systemFontOfSize:14];
    
    [cleatebutton addSubview:titleLabel];
    self.MyTableView.tableFooterView=cleatebutton;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboard) name:@"keyboard" object:nil];
    
    //从数据库中查找
    [self Finddatabase];
    
}
-(void)keyboard
{
    [self.TextF resignFirstResponder];
}
#pragma mark - Event Handlers

-(void)Finddatabase
{
    [self.DataSource removeAllObjects];
    SearchhistoryManager *manager=[SearchhistoryManager shareManager];
    // FMResultSet结果集，用来表示查询到的数据
    FMResultSet *rs = [manager.SearchHistoryDataBase executeQuery:@"select * from SearchHistory"];
    
    // 遍历结果集，next让结果集的指针指向下一条记录(下一行数据)，如果有数据，就返回YES，没有数据，就返回NO
    while ([rs next]) {
        
        SecordHistoryModel *model=[[SecordHistoryModel alloc]init];
        
        // stringForColumn 取到当前指针指向的记录中，对应的字段的值，把取出来的值转成String
        model.title=[rs stringForColumn:@"title"];
        model.URlstr=[rs stringForColumn:@"URlstr"];
        
        [self.DataSource addObject:model];
    }
    if (self.DataSource.count==0) {
        self.MyTableView.hidden=YES;
    }else{
        self.MyTableView.hidden=NO;
    }
    
    [self.MyTableView reloadData];
}

#pragma mark--UITableViewDelegate,UITableViewDataSource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DataSource.count;
}

-(void)ClearManager:(UIButton *)btn
{
    SearchhistoryManager *manager=[SearchhistoryManager shareManager];
    // 清空数据库
    NSString *str=@"DELETE FROM SearchHistory";
    
    if ([manager.SearchHistoryDataBase executeUpdate:str]) {
        
        self.MyTableView.hidden=YES;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchHistoryCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"SearchHistoryCell" forIndexPath:indexPath];
    
    SecordHistoryModel *model=self.DataSource[indexPath.row];
    
    Cell.TitleLabel.text=model.title;
    
    Cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.MyTableView.hidden=YES;
   
    [ZGManagerHUD showHUDwithMessage:@"正在搜索" inViewController:self.tabBarController];
    
    SecordHistoryModel *model=self.DataSource[indexPath.row];
    self.TextF.text=model.title;
    
    self.NewVC=[[newsViewController alloc]initWithNibName:@"newsViewController" bundle:nil];
    self.NewVC.urlString=model.URlstr;
    self.NewVC.FoundVCnumber=18;
    self.NewVC.view.frame=CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-44);
    
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.7*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [ZGManagerHUD hidesHUDComplection:nil];
    });
    [self addChildViewController:self.NewVC];
    [self.view addSubview:self.NewVC.view];
    [self.NewVC.view bringSubviewToFront:self.view];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        SecordHistoryModel *model=self.DataSource[indexPath.row];
        
        NSString *str=[NSString stringWithFormat:@"DELETE FROM SearchHistory WHERE title ='%@'",model.title];
        SearchhistoryManager *manager=[SearchhistoryManager shareManager];
        if ([manager.SearchHistoryDataBase executeUpdate:str]) {
            
          
        }
        
        [self.DataSource removeObjectAtIndex:indexPath.row];
        [self.MyTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (self.DataSource.count==0) {
            self.MyTableView.hidden=YES;
        }
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //滑动隐藏UITextField
    [self.TextF resignFirstResponder];
}


//搭载界面
-(void)createUI
{
    
    UIView *view=[[UIView alloc ]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
   view.backgroundColor=[UIColor colorWithRed:211/255.0f green:76/255.0f blue:74/255.0f alpha:1];
    [self.view addSubview:view];
    
    self.TextF=[[UITextField alloc]initWithFrame:CGRectMake(10, 25, kScreenWidth-80, 30)];
    self.TextF.borderStyle=UITextBorderStyleRoundedRect;
    self.TextF.backgroundColor=[UIColor whiteColor];
    self.TextF.delegate=self;
    self.TextF.placeholder=@"搜索你感兴趣的内容";
    self.TextF.font=[UIFont systemFontOfSize:14];
    self.TextF.keyboardType=UIKeyboardTypeWebSearch;
    [view addSubview:self.TextF];
    
    
    self.foundBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.foundBtn.frame=CGRectMake(kScreenWidth-60, 25, 50, 30);
    self.foundBtn.tag=10;
    [self.foundBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [self.foundBtn addTarget:self action:@selector(foundBtn:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.foundBtn];
    

    self.ClearBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.ClearBtn.frame=CGRectMake(kScreenWidth-99, 30, 23, 23);
    [self.ClearBtn setImage:[UIImage imageNamed:@"ic_clear"] forState:UIControlStateNormal];
    [self.ClearBtn addTarget:self action:@selector(ClearBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.ClearBtn];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.TextF resignFirstResponder];
    //根据输入框里面的内容搜索
    [self SearchData];
    
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     [self.TextF resignFirstResponder];
}

-(void)foundBtn:(UIButton *)btn{
    [self.TextF resignFirstResponder];

    //根据输入框里面的内容搜索
    [self SearchData];
}
-(void)SearchData
{

    
    if (self.TextF.text.length!=0) {
        [ZGManagerHUD showHUDwithMessage:@"正在搜索" inViewController:self];
        
        self.MyTableView.hidden=YES;
        self.NewVC.view.hidden=YES;
        
        self.NewVC=[[newsViewController alloc]initWithNibName:@"newsViewController" bundle:nil];
        self.NewVC.urlString=[[NSString stringWithFormat:@"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&key=%@",self.TextF.text]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.NewVC.FoundVCnumber=18;
        self.NewVC.view.frame=CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-44);
        
        [self addChildViewController:self.NewVC];
        [self.view addSubview:self.NewVC.view];
        [self.NewVC.view bringSubviewToFront:self.view];
        
        SecordHistoryModel *model=[[SecordHistoryModel alloc]init];
        model.URlstr=self.NewVC.urlString;
        model.title=self.TextF.text;
        
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.7*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
        [ZGManagerHUD hidesHUDComplection:nil];
        });
        
        SearchhistoryManager *manager=[SearchhistoryManager shareManager];
        // FMResultSet结果集，用来表示查询到的数据
        FMResultSet *rs = [manager.SearchHistoryDataBase executeQuery:@"select * from SearchHistory"];
        
        // 遍历结果集，next让结果集的指针指向下一条记录(下一行数据)，如果有数据，就返回YES，没有数据，就返回NO
        while ([rs next]) {
            // stringForColumn 取到当前指针指向的记录中，对应的字段的值，把取出来的值转成String
            NSString *sidStr=[rs stringForColumn:@"title"];
            
            [self.Arr addObject:sidStr];
        }
        for (NSString *titlestr in self.Arr) {
            if ([titlestr isEqualToString:self.TextF.text]) {
                //如果搜索过就不要添加进去
                return;
            }
        }
        //插入数据
        if(! [manager.SearchHistoryDataBase executeUpdate:@"insert into SearchHistory (URlstr,title) values(?,?)",model.URlstr
              ,model.title])
        {
            NSLog(@"数据插入失败");
        }
    }else{
        ZGPromptView  *prompView =[ZGPromptView new] ;
        [prompView addToWithController:self withString:@"请输入搜索内容"];
    }
}

-(NSMutableArray *)DataSource
{
    if (_DataSource==nil) {
        _DataSource=[[NSMutableArray alloc]init];
    }
    return _DataSource;
}
-(NSMutableArray *)Arr
{
    if (_Arr==nil) {
        _Arr=[[NSMutableArray alloc]init];
    }
    return _Arr;
}

-(void)ClearBtn:(UIButton *)btn{
    [self.TextF resignFirstResponder];
    self.TextF.text=@"";
    self.NewVC.view.hidden=YES;
    self.MyTableView.hidden=NO;
    //将刚刚搜索过的加入数据库
    [self Finddatabase];
}
@end
