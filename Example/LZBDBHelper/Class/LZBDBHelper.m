//
//  LZBDBHelper.m
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import "LZBDBHelper.h"
#import <objc/runtime.h>




@implementation LZBDBHelper
+ (BOOL)saveDBModel:(id)model userId:(NSString *)userId
{
    return [self updateDBModel:model userId:userId];
}
+ (BOOL)updateDBModel:(id)model userId:(NSString *)userId
{
    Class cls = [model class];
    //1.判断模型对应的表是否存在，如果不存在就创建表
    if(![LZBSqliteTableTool table_isExist:cls userId:userId]){
        [LZBSqliteTableTool table_createTable:cls userId:userId];
    }
    //2.检测表字段是否需要更新，如果需要就更新
    if([LZBSqliteTableTool table_isRequireUpdateTable:cls userId:userId]){
        [LZBSqliteTableTool table_updateTable:cls userId:userId];
    }
    //3.判断模型记录是否存在，如果存在就更新  不存在就插入
    //3.1通过主键查找记录，如果能找到记录说明模型记录存在
    NSString *tableName = [cls db_getTabbleName];
    if(![cls respondsToSelector:@selector(model_getPrimaryKey)])
    {
        NSLog(@"必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    NSString *primaryKey = [cls model_getPrimaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    NSString *checkModelExistSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",tableName,primaryKey,primaryValue];
    NSArray *checkResult = [LZBSqliteBaseTool sql_querySql:checkModelExistSql userId:userId];
    //4.获取模型数据
    //获取模型的字段数组
    NSArray *ivarNames = [cls db_ClassIvarNameAndIvarTypeDict].allKeys;
    NSInteger count = ivarNames.count;
    
    //获取模型的值的数组
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:count];
    for (NSString *ivarName in ivarNames) {
        id value = [model valueForKeyPath:ivarName];
        if([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]])
        {
            // 字典/数组 -> data
            NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            // data -> nsstring
            value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        [values addObject:value];
    }
    //拼接更新字符串
    NSMutableArray *pendingArray = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        NSString *ivarName = ivarNames[i];
        NSString *value = values[i];
        [pendingArray addObject:[NSString stringWithFormat:@"%@ = '%@'",ivarName,value]];
    }
    NSString *execsql = @"";
    if(checkResult.count > 0){
        //记录存在，更新 update  表名 set 字段1 = '字段值'，字段2 = '字段值'，…, where 主键 = ‘主键值’
        execsql = [NSString stringWithFormat:@"update %@ set %@  where %@ = '%@'",tableName,[pendingArray componentsJoinedByString:@","],primaryKey,primaryValue];
    }
    else{
        //记录不存在，插入insert into 表名（字段1,字段2,字段3） values (‘值1’，’值2’，’值3’)
        execsql = [NSString stringWithFormat:@"insert into %@ (%@) values ('%@')",tableName,[ivarNames componentsJoinedByString:@","],[values componentsJoinedByString:@"','"]];
    }
    
    return [LZBSqliteBaseTool sql_dealBasesql:execsql userId:userId];
}

#pragma mark- 删除
+ (BOOL)deleteDBModel:(id)model userId:(NSString *)userId
{
    Class cls = [model class];
    NSString *tabbleName = [cls db_getTabbleName];
    if(![cls respondsToSelector:@selector(model_getPrimaryKey)])
    {
        LZBNSLog(@"必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    NSString *primaryKey = [cls model_getPrimaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    if(primaryValue == nil)
    {
        LZBNSLog(@"primaryValue 主键值不能nil");
        return NO;
    }
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",tabbleName,primaryKey,primaryValue];
    return [LZBSqliteBaseTool sql_dealBasesql:deleteSql userId:userId];
    
}
+ (BOOL)deleteDBModel:(Class)cls whereCondition:(NSString *)conditionString userId:(NSString *)userId
{
    NSString *tabbleName = [cls db_getTabbleName];
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",tabbleName];
    if(conditionString.length != 0)
        deleteSql = [deleteSql stringByAppendingFormat:@" where %@",conditionString];
    
    
    return [LZBSqliteBaseTool sql_dealBasesql:deleteSql userId:userId];
}
+ (BOOL)deleteDBModel:(Class)cls columnName:(NSString *)name relation:(LZBIvarNameToValueRelationType)relationType value:(id)value userId:(NSString *)userId
{
    NSString *tabbleName = [cls db_getTabbleName];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",tabbleName];
    
    deleteSql =[deleteSql stringByAppendingFormat:@" where %@ %@ '%@'",name,LZBIvarNameToValueRelationTypeValue[relationType],value];
    
    return [LZBSqliteBaseTool sql_dealBasesql:deleteSql userId:userId];
}
+ (BOOL)deleteDBModel:(Class)cls deleteSql:(NSString *)deletesql userId:(NSString *)userId
{
    NSString *tabbleName = [cls db_getTabbleName];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",tabbleName];
    if(deletesql.length != 0)
        deleteSql = [deleteSql stringByAppendingFormat:@" %@",deletesql];
    return [LZBSqliteBaseTool sql_dealBasesql:deleteSql userId:userId];
}

#pragma mark -查询
+ (NSArray *)queryDBModel:(Class)cls userId:(NSString *)userId
{
    //1.拼接sql语句
    NSString *tabbleName = [cls db_getTabbleName];
    NSString *querySql = [NSString stringWithFormat:@"select * from %@",tabbleName];
    
    //2.获取查询结果集合
    NSArray <NSDictionary *> *results = [LZBSqliteBaseTool sql_querySql:querySql userId:userId];
    
    //3.处理查询结果字典数组 -> 模型数组
    return [self hanleResultWithDictArray:results withClass:cls];
    
}
+ (NSArray *)queryDBModel:(Class)cls columnName:(NSString *)name relation:(LZBIvarNameToValueRelationType)relationType value:(id)value userId:(NSString *)userId
{
    //1.拼接sql语句
    NSString *tabbleName = [cls db_getTabbleName];
    NSString *querySql = [NSString stringWithFormat:@"select * from %@",tabbleName];
    
    querySql =[querySql stringByAppendingFormat:@" where %@ %@ '%@'",name,LZBIvarNameToValueRelationTypeValue[relationType],value];
    
    //2.获取查询结果集合
    NSArray <NSDictionary *> *results = [LZBSqliteBaseTool sql_querySql:querySql userId:userId];
    
    //3.处理查询结果字典数组 -> 模型数组
    return [self hanleResultWithDictArray:results withClass:cls];
}

+ (NSArray *)queryDBModel:(Class)cls querySql:(NSString *)querysql userId:(NSString *)userId
{
    //2.获取查询结果集合
    NSArray <NSDictionary *> *results = [LZBSqliteBaseTool sql_querySql:querysql userId:userId];
    
    //3.处理查询结果字典数组 -> 模型数组
    return [self hanleResultWithDictArray:results withClass:cls];
}



#pragma mark - pravite
+ (NSArray *)hanleResultWithDictArray:(NSArray <NSDictionary *> *)result withClass:(Class)cls
{
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:result.count];
    
    //成员变量名称 ： 成员变量类型字典
    NSDictionary *nameTypeDict = [cls db_ClassIvarNameAndIvarTypeDict];
    
    //遍历数组里面的字典并赋值
    for (NSDictionary *dict in result) {
        id model = [[cls alloc]init];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *type = nameTypeDict[key];
            id resultValue = obj;
            if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
                
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
            }else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]) {
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            [model setValue:resultValue forKeyPath:key];
            
        }];
        [modelArray addObject:model];
    }
    
    return modelArray;
}
@end
