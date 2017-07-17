//
//  PersonModel.h
//  News
//
//  Created by ZZG on 16/6/2.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "JSONModel.h"

@interface PersonModel : JSONModel

@property (nonatomic ,copy)NSString  *headimgurl;
@property (nonatomic ,copy)NSString  *nickname;
@property (nonatomic ,copy)NSString  *member_id;
@property (nonatomic ,copy)NSString  *phone;
@property (nonatomic ,copy)NSString  *level;

@end
