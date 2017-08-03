//
//  LZBSqliteTableTool.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//处理数据库的表

#import <Foundation/Foundation.h>

@interface LZBSqliteTableTool : NSObject

/**
 判断表是否存在
 
 @param cls 对应哪张表
 @param userId 对应哪个数据库
 @return 是否存在
 */
+ (BOOL)table_isExist:(Class)cls userId:(NSString *)userId;

/**
 根据类名创建一张表在userId对应的数据库中
 
 @param cls 类名
 @param userId 用户Id
 @return 创建是否成功
 */
+ (BOOL)table_createTable:(Class)cls userId:(NSString *)userId;

/**
 是否需要更新边，表的字段
 
 @param cls 类
 @param userId 用户Id
 @return 是否需要更新
 */
+ (BOOL)table_isRequireUpdateTable:(Class)cls userId:(NSString *)userId;


/**
 查询 userId数据库对应的cls表的数据
 
 @param cls 对应哪张表
 @param userId 对应哪个数据库
 @return 对应的数据库值
 */
+ (NSArray *)table_sortedColumnNames:(Class)cls userId:(NSString *)userId;

/**
 更新表 - 更新表的字段
 
 @param cls 类
 @param userId 用户Id
 @return 更新是否成功
 */
+ (BOOL)table_updateTable:(Class)cls userId:(NSString *)userId;


@end
