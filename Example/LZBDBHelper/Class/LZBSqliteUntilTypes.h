//
//  LZBSqliteUntilTypes.h
//  LZBDBHelper
//
//  Created by zibin on 2017/8/3.
//  Copyright © 2017年 lzbgithubcode. All rights reserved.
//

#import <Foundation/Foundation.h>

//模型中成员变量与值的关系
typedef NS_ENUM(NSInteger, LZBIvarNameToValueRelationType){
    LZBIvarNameToValueRelationType_More,  //>
    LZBIvarNameToValueRelationType_Less,  ///<
    LZBIvarNameToValueRelationType_Equal,  //=
    LZBIvarNameToValueRelationType_NotEqual, //!=
    LZBIvarNameToValueRelationType_MoreEqual, //>=
    LZBIvarNameToValueRelationType_LessEqual, ///<=
    
};
extern NSString* LZBIvarNameToValueRelationTypeValue[];
