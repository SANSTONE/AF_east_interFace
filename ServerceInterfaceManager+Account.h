//
//  ServerceInterfaceManager+Account.h
//  
//
//  Created by LEI.FY on 2019/8/26.
//  Copyright LEI.FY. All rights reserved.
//

#import "ServerceInterfaceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServerceInterfaceManager (Account)



/*1.登录注册相关****************************************/
/**
 注册
 
 @param phoneNum                            用户名
 @param password                            密码
 @param msgAuthCode                     验证码
 @param nickName                            昵称
 @param country                               国家
 @param  finishBlock                    请求成功回调
 @param  failedBlock                    请求失败回调
 @param  businesBlock                  业务数据异常回调
 */

-(id)userRegisterByPhone:(NSString *)phoneNum
                password:(NSString *)password
             msgAuthCode:(NSString *)msgAuthCode
                nickName:(NSString *)nickName
                 country:(NSString *)country
             finishBlock:(ServiceFinishBlock)finishBlock
             failedBlock:(ServiceFailedBlock)failedBlock
            businesBlock:(ServiceBusinesFailedBlock)businesBlock;

/**
 登录 用户名=手机号

 @param phoneNum                        手机号
 @param password                         密码
 @param  finishBlock                请求成功回调
 @param  failedBlock                请求失败回调
 @param  businesBlock              业务数据异常回调
 */

-(id)userLoginByPhone:(NSString *)phoneNum
             password:(NSString *)password
          finishBlock:(ServiceFinishBlock)finishBlock
          failedBlock:(ServiceFailedBlock)failedBlock
         businesBlock:(ServiceBusinesFailedBlock)businesBlock;


@end

NS_ASSUME_NONNULL_END
