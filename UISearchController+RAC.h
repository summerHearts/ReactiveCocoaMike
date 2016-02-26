//
//  UISearchController+RAC.h
//  ReactiveCocoaMike
//
//  Created by 佐毅 on 16/2/3.
//  Copyright © 2016年 上海乐住信息技术有限公司. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"

@interface UISearchController (RAC)

- (RACSignal *)rac_textSignal;

- (RACSignal *)rac_isActiveSignal;

@end
