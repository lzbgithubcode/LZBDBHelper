//
//  LZBDBHelper.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZBDBHelperMacro.h"

@interface LZBDBHelper : NSObject

#pragma mark - 保存更新
/**
 保存模型/更新模型
 
 @param model 需要保存的模型
 @param userId 决定那个数据库
 @return 是否保存成功
 */
+ (BOOL)saveDBModel:(id)model userId:(NSString *)userId;

/**
 更新模型
 
 @param model 需要更新的模型
 @param userId 决定那个数据库
 @return 是否更新成功
 */
+ (BOOL)updateDBModel:(id)model userId:(NSString *)userId;


#pragma mark - 删除
/**
 删除模型记录 - 默认根据主键删除 - 主键不能为nil
 
 @param model 被删除模型
 @param userId 决定那个数据库
 @return 是否删除成功
 */
+ (BOOL)deleteDBModel:(id)model userId:(NSString *)userId;



/**
 根据条件删除记录  比如  age < 10
 
 @param cls 模型类
 @param conditionString 删除的条件
 @param userId 决定那个数据库
 @return 是否删除成功
 */
+ (BOOL)deleteDBModel:(Class)cls whereCondition:(NSString *)conditionString userId:(NSString *)userId;


/**
 根据条件删除记录  比如  age < 10
 
 @param cls 模型类
 @param name 成员变量名
 @param relationType 关系类型
 @param value 成员变量对应的值
 @param userId 决定那个数据库
 @return 是否删除成功
 */
+ (BOOL)deleteDBModel:(Class)cls columnName:(NSString *)name relation:(LZBIvarNameToValueRelationType)relationType value:(id)value userId:(NSString *)userId;


/**
 执行deletesql删除的sql语句
 
 @param cls 模型类
 @param deletesql sql的删除语句
 @param userId 决定那个数据库
 @return 是否删除成功
 */
+ (BOOL)deleteDBModel:(Class)cls deleteSql:(NSString *)deletesql userId:(NSString *)userId;

#pragma mark - 查询
/**
 查询模型记录
 
 @param cls 模型
 @param userId 决定那个数据库
 @return 查询结果
 */
+ (NSArray *)queryDBModel:(Class)cls userId:(NSString *)userId;

/**
 根据条件查询记录  比如  age < 10
 
 @param cls 模型类
 @param name 成员变量名
 @param relationType 关系类型
 @param value 成员变量对应的值
 @param userId 决定那个数据库
 @return 查询结果
 */
+ (NSArray *)queryDBModel:(Class)cls columnName:(NSString *)name relation:(LZBIvarNameToValueRelationType)relationType value:(id)value userId:(NSString *)userId;


/**
 执行querysql查询的sql语句
 
 @param cls 模型类
 @param querysql sql的查询语句
 @param userId 决定那个数据库
 @return 查询结果
 */
+ (NSArray *)queryDBModel:(Class)cls querySql:(NSString *)querysql userId:(NSString *)userId;

@end
