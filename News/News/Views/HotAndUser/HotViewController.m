//
//  HotViewController.m
//  
//
//  Created by siyue on 16/5/23.
//
//

#import "HotViewController.h"
#import "newsViewController.h"
#import "TitleView.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface HotViewController ()<TitleCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ImgView;
@property (weak, nonatomic) IBOutlet UIButton *NewBtn;
@property (weak, nonatomic) IBOutlet UIView *Myview;
@property (nonatomic ,copy)NSString *url;
@property (weak, nonatomic) IBOutlet UIButton *ShareBtn;
@property (weak, nonatomic) IBOutlet UIButton *ReadingBtn;
@property (weak, nonatomic) IBOutlet UIButton *earningsBtn;
@property (weak, nonatomic) IBOutlet UIView *View1;
@property (weak, nonatomic) IBOutlet UIView *View2;
@property (weak, nonatomic) IBOutlet UIView *View3;

@property (nonatomic ,strong)newsViewController *newview;
@property (nonatomic ,strong)TitleView *titleView;
@property (nonatomic ,strong)NSArray  *urlStrings;

//记录是点击的是哪一个Title
@property (nonatomic ,copy)NSString *titleName;

//线条约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WidthLayout3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeigheLayout;


@property (nonatomic ,strong)UIView *transparentView;
@end

static int number=1;

@implementation HotViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleName=@"全部";
}
-(void)viewWillAppear:(BOOL)animated
{
    //设置线条宽度
    self.WidthLayout1.constant=0.5;
    self.WidthLayout2.constant=0.5;
    self.WidthLayout3.constant=0.5;
    self.HeigheLayout.constant=0.5;
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.ImgView.image=[UIImage imageNamed:@"rank_arrow_down"];
    [self.NewBtn setTitle:[NSString stringWithFormat:@"%@",self.titleName] forState:UIControlStateNormal];
    self.View1.hidden=NO;
    self.View2.hidden=NO;
    self.View3.hidden=NO;
    for (UIView *Myview in self.Myview.subviews) {
        for (UIButton *button in Myview.subviews) {
            button.hidden=NO;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    self.url=@"http://wz.lefei.com/Api/ApiV2/articleLists?order_type=2";
    [self createUI];
}

-(void)createUI
{
    self.newview=[[newsViewController alloc]initWithNibName:@"newsViewController" bundle:nil];
    self.newview.FoundVCnumber=19;
    self.newview.urlString=self.url;
    self.newview.view.frame=CGRectMake(0, 40.5, kScreenWidth, self.view.frame.size.height-40.5);
    
    [self addChildViewController:self.newview];
    [self.view addSubview:self.newview.view];
}

- (IBAction)BtnCLicked:(UIButton *)sender {
    if (sender.tag==10){
        self.titleView.hidden=NO;
        number++;
        if (number%2==0) {
            [self createView];
            
            self.titleView.frame=CGRectMake(0, -200, kScreenWidth, 200);
            [self.view bringSubviewToFront:self.Myview] ;
            [UIView transitionWithView:self.titleView duration:0.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.titleView.frame=CGRectMake(0, 40.5, kScreenWidth, 200);
            } completion:^(BOOL finished) {
                self.transparentView.hidden=NO;
            }];
            
            self.ImgView.image=[UIImage imageNamed:@"rank_arrow_up"];
            [self.NewBtn setTitle:@"收起          " forState:UIControlStateNormal];
            
            
            self.View1.hidden=YES;
            self.View2.hidden=YES;
            self.View3.hidden=YES;
            for (UIView *Myview in self.Myview.subviews) {
                for (UIButton *button in Myview.subviews) {
                    if (button.tag!=10) {
                        
                        button.hidden=YES;
                    }
                }
            }
            
            self.ImgView.hidden=NO;
        }else {
            
            [UIView transitionWithView:self.titleView duration:0.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.titleView.frame=CGRectMake(0, -200, kScreenWidth, 200);
            } completion:^(BOOL finished) {
                //隐藏HotView
                self.titleView.hidden=YES;
                self.transparentView.hidden=YES;
            }];
            
            if (self.titleName.length==0) {
                self.titleName=@"全部         ";
            }
        [self.NewBtn setTitle:self.titleName forState:UIControlStateNormal];
        
            self.View1.hidden=NO;
            self.View2.hidden=NO;
            self.View3.hidden=NO;
        self.ImgView.image=[UIImage imageNamed:@"rank_arrow_down"];
            
            for (UIView *Myview in self.Myview.subviews) {
                for (UIButton *button in Myview.subviews) {
                    button.hidden=NO;
                }
            }
        }
    //点击分享阅读收益
    }else if (sender.tag==11){
         self.url=@"http://wz.lefei.com/Api/ApiV2/articleLists?order_type=1";
        [self.ShareBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.ReadingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.earningsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self createUI];
    }else if (sender.tag==12){
        self.url=@"http://wz.lefei.com/Api/ApiV2/articleLists?order_type=2";
        [self.ShareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.ReadingBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.earningsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self createUI];
    }else{
        self.url=@"http://wz.lefei.com/Api/ApiV2/articleLists?order_type=3";
        [self.ShareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.ReadingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.earningsBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self createUI];
    }
}
//添加一个透明的View
-(void)createView
{
    self.transparentView=[[UIView alloc]initWithFrame:self.newview.view.bounds];
    self.transparentView.backgroundColor=[UIColor clearColor];
    self.titleView =[[NSBundle mainBundle]loadNibNamed:@"TitleView" owner:self options:0][0];
    self.titleView.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.95];
    self.titleView.Delegate=self;
    [self.view addSubview:self.titleView];
    [self.Myview bringSubviewToFront:self.transparentView];
    [self.newview.view addSubview:self.transparentView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    number=1;
    [UIView transitionWithView:self.titleView duration:0.1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.titleView.frame=CGRectMake(0, -200, kScreenWidth, 200);
    } completion:^(BOOL finished) {
        //隐藏HotView
        self.titleView.hidden=YES;
        self.transparentView.hidden=YES;
    }];
    self.ImgView.image=[UIImage imageNamed:@"rank_arrow_down"];
    [self.NewBtn setTitle:[NSString stringWithFormat:@"%@",self.titleName] forState:UIControlStateNormal];
    
    self.View1.hidden=NO;
    self.View2.hidden=NO;
    self.View3.hidden=NO;
    for (UIView *Myview in self.Myview.subviews) {
        for (UIButton *button in Myview.subviews) {
            button.hidden=NO;
        }
    }
}
-(void)didSelectedCategorynum:(NSInteger)num AndTitle:(NSString *)title
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"IDPage" object:nil userInfo:@{@"index":@(1)}];
    number=1;
    self.ImgView.image=[UIImage imageNamed:@"rank_arrow_down"];
    self.View1.hidden=NO;
    self.View2.hidden=NO;
    self.View3.hidden=NO;
    for (UIView *Myview in self.Myview.subviews) {
        for (UIButton *button in Myview.subviews) {
            button.hidden=NO;
        }
    }

    self.url=self.urlStrings[num];

    [self.NewBtn setTitle:title forState:UIControlStateNormal];
    [self createUI];
    self.titleName=[NSString stringWithFormat:@"%@    ",title];
}
- (NSArray *)urlStrings
{
    if (_urlStrings == nil) {
        _urlStrings = @[@"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=0",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=1",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=2",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=3",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=4",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=5",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=6",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=7",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=10",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=11",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=12",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=13",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=14",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=15",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=16",
                        @"http://wz.lefei.com/?m=Api&c=ApiV2&a=articleLists&c_id=17"];
    }
    
    return _urlStrings;
}
@end
