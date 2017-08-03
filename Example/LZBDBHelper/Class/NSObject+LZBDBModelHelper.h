//
//  NSObject+LZBDBModelHelper.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//// 操作需要保存模型的方法集合

#import <Foundation/Foundation.h>

@interface NSObject (LZBDBModelHelper)
/**
 根据类名返回表的名称
 @return 表的名称
 */
+ (NSString *)db_getTabbleName;

/**
 根据类名返回临时表的名称
 @return 表的名称
 */
+ (NSString *)db_getTabbleTempName;

/**
 根据类返回成员变量的名称和成员变量的类型
 @return 字典 成员变量：成员变量类型
 */
+ (NSDictionary *)db_ClassIvarNameAndIvarTypeDict;

/**
 根据类返回成员变量的名称和映射到数据库的类型字典

 @return 字典 成员变量：数据库列变量类型
 */
+ (NSDictionary *)db_ClassIvarNameAndMapSqliteTypeDict;

/**
 根据类 返回成员变量的名称和映射到数据库的类型 的字符串
 @return   （数据库列名，数据库列类型）字符串
 */
+ (NSString *)db_ClassColumnNameAndMapSqliteTypeString;


/**
 根据类 返回排序后的成员变量字段数组
 @return 模型里面数组成员变量数组
 */
+ (NSArray *)db_ClassAllSortedIvarNames;
@end
