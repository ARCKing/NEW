//
//  ZGPromptView.h
//  News
//
//  Created by ZZG on 16/6/7.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGPromptView : UIView


/**
 *  添加文字提示框
 *
 *  @param target     控件或者控制器
 *  @param textString 提示文字
 */
- (void)addToWithController:(id)target withString:(NSString *)textString ;

/**
 *  添加文字提示框
 *
 *  @param target     控件或者控制器
 *  @param textString 提示文字
 */
- (void)addToWithController:(id)target withString:(NSString *)textString withImage:(UIImage *)image ;


-(void)addToWithController:(id)target withLabel:(NSString *)title AndHeight:(NSInteger)Height;


-(void)addToWithController:(id)target;

@end
