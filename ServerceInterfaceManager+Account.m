//
//  ServerceInterfaceManager+Account.m
//  
//
//  Created by LEI.FY on 2019/8/26.
//  Copyright LEI.FY. All rights reserved.
//

#import "ServerceInterfaceManager+Account.h"

@implementation ServerceInterfaceManager (Account)




-(id)userRegisterByPhone:(NSString *)phoneNum
                password:(NSString *)password
             msgAuthCode:(NSString *)msgAuthCode
                nickName:(NSString *)nickName
                 country:(NSString *)country
             finishBlock:(ServiceFinishBlock)finishBlock
             failedBlock:(ServiceFailedBlock)failedBlock
            businesBlock:(ServiceBusinesFailedBlock)businesBlock{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [dic setObject:phoneNum                          forKey:@"phoneNum"];
    [dic setObject:password                          forKey:@"password"];
    [dic setObject:nickName                          forKey:@"nickName"];
    [dic setObject:country                           forKey:@"country"];
    [dic setObject:msgAuthCode                       forKey:@"msgAuthCode"];
    
    id operation = [self JSONPostWithUrl:self.apiList.acountRegister
                                    dict:dic
                             finishBlock:finishBlock
                             failedBlock:failedBlock
                            businesBlock:businesBlock];
    return operation;
}

-(id)userLoginByPhone:(NSString *)phoneNum
             password:(NSString *)password
          finishBlock:(ServiceFinishBlock)finishBlock
          failedBlock:(ServiceFailedBlock)failedBlock
         businesBlock:(ServiceBusinesFailedBlock)businesBlock{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [dic setObject:phoneNum                          forKey:@"phoneNum"];
    [dic setObject:password                          forKey:@"password"];
 
    id operation = [self JSONPostWithUrl:self.apiList.userLogin
                                    dict:dic
                             finishBlock:finishBlock
                             failedBlock:failedBlock
                            businesBlock:businesBlock];
    return operation;
    
}

@end
