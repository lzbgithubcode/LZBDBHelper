//
//  LZBSqliteBaseTool.m
//  LZBDBHelper
//
//  Created by zibin on 2017/8/2.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import "LZBSqliteBaseTool.h"
#import "LZBDBHelperMacro.h"
#import <sqlite3.h>
//#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kCachePath @"/Users/apple/Desktop"

sqlite3 *ppDb = nil;

@implementation LZBSqliteBaseTool

+ (BOOL)sql_dealBasesql:(NSString *)sql  userId:(NSString *)userId
{
    
    NSAssert(sql.length != 0, @"sql语句不能nil");
    //1.创建并打开数据库
    if(![self openSqliteWithUserId:userId]) return NO;
    
    
    //2.执行sql语句
    int result = sqlite3_exec(ppDb,sql.UTF8String , nil, nil, nil);
    if(result != SQLITE_OK){
        LZBNSLog(@"执行sql语句失败，sqlite3_exec返回码：%d",result);
    }
    
    //3.关闭数据库
    [self closeSqlite];
    
    return result == SQLITE_OK;
}
+ (BOOL)sql_dealsqls:(NSArray <NSString *>*)sqls  userId:(NSString *)userId
{
    //开启事务
    [self beginTransaction:userId];
    
    for (NSString *sql in sqls) {
        BOOL result = [self sql_dealBasesql:sql userId:userId];
        if(result == NO)
        {
            //执行失败就回滚事务
            [self rollBackTransaction:userId];
            return NO;
        }
    }
    //都执行成功才提交事务
    [self commitTransaction:userId];
    return YES;
}

+ (NSMutableArray <NSMutableDictionary *>*)sql_querySql:(NSString *)sql userId:(NSString *)userId
{
    //1.打开数据库
    [self openSqliteWithUserId:userId];
    
    //2.创建准备语句
    // 参数1: 一个已经打开的数据库
    // 参数2: 需要中的sql
    // 参数3: 参数2取出多少字节的长度 -1 自动计算 \0
    // 参数4: 准备语句
    // 参数5: 通过参数3, 取出参数2的长度字节之后, 剩下的字符串
    sqlite3_stmt *ppStmt = nil;
    if(sqlite3_prepare_v2(ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK){
        LZBNSLog(@"准备语句编译失败，请执行正确的sql语句");
        return nil;
    }
    
    //3.绑定数据
    
    //4.获得数据,一行就是一个字典，多行组成字典数组
    NSMutableArray *dictArray = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        //4.1获取列的个数
        int columnCount = sqlite3_column_count(ppStmt);
        
        //4.2 创建一行的数据的字典
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionary];
        [dictArray addObject:rowDict];
        
        //4.3遍历每一列获得字典数据
        for (int  i = 0 ; i < columnCount; i++) {
            //4.3.1获得列名
            const char *columnNameC =  sqlite3_column_name(ppStmt, i);
            NSString *columnNameOC = [NSString stringWithUTF8String:columnNameC];
            
            //4.3.2获取每列对应的值并获取每列对应的类型
            int type = sqlite3_column_type(ppStmt, i);
            id value = nil;
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                    
                default:
                    break;
            }
            [rowDict setValue:value forKey:columnNameOC];
        }
        
        
    }
    // 5.重置(省略)
    
    // 6.释放资源
    sqlite3_finalize(ppStmt);
    [self closeSqlite];
    
    return dictArray;
}




#pragma mark - pravite
+ (BOOL)openSqliteWithUserId:(NSString *)userId
{
    NSString *dbName = @"common1.sqlite";
    if(userId.length != 0)
        dbName = [NSString stringWithFormat:@"%@_db.sqlite",userId];
    
    NSString *fullPath = [kCachePath stringByAppendingPathComponent:dbName];
    
    int result = sqlite3_open(fullPath.UTF8String, &ppDb);
    
    if(result != SQLITE_OK){
        LZBNSLog(@"打开数据失败，sqlite3_open 返回码：%d",result);
    }
    return result == SQLITE_OK;
}

+ (void)closeSqlite
{
    int result = sqlite3_close(ppDb);
    if(result != SQLITE_OK){
        LZBNSLog(@"关闭数据失败，sqlite3_close 返回码：%d",result);
    }
}
#pragma mark - 事务

+ (void)beginTransaction:(NSString *)userId
{
    [self sql_dealBasesql:@"begin transaction" userId:userId];
}
+ (void)commitTransaction:(NSString *)userId
{
    [self sql_dealBasesql:@"commit transaction" userId:userId];
}
+ (void)rollBackTransaction:(NSString *)userId
{
    [self sql_dealBasesql:@"rollback transaction" userId:userId];
}
@end
