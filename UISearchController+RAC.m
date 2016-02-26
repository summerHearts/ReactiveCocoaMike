//
//  UISearchController+RAC.m
//  ReactiveCocoaMike
//
//  Created by 佐毅 on 16/2/3.
//  Copyright © 2016年 上海乐住信息技术有限公司. All rights reserved.
//


#import "UISearchController+RAC.h"

#import <objc/objc-runtime.h>

@interface UISearchController()<UISearchResultsUpdating, UISearchControllerDelegate>

@end

@implementation UISearchController (RAC)

- (RACSignal *)rac_textSignal
{
    self.searchResultsUpdater = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) {
        return signal;
    }

    signal = [[self rac_signalForSelector:@selector(updateSearchResultsForSearchController:) fromProtocol:@protocol(UISearchResultsUpdating)] map:^id(RACTuple *tuple) {

        UISearchController *searchController = tuple.first;
        return searchController.searchBar.text;
    }];

    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal *)rac_isActiveSignal
{
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;

    RACSignal *willPresentSearching = [[self rac_signalForSelector:@selector(willPresentSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@YES];
    RACSignal *willDismissSearching = [[self rac_signalForSelector:@selector(willDismissSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@NO];
    signal = [RACSignal merge:@[willPresentSearching, willDismissSearching]];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

@end
