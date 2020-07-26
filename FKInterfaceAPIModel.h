//
//  FKInterfaceAPIModel.h
//  FDKK
//
//  Created by LEI.FY on 2019/8/23.
//  Copyright © LEI.FY. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface FKInterfaceAPIModel : NSObject

// 服务器
@property(nonatomic,copy)NSString * appDebugUrl ;

@property (nonatomic,copy) NSString *appReleaseUrl;

/**********************************账号管理**********************************/


// app端登陆(账号登录)
@property(nonatomic,copy)NSString * userLogin;


// 注册账户
@property(nonatomic,copy)NSString * acountRegister;

/*便捷方法*/

-(instancetype)initWithApiConfigName:(NSString *)configName;

+(instancetype)initWithApiConfigName:(NSString *)configName;

@end

NS_ASSUME_NONNULL_END
