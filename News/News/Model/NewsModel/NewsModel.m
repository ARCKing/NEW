//
//  NewsModel.m
//  
//
//  Created by siyue on 16/5/20.
//
//

#import "NewsModel.h"

@implementation NewsModel

//为了防止属性列表和返回的数据不对应而导致的崩溃
+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+(JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"NewsID"}];
}

@end
