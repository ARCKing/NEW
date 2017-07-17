//
//  ChatView.m
//  News
//
//  Created by ZZG on 16/7/6.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "ChatView.h"

@implementation ChatView

- (void)drawRect:(CGRect)rect {

    self.MYTextView.layer.borderColor=[UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1].CGColor;
    self.MYTextView.layer.borderWidth=0.5;
    self.MYTextView.layer.cornerRadius=0;
    self.MYTextView.layer.masksToBounds=YES;
    
    
    self.cancelBtn.layer.cornerRadius=5;
    self.cancelBtn.layer.masksToBounds=YES;
    
    self.publishedBtn.layer.cornerRadius=5;
    self.publishedBtn.layer.masksToBounds=YES;
}


@end
