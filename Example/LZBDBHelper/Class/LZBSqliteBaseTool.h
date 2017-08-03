//
//  LZBSqliteBaseTool.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/2.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//sqlite的基本操作语句 DDL  DML   DQL

#import <Foundation/Foundation.h>

@interface LZBSqliteBaseTool : NSObject
/**
 执行sql语句
 
 @param sql sql语句
 @param userId 用户Id
 @return 执行成功和失败
 */
+ (BOOL)sql_dealBasesql:(NSString *)sql  userId:(NSString *)userId;

/**
 执行sql语句组，采用事务进行包装
 
 @param sqls sql语句组
 @param userId 用户Id
 @return 执行成功和失败
 */
+ (BOOL)sql_dealsqls:(NSArray <NSString *>*)sqls  userId:(NSString *)userId;

/**
 查询sql语句,返回结果集
 
 @param sql sql sql语句
 @param userId userId 用户Id
 @return 查询结果
 */
+ (NSMutableArray <NSMutableDictionary *>*)sql_querySql:(NSString *)sql userId:(NSString *)userId;
@end
