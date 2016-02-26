//
//  CustomController.m
//  ReactiveCocoaMike
//
//  Created by 佐毅 on 16/2/3.
//  Copyright © 2016年 上海乐住信息技术有限公司. All rights reserved.
//

#import "CustomController.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "UISearchController+RAC.h"

@interface CustomController ()

@property NSMutableArray *objects;

@property (nonatomic, strong) UISearchController *searchController;
@property(nonatomic, copy) NSArray *searchTexts;
@property(nonatomic, copy) NSArray *searchResults;
@property(nonatomic, assign, getter = isSearching) BOOL searching;
@end

@implementation CustomController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

    self.searchTexts = @[
                         @"San Francisco",
                         @"Grand Rapids",
                         @"Chicago",
                         @"San Jose"
                         ];
    self.searchResults = @[];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    RAC(self, searchResults) = [self rac_liftSelector:@selector(search:) withSignalsFromArray:@[self.searchController.rac_textSignal]];
    
    [self.searchController.rac_textSignal subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];
    RAC(self, searching) = [self.searchController rac_isActiveSignal];
}
- (NSArray *)search:(NSString *)searchText {
    NSMutableArray *results = [NSMutableArray array];
    if (searchText.length > 0) {
        for (NSString *text in self.searchTexts) {
            if([[text lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
                [results addObject:text];
            }
        }
    } else {
        results = [self.searchTexts copy];
    }
    return results;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isSearching) {
        return self.searchResults.count;
    } else {
        return self.searchTexts.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.isSearching ? self.searchResults[indexPath.row] : self.searchTexts[indexPath.row];
    return cell;
}

@end
