
//
//  FKInterfaceAPIModel.m
//  FDKK
//
//  Created by LEI.FY on 2019/8/23.
//  Copyright LEI.FY. All rights reserved.
//

#import "FKInterfaceAPIModel.h"

@implementation FKInterfaceAPIModel

-(instancetype)initWithApiConfigName:(NSString *)configName{
    self = [super init];
    if (self) {
    
        NSString *path=[[NSBundle mainBundle] pathForResource:configName
                                                       ofType:@"plist"];
        NSDictionary *infoDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
       
        [infoDic enumerateKeysAndObjectsUsingBlock:
         ^(id key, id obj, BOOL *stop)
         {
             id value = obj;
             
             if ([obj isKindOfClass:[NSNumber class]])
             {
                 if (strcmp([obj objCType], @encode(BOOL)) != 0)
                 {
                     @try
                     {
                         value = [NSString stringWithFormat:@"%@",[obj stringValue]];
                     }
                     @catch (NSException * e)
                     {
                         if ([[e name] isEqualToString:NSInvalidArgumentException])
                         {
                             NSNumber *temp =[NSNumber numberWithBool:[obj boolValue]];
                             value =  [NSString stringWithFormat:@"%@",[temp stringValue]];
                             
                         }
                     }
                     
                 }
             }
             else if([obj isKindOfClass:[NSNull class]])
             {
                 value = @"";
             }
            
             if (![key isEqualToString:@"appDebugUrl"] &&
                 ![key isEqualToString:@"appReleaseUrl"] &&) {
                 value = [APPRELEASEURL stringByAppendingString:obj];
             }
            
             [self setValue:value forKey:key];
         }];
    }
    return self;
}

+ (instancetype)initWithApiConfigName:(NSString *)configName{
    
    return [[self alloc]initWithApiConfigName:configName];
}


@end
