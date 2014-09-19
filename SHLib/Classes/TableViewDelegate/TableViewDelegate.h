//
// Created by Terence Baker on 18/02/2014.
// Copyright (c) 2014 Terence Baker. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TableSelectionDelegate <NSObject>

- (void)tableView:(UITableView *)tableView itemSelected:(id)item atIndexPath:(NSIndexPath *)indexPath;

@end

@interface TableViewDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, weak) id <TableSelectionDelegate> selectionDelegate;

- (id)initWithTableView:(UITableView *)tableView;
- (id)initWithTableView:(UITableView *)tableView andCellClass:(Class)cellClass;
- (id)initWithTableView:(UITableView *)tableView withCellClass:(Class)cellClass andDataSource:(NSArray *)array;
- (id)initWithTableView:(UITableView *)tableView andDataSource:(NSArray *)array;
- (void)customInitForTableView:(UITableView *)tableView;
- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;;

@end