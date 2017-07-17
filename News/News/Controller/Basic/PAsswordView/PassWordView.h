//
//  PassWordView.h
//  News
//
//  Created by ZZG on 16/5/30.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassWordView : UIView
@property (weak, nonatomic) IBOutlet UITextField *OldPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *NewPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *NewPassword2TF;
@property (weak, nonatomic) IBOutlet UIButton *UpdataBtn;

@end
