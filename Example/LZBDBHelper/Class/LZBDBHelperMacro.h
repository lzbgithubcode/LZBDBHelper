//
//  LZBDBHelperMacro.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/2.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#ifndef LZBDBHelperMacro_h
#define LZBDBHelperMacro_h


#ifdef DEBUG
#define LZBNSLog(...) NSLog(__VA_ARGS__)
#else//发布状态，关闭LOG功能
#define LZBNSLog(...)
#endif

//模型处理类
#import "NSObject+LZBDBModelHelper.h"
//需要用到DB存储的扩展类
#import "LZBDBModelProtocol.h"
//sql基本数据操作类
#import "LZBSqliteBaseTool.h"
//sql处理数据库表的类
#import "LZBSqliteTableTool.h"
//常量类型类
#import "LZBSqliteUntilTypes.h"


#endif /* LZBDBHelperMacro_h */
