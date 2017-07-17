//
//  ZGPromptView.m
//  News
//
//  Created by ZZG on 16/6/7.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "ZGPromptView.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

@interface ZGPromptView ()

@property(nonatomic,strong)UILabel *label ;
@property(nonatomic,strong)UIImageView *imageView ;
@property (nonatomic ,strong)UILabel *WarningLabel;

@property(nonatomic,copy)id superView ;

@end
@implementation ZGPromptView

/**
 *  添加文字提示框
 *
 *  @param target     控件或者控制器
 *  @param textString 提示文字
 */
- (void)addToWithController:(id)target withString:(NSString *)textString
{
    
    self.backgroundColor =[UIColor grayColor];
    self.frame = CGRectMake(0, 0, 150, 100) ;
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0) ;
    self.layer.masksToBounds = YES ;
    self.layer.cornerRadius = 8 ;
    if([target isKindOfClass:[UIViewController class]])
    {
        __weak UIViewController *VC = target ;
        [VC.view addSubview:self] ;
    }
    else
    {
        __weak UIViewController *VC = [self viewController:target] ;
        [VC.view addSubview:self] ;
    }
    
    
    // 图片
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(55, 10, 40, 40)] ;
    _imageView.image = [UIImage imageNamed:@"ic_tishi"] ;
    [self addSubview:_imageView] ;
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 40)] ;
    [_label setTextAlignment:NSTextAlignmentCenter];
    _label.textColor = [UIColor whiteColor] ;
    _label.numberOfLines = 0 ;
    _label.text = textString ;
    _label.textAlignment = NSTextAlignmentCenter ;
    _label.layer.cornerRadius = 5 ;
    _label.layer.masksToBounds = YES ;
    _label.font = [UIFont systemFontOfSize:14] ;
    [self addSubview:_label] ;
    
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [UIView animateWithDuration:2 animations:^{
            self.alpha = 0 ;
        } completion:^(BOOL finished) {
            [self removeFromSuperview] ;
        }];
    });
    
}

/**
 *  添加文字提示框
 *
 *  @param target     控件或者控制器
 *  @param textString 提示文字
 */
- (void)addToWithController:(id)target withString:(NSString *)textString withImage:(UIImage *)image
{
    self.backgroundColor = [UIColor grayColor];
    self.frame = CGRectMake(0, 0, 150, 100);
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0) ;
    self.layer.masksToBounds = YES ;
    self.layer.cornerRadius = 8 ;
    if([target isKindOfClass:[UIViewController class]])
    {
        __weak UIViewController *VC = target ;
        [VC.view addSubview:self] ;
    }
    else
    {
        __weak UIViewController *VC = [self viewController:target] ;
        [VC.view addSubview:self] ;
    }
    
    
    // 图片
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(55, 10, 40, 40)] ;
    _imageView.image = image ;
    [self addSubview:_imageView] ;
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 40)] ;
    _label.textColor = [UIColor whiteColor] ;
    _label.numberOfLines = 0 ;
    _label.text = textString ;
    _label.textAlignment = NSTextAlignmentCenter ;
    _label.layer.cornerRadius = 5 ;
    _label.layer.masksToBounds = YES ;
    _label.font = [UIFont systemFontOfSize:14] ;
    [self addSubview:_label] ;
    
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [UIView animateWithDuration:2 animations:^{
            self.alpha = 0 ;
        } completion:^(BOOL finished) {
            [self removeFromSuperview] ;
        }];
    });
    
}

-(void)addToWithController:(id)target withLabel:(NSString *)title  AndHeight:(NSInteger)Height
{
    UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    CGRect tmpRect = [title boundingRectWithSize:CGSizeMake(kScreenWidth, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil] context:nil];
    
    self.backgroundColor = [UIColor grayColor];
    
    self.frame = CGRectMake(kScreenWidth/2-(tmpRect.size.width+20)/2, kScreenHeight-Height-44-50, tmpRect.size.width+20, 30);
    
    self.layer.masksToBounds = YES ;
    self.layer.cornerRadius = 5 ;
    if([target isKindOfClass:[UIViewController class]])
    {
        __weak UIViewController *VC = target ;
        [VC.view addSubview:self] ;
    }
    else
    {
        __weak UIViewController *VC = [self viewController:target] ;
        [VC.view addSubview:self] ;
    }
    self.WarningLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 3, tmpRect.size.width, 25)];
    [self.WarningLabel setTextAlignment:NSTextAlignmentCenter];
    self.WarningLabel.textColor=[UIColor whiteColor];
    self.WarningLabel.text=title;
    [self addSubview:self.WarningLabel];
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [UIView animateWithDuration:2 animations:^{
            self.alpha = 0 ;
        } completion:^(BOOL finished) {
            [self removeFromSuperview] ;
        }];
    });
    
}

-(void)addToWithController:(id)target
{
    self.backgroundColor = [UIColor colorWithRed:213/255.0 green:233/255.0 blue:246/255.0 alpha:0.99];
    self.frame = CGRectMake(0, -30, kScreenWidth, 30);

    if([target isKindOfClass:[UIViewController class]])
    {
        __weak UIViewController *VC = target ;
        [VC.view addSubview:self] ;
    }
    else
    {
        __weak UIViewController *VC = [self viewController:target] ;
        [VC.view addSubview:self] ;
    }
    self.WarningLabel=[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-60, 3, 120, 25)];
    [self.WarningLabel setTextAlignment:NSTextAlignmentCenter];
    self.WarningLabel.textColor=[UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1];
    self.WarningLabel.font=[UIFont systemFontOfSize:14];
    self.WarningLabel.text=@"数据更新完毕";
    [self addSubview:self.WarningLabel];
    
    
    [UIView animateWithDuration:0.7 animations:^{
        self.frame = CGRectMake(0, 0, kScreenWidth, 30);
    }];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            [UIView animateWithDuration:0.7 animations:^{
                self.frame = CGRectMake(0, -30, kScreenWidth, 30);
                
            } completion:^(BOOL finished) {
                [self removeFromSuperview] ;
            }];
        });
    });
    
   
}

-(void)sleep
{

}

- (UIViewController *)viewController:(UIView *)view
{
    
    UIResponder *responder = view;
    while ((responder = [responder nextResponder]))
    {
        if ([responder isKindOfClass: [UIViewController class]])
        {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

@end
