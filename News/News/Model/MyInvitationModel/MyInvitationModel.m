//
//  MyInvitationModel.m
//  News
//
//  Created by ZZG on 16/6/8.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "MyInvitationModel.h"

@implementation MyInvitationModel

//为了防止属性列表和返回的数据不对应而导致的崩溃
+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
