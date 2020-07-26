//
//  ServerceInterfaceManager.m
//  
//
//  Created by lei.FY on 2019/5/31.
//  Copyright lei.FY. All rights reserved.
//


#import "ServerceInterfaceManager.h"
#import "AFNetworking.h"
#import "ServerceInterfaceManager+Account.h"
#import "ServerceInterfaceManager+Device.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#define WEBNET_TIME_OUT 5.0f

NSNotificationName const FKTokenErrorNotification =@"FKTokenErrorNotification";
@implementation ServerceInterfaceManager
static ServerceInterfaceManager *staic_ServerceInterfaceManager = nil;

-(id)init
{
    self = [super init];
    if (self)
    {
        NSLog(@"API interaface %@",[FKInterfaceAPIModel initWithApiConfigName:@"FKInterfaceApiConfig"].acountRegister);
        self.apiList = [FKInterfaceAPIModel initWithApiConfigName:@"FKInterfaceApiConfig"];
    }
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      staic_ServerceInterfaceManager =[[ServerceInterfaceManager alloc] init];
                      
                  });
    return staic_ServerceInterfaceManager;
}
/*get 方法*/
-(id)JSONGetWithUrl:(NSString *)url
               dict:(NSDictionary *)dict
        finishBlock:(ServiceFinishBlock)finishBlock
        failedBlock:(ServiceFailedBlock)failedBlock
       businesBlock:(ServiceBusinesFailedBlock)businesBlock
{
    //https 必须要加
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    securityPolicy.validatesDomainName = NO;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer =  [AFHTTPRequestSerializer serializer];
    manager.securityPolicy = securityPolicy;
    
    NSString *tokenStr  = [[NSUserDefaults standardUserDefaults]objectForKey:USER_LOGIN_TOKEN];
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionCode  = [versionStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    manager.requestSerializer.timeoutInterval = WEBNET_TIME_OUT;
    NSDictionary  *header;
    if (tokenStr) {
           header = @{//@"Content-Type":@"application/json",
                      @"version-name":versionStr,
                      @"version-code":versionCode,
                      @"device":@"ios",
                      @"token":tokenStr};
       }else{
           header = @{//@"Content-Type":@"application/json",
                      @"version-name":versionStr,
                      @"version-code":versionCode,
                      @"device":@"ios"};
       }

    id responseObject = [manager GET:url parameters:dict headers:header progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *resultDate = responseObject;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resultDate options:NSJSONReadingMutableContainers error:nil];
        
        int status  = [[result objectForKey:@"code"] intValue];
        NSString  *errmsg =  @"请求成功";
        if(status == 200){
            //请求成功，直接传回业务字段
            NSDictionary *resultQ = [result objectForKey:@"message"];
            finishBlock(resultQ,errmsg);
        }else if (status == 3004){
            [[NSNotificationCenter defaultCenter] postNotificationName:FKTokenErrorNotification object:errmsg];
        }else{
            //业务逻辑错误，相应处理，提示
            businesBlock(result,[result objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]){
            NSData *errorData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:errorData
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&error];
            NSString  *errmsg = [result objectForKey:@"error"];
            NSLog(@"错误返回%@",result);
            //NSInteger errorCode = [[result objectForKey:@"code"] integerValue];  ///<备用错误码字段
            //NSLog(@"url  ==  \n错误返回%@",url,result);
            failedBlock(error, errmsg);
        }else{
            NSString  *errmsg = NSLocalizedString(@"Please check the network", nil);
            failedBlock(error,errmsg);
        }
        NSLog(@"error ==%@", [error userInfo][@"com.alamofire.serialization.response.error.string"]);
    }];
    return responseObject;
}


