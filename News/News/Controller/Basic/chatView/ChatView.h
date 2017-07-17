//
//  ChatView.h
//  News
//
//  Created by ZZG on 16/7/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatView : UIView
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@property (weak, nonatomic) IBOutlet UITextView *MYTextView;


@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *publishedBtn;


@end
