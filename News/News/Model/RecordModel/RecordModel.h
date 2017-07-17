//
//  RecordModel.h
//  News
//
//  Created by ZZG on 16/6/22.
//  Copyright © 2016年 siyue. All rights reserved.
//

#import "JSONModel.h"

@interface RecordModel : JSONModel

@property (nonatomic ,copy)NSString *desc;
@property (nonatomic ,copy)NSString *price;
@property (nonatomic ,copy)NSString *time;
@property (nonatomic ,copy)NSString *title;
@property (nonatomic ,copy)NSString *state;
@property (nonatomic ,copy)NSString *bank_name;

@property (nonatomic ,copy)NSString *type;

@end