/*psot 方法*/
-(id)JSONPostWithUrl:(NSString *)url
                dict:(NSDictionary *)dict
         finishBlock:(ServiceFinishBlock)finishBlock
         failedBlock:(ServiceFailedBlock)failedBlock
        businesBlock:(ServiceBusinesFailedBlock)businesBlock
{
    NSLog(@"url== %@",url);
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    securityPolicy.validatesDomainName = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.securityPolicy = securityPolicy;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];//申明返回的结果是json类型
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionCode  = [versionStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *tokenStr  = [[NSUserDefaults standardUserDefaults]objectForKey:USER_LOGIN_TOKEN];
    /*http 头里面写参数*/
    NSLog(@"FKTokenErrorNotification 222222222222222 connect******%@*******%@  \n token---%@",url,dict,tokenStr);
    manager.requestSerializer.timeoutInterval = WEBNET_TIME_OUT;
    NSDictionary  *header;
    if (tokenStr) {
        header = @{
                   @"version-name":versionStr,
                   @"version-code":versionCode,
                   @"device":@"ios",
                   @"token":tokenStr};
    }else{
        header = @{
                   @"version-name":versionStr,
                   @"version-code":versionCode,
                   @"device":@"ios"};
    }
    NSURLSessionDataTask *response = [manager dataTaskWithHTTPMethod:@"POST" URLString:url parameters:dict headers:header uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = responseObject;
        int status  = [[result objectForKey:@"code"] intValue];
        NSString  *errmsg = [result objectForKey:@"msg"];
        //请求成功
        NSLog(@"success:%@",result);
        if(status == 0){
            //请求成功，直接传回业务字段
            NSDictionary *resultQ = [result objectForKey:@"data"];
            finishBlock(resultQ,errmsg);
        }else if (status == 3004 && ![url containsString:self.apiList.userLogin]){
            [[NSNotificationCenter defaultCenter] postNotificationName:FKTokenErrorNotification object:errmsg];
             NSString *message =NSLocalizedString(@"The account login is invalid, please log in again", nil);;
             businesBlock(result,message);
        }else{
            //业务逻辑错误，相应处理，提示
            NSString *message =[result objectForKey:@"msg"];
            switch (status) {
                case 3014:
                {
                    message  = NSLocalizedString(@"Incorrect username or password", nil);
                    break;
                }
                case 3008:
                {
                    message  = NSLocalizedString(@"The phone number is already registered", nil);
                    break;
                }
                default:
                    break;
            }
            businesBlock(result,message);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]){
            NSData *errorData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:errorData
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&error];
            NSString  *errmsg = [result objectForKey:@"error"];
            NSLog(@"错误返回%@",result);
            failedBlock(error, errmsg);
        }else{
            //网络原因
            NSString  *errmsg = NSLocalizedString(@"Please check the network", nil);
            failedBlock(error,errmsg);
        }
        NSLog(@"error ==%@", [error userInfo][@"com.alamofire.serialization.response.error.string"]);
    }];
    [response resume];
    return response;
}

-(id)JSONPostWithUrlForCamera:(NSString *)url
                         dict:(NSDictionary *)dict
                  finishBlock:(ServiceFinishBlock)finishBlock
                  failedBlock:(ServiceFailedBlock)failedBlock
                 businesBlock:(ServiceBusinesFailedBlock)businesBlock{
    
    NSLog(@"url== %@",url);
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    securityPolicy.validatesDomainName = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.securityPolicy = securityPolicy;
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionCode  = [versionStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *tokenStr  = [[FKCameraManager shareSingleton] read_camera_loginToken];
    
    NSDictionary  *header;
    if (tokenStr) {
        header = @{
                   @"version-name":versionStr,
                   @"version-code":versionCode,
                   @"device":@"ios",
                   @"token":tokenStr};
    }else{
        header = @{
                   @"version-name":versionStr,
                   @"version-code":versionCode,
                   @"device":@"ios"};
    }
    NSLog(@"FKTokenErrorNotification camera paramer:\n******%@\n*******%@\n******%@",url,dict,tokenStr);
    NSURLSessionDataTask *response = [manager dataTaskWithHTTPMethod:@"POST" URLString:url parameters:dict headers:header uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = responseObject;
        int status  = [[result objectForKey:@"code"] intValue];
        NSString  *errmsg = [result objectForKey:@"msg"];
        // NSLog(@"first handler resust %@",result);
        if(status == 0){
            //请求成功，直接传回业务字段
            NSDictionary *resultQ = [result objectForKey:@"data"];
            finishBlock(resultQ,errmsg);
        }else{
            //业务逻辑错误，相应处理，提示
            businesBlock(result,[result objectForKey:@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]){
            NSData *errorData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:errorData
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&error];
            NSString  *errmsg = [result objectForKey:@"error"];
            NSLog(@"错误返回%@",result);
            failedBlock(error, errmsg);
        }else{
            //网络原因
            NSString  *errmsg = NSLocalizedString(@"Please check the network", nil);
            failedBlock(error,errmsg);
        }
    }];
    [response resume];
    return response;
}

