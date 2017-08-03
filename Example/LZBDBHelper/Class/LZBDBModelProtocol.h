//
//  LZBDBModelProtocol.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

@protocol LZBDBModelProtocol <NSObject>


@required
/**
 设置主键
 @return 主键信息
 */
+ (NSString *)model_getPrimaryKey;


@optional
/**
 设置忽略字段名称数组
 
 @return 忽略字段数组
 */
+ (NSArray *)model_ignoreColumnNames;

/**
 设置更改字典的名称   新的字段：旧的字段
 
 @return 更改字段字典
 */
+ (NSDictionary *)model_newNameMapToOldNameDictionary;

@end
