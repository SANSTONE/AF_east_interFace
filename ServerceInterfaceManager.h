//
//  ServerceInterfaceManager.h
//  
//
//  Created by lei.FY on 2019/5/31.
//  Copyright lei.FY.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FKInterfaceAPIModel.h"
extern NSNotificationName const FKTokenErrorNotification;
/**
 请求成功回调block
 */
typedef void(^ServiceFinishBlock)(id  result, id  serviceOperation);

/**
 请求失败回调block
 */
typedef void(^ServiceFailedBlock)(id  result, id  serviceOperation);

/**
 业务逻辑层错误回调block
 */
typedef void(^ServiceBusinesFailedBlock)(id  result, id  serviceOperation);


/**
 wi-fi状态变化时候的回调block
 */
typedef void(^NetworkBlock)(id status, id  WiFiName);


@interface ServerceInterfaceManager : NSObject

@property (nonatomic,   copy) ServiceFinishBlock          finishBlock;           ///< 请求成功
@property (nonatomic,   copy) ServiceFailedBlock          failedBlock;           ///< 请求失败
@property (nonatomic,   copy) ServiceBusinesFailedBlock   businesBlock;          ///< 业务层请求异常

@property (nonatomic,   copy) NetworkBlock                networkBlock;          ///<  wi-i状态变化时候的回调block

@property (nonatomic,   strong)FKInterfaceAPIModel        *apiList;              ///< API list

/**
 单例实现
 */
+ (id)sharedInstance;

/**
 请求接口Post方法
 
 @param url                 地址
 @param dict                请求参数
 @param finishBlock         请求成功回调
 @param failedBlock         请求失败回调
 @param businesBlock        业务数据异常回调
 */
-(id)JSONPostWithUrl:(NSString *)url
                dict:(NSDictionary *)dict
         finishBlock:(ServiceFinishBlock)finishBlock
         failedBlock:(ServiceFailedBlock)failedBlock
        businesBlock:(ServiceBusinesFailedBlock)businesBlock;


/**
 请求接口Post方法
 
 @param url                    地址
 @param dict                       请求参数
 @param finishBlock         请求成功回调
 @param failedBlock         请求失败回调
 @param businesBlock        业务数据异常回调
 */
-(id)JSONPostWithUrlForCamera:(NSString *)url
                         dict:(NSDictionary *)dict
                  finishBlock:(ServiceFinishBlock)finishBlock
                  failedBlock:(ServiceFailedBlock)failedBlock
                 businesBlock:(ServiceBusinesFailedBlock)businesBlock;


/*下载文件*/


-(void)downFileFetchWithUrl:(NSString *)url
                       dict:(NSDictionary *)dict
               fileSavePath:(NSString *)fileSavePath
                finishBlock:(ServiceFinishBlock)finishBlock
                failedBlock:(ServiceFailedBlock)failedBlock
               businesBlock:(ServiceBusinesFailedBlock)businesBlock;
/**
 请求接口Get方法
 
 @param url                 地址
 @param dict                请求参数
 @param finishBlock         请求成功回调
 @param failedBlock         请求失败回调
 @param businesBlock        业务数据异常回调
 */
-(id)JSONGetWithUrl:(NSString *)url
               dict:(NSDictionary *)dict
        finishBlock:(ServiceFinishBlock)finishBlock
        failedBlock:(ServiceFailedBlock)failedBlock
       businesBlock:(ServiceBusinesFailedBlock)businesBlock;

/**
 带分页请求请求接口Post方法  dic参数中必须是有page，pagenNum的
 
 @param url                 地址
 @param dict                请求参数
 @param finishBlock         请求成功回调
 @param failedBlock         请求失败回调
 @param businesBlock        业务数据异常回调
 */

/*psot 方法*/
-(id)JSONPostJustForPageWithUrl:(NSString *)url
                           dict:(NSDictionary *)dict
                    finishBlock:(ServiceFinishBlock)finishBlock
                    failedBlock:(ServiceFailedBlock)failedBlock
                   businesBlock:(ServiceBusinesFailedBlock)businesBlock;

/**
 网络状态检查,根据需要使用
 */
+ (void)netWorkStatus:(NetworkBlock)networkBlock;

@end
