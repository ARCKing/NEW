//
//  MyInvitationModel.h
//  News
//
//  Created by ZZG on 16/6/8.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "JSONModel.h"

@interface MyInvitationModel : JSONModel


@property (nonatomic ,copy)NSString *addtime;
@property (nonatomic ,copy)NSString *avatar;
@property (nonatomic ,copy)NSString *desc;
@property (nonatomic ,copy)NSString *is_inviter_re;
@property (nonatomic ,copy)NSString *nickname;
@property (nonatomic ,copy)NSString *residue_money;
@end
