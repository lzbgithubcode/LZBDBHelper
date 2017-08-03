//
//  LZBSqliteTableTool.m
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import "LZBSqliteTableTool.h"
#import "NSObject+LZBDBModelHelper.h"
#import "LZBSqliteBaseTool.h"
#import "LZBDBModelProtocol.h"

@implementation LZBSqliteTableTool
+ (BOOL)table_isExist:(Class)cls userId:(NSString *)userId
{
    //1.获取表名
    NSString *tabbleName = [cls db_getTabbleName];
    
    //2.查询语句
    NSString *queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tabbleName];
    
    //3.得到查询结果
    NSMutableArray *result = [LZBSqliteBaseTool sql_querySql:queryCreateSqlStr userId:userId];
    return result.count > 0;
}

+ (BOOL)table_isRequireUpdateTable:(Class)cls userId:(NSString *)userId
{
    NSArray *modelNames =[cls db_ClassAllSortedIvarNames];
    NSArray *sqliteNames = [self table_sortedColumnNames:cls userId:userId];
    BOOL isUpdate = ![modelNames isEqualToArray:sqliteNames];
    return isUpdate;
}

+ (BOOL)table_createTable:(Class)cls userId:(NSString *)userId
{
    //1.根据类名创建一张存放模型的表
    // create table if not exists 表名(字段1 字段1类型, 字段2 字段2类型 (约束),...., primary key(字段))
    NSString *tableName = [cls db_getTabbleName];
    
    //1.1过滤是否设置主键
    if(![cls respondsToSelector:@selector(model_getPrimaryKey)])
    {
        NSLog(@"必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    
    //1.2获取主键
    NSString *primaryKey = [cls model_getPrimaryKey];
    
    //2.获取模型里面的字段和类型并编写出sql语句
    NSString *createTablesql = [NSString stringWithFormat:@"create table if not exists %@ (%@, primary key (%@));",tableName,[cls db_ClassColumnNameAndMapSqliteTypeString],primaryKey];
    
    return [LZBSqliteBaseTool sql_dealBasesql:createTablesql userId:userId];
    
    
}


+ (NSArray *)table_sortedColumnNames:(Class)cls userId:(NSString *)userId
{
    //1.获取表名
    NSString *tabbleName = [cls db_getTabbleName];
    
    //2.查询语句
    NSString *queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tabbleName];
    
    //3.得到查询结果字典的首个数据，主要是为了得到字段名称
    NSMutableDictionary *dict = [LZBSqliteBaseTool sql_querySql:queryCreateSqlStr userId:userId].firstObject;
    
    //  sql = "CREATE TABLE LZBStudentModel (b integer,studentId integer,name text,fale integer, primary key (studentId))"
    
    //3.1转化为小写，并过滤
    NSString *tableSql = dict[@"sql"];
    if(tableSql.length == 0){
        return nil;
    }
    
    //3.2过滤特殊字符串
    //create table lzbstudentmodel (b integer,studentid integer,name text,fale integer, primary key (studentid))
    tableSql = [tableSql stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    tableSql = [tableSql stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    tableSql = [tableSql stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    tableSql = [tableSql stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    
    //3.3获取参数
    NSString *nameTypeAllString = [tableSql componentsSeparatedByString:@"("][1];
    NSArray *nameTypeAllArray = [nameTypeAllString componentsSeparatedByString:@","];
    
    //3.4获得数据库字段名称
    
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *nameType in nameTypeAllArray) {
        if([[nameType lowercaseString] containsString:@"primary"])
            continue;
        
        //空格压缩
        NSString *nameTypes = [nameType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        NSString *name = [nameTypes componentsSeparatedByString:@" "].firstObject;
        
        //把字段名称增加到数组中
        [names addObject:name];
    }
    //排序
    [names sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    return names;

}

+ (BOOL)table_updateTable:(Class)cls userId:(NSString *)userId
{
    //1.创建临时表
    NSString *tempTableName = [cls db_getTabbleTempName];
    NSString *oldTableName = [cls db_getTabbleName];
    //1.1过滤是否设置主键
    if(![cls respondsToSelector:@selector(model_getPrimaryKey)])
    {
        NSLog(@"必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    
    NSString *primaryKey = [cls model_getPrimaryKey];
    
    NSMutableArray *execsqls = [NSMutableArray array];
    
    NSString *createTablesql = [NSString stringWithFormat:@"create table if not exists %@ (%@, primary key (%@));",tempTableName,[cls db_ClassColumnNameAndMapSqliteTypeString],primaryKey];
    [execsqls addObject:createTablesql];
    
    //2.向临时表中插入主键mysql>insert into tbl_name1(col1,col2) select col3,col4 from tbl_name2;
    NSString *insertPrimaryKeysql = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",tempTableName,primaryKey,primaryKey,oldTableName];
    
    [execsqls addObject:insertPrimaryKeysql];
    
    //3.根据主键把老表的数据插入到新的临时表中
    NSArray *oldNames = [self table_sortedColumnNames:cls userId:userId];
    NSArray *newNames = [cls db_ClassAllSortedIvarNames];
    
    
    //3.1.获取更改字段的字典
    NSDictionary *reNamePropertyDict = @{};
    if([cls  respondsToSelector:@selector(model_newNameMapToOldNameDictionary)]){
        reNamePropertyDict = [cls model_newNameMapToOldNameDictionary];
    }
    
    for (NSString *columnName in newNames) {
        
        //3.2过滤通过新的字段找到映射到旧表的老字段
        NSString *oldName = columnName;
        if([reNamePropertyDict[oldName] length] != 0)
            oldName = reNamePropertyDict[oldName];
        
        //3.3如果旧表中不包括字段 并且不保存以前映射的老字段 或者 字段是属性，那么就继续
        if((![oldNames containsObject:columnName] && ![oldNames containsObject:oldName])||[oldName isEqualToString:primaryKey]){
            continue;
        }
        //如果老表里面有新表的字段,就把老表的字段的数据插入新表中
        NSString *updateSql= [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)",tempTableName,columnName,oldName,oldTableName,tempTableName,primaryKey,oldTableName,primaryKey];
        [execsqls addObject:updateSql];
        
    }
    
    //4.删除老表
    NSString *deleteOldTablesql = [NSString stringWithFormat:@"drop table if exists %@",oldTableName];
    [execsqls addObject:deleteOldTablesql];
    
    //5.更改临时表的名字为新表的名字 ,新表和旧表名字一样
    NSString *renameTabbleName = [NSString stringWithFormat:@"alter table %@ rename to %@",tempTableName,oldTableName];
    [execsqls addObject:renameTabbleName];
    
    return [LZBSqliteBaseTool sql_dealsqls:execsqls userId:userId];
    
    
}
@end