-(id)JSONPostJustForPageWithUrl:(NSString *)url
                           dict:(NSDictionary *)dict
                    finishBlock:(ServiceFinishBlock)finishBlock
                    failedBlock:(ServiceFailedBlock)failedBlock
                   businesBlock:(ServiceBusinesFailedBlock)businesBlock
{
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    securityPolicy.validatesDomainName = NO;
    
    /**/
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.securityPolicy = securityPolicy;
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"device"];
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionCode  = [versionStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *tokenStr  = [[NSUserDefaults standardUserDefaults]objectForKey:USER_LOGIN_TOKEN];
    manager.requestSerializer.timeoutInterval = WEBNET_TIME_OUT;
    
    NSDictionary  *header;
    if (tokenStr) {
        header = @{
                   @"version-code":versionCode,
                   @"device":@"ios",
                   @"pageNum":[dict objectForKey:@"pageNum"],
                   @"pageSize":[dict objectForKey:@"pageSize"],
                   @"token":tokenStr};
    }else{
        header = @{
                   @"version-code":versionCode,
                   @"pageNum":[dict objectForKey:@"pageNum"],
                   @"pageSize":[dict objectForKey:@"pageSize"],
                   @"device":@"ios"};
    }
    NSURLSessionDataTask *response = [manager dataTaskWithHTTPMethod:@"POST" URLString:url parameters:dict headers:header uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = responseObject;
        int status  = [[result objectForKey:@"code"] intValue];
        NSString  *errmsg = @"请求成功";
        if(status == 200){
            //请求成功，直接传回业务字段
            NSDictionary *resultQ = [result objectForKey:@"message"];
            finishBlock(resultQ,errmsg );
        }else if (status == 3004){
            [[NSNotificationCenter defaultCenter] postNotificationName:FKTokenErrorNotification object:errmsg];
        }else{
            //业务逻辑错误，相应处理，提示
            businesBlock(result,[result objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]){
            NSData *errorData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:errorData
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&error];
            NSString  *errmsg = [result objectForKey:@"error"];
            //            NSInteger errorCode = [[result objectForKey:@"code"] integerValue];  ///<备用错误码字段
            
            NSLog(@"错误返回%@",result);
            failedBlock(error, errmsg);
        }else{
            //网络原因
            NSString  *errmsg = NSLocalizedString(@"Please check the network", nil);
            failedBlock(error,errmsg);
        }
        NSLog(@"error ==%@", [error userInfo][@"com.alamofire.serialization.response.error.string"]);
    }];
    [response resume];
    return response;
}

-(void)downFileFetchWithUrl:(NSString *)url
                       dict:(NSDictionary *)dict
               fileSavePath:(NSString *)fileSavePath
                finishBlock:(ServiceFinishBlock)finishBlock
                failedBlock:(ServiceFailedBlock)failedBlock
               businesBlock:(ServiceBusinesFailedBlock)businesBlock{
    // 创建会话管理者
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    // 创建下载路径
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //创建下载任务
    NSURLSessionDownloadTask *downTask = [manager downloadTaskWithRequest:request
                                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"当前下载进度 %@",[NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount]);
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL URLWithString:fileSavePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File download sucess: %@",filePath);
        finishBlock(response,error);
    }];
    [downTask resume];
}


+ (void)netWorkStatus:(NetworkBlock)networkBlock{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        
        NSString *ssid = @"Not Found";
        CFArrayRef myArray = CNCopySupportedInterfaces();
        if (myArray != nil) {
            CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
            if (myDict != nil) {
                NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
                ssid = [dict valueForKey:@"SSID"];
            }
            
            // CFRelease(myArray);
        }
        networkBlock(@"sucess",ssid);
        NSLog(@"WIFI");
        
    }];
    
    // 3.开始监控
    //[manager startMonitoring];
}

@end

