//
// Created by Terence Baker on 18/02/2014.
// Copyright (c) 2014 Terence Baker. All rights reserved.
//

#import "TableViewDelegate.h"

@interface TableViewDelegate ()

@property(nonatomic, strong) id cell;
@property(nonatomic, strong) NSString *cellName;

@end

@implementation TableViewDelegate

- (id)initWithTableView:(UITableView *)tableView {

    if (self = [super init]) {

        [tableView setDelegate:self];
        [tableView setDataSource:self];

        self.dataSource = @[]; //This is to make Cal happy

        [self customInitForTableView:tableView];
    }

    return self;
}

- (id)initWithTableView:(UITableView *)tableView andCellClass:(Class)cellClass {

    if (self = [self initWithTableView:tableView]) {

        [self registerCellWithClass:cellClass forTableView:tableView];
    }

    return self;
}

- (id)initWithTableView:(UITableView *)tableView andDataSource:(NSArray *)array {

    if (self = [self initWithTableView:tableView]) {

        self.dataSource = array;
    }

    return self;
}

- (id)initWithTableView:(UITableView *)tableView withCellClass:(Class)cellClass andDataSource:(NSArray *)array {

    if (self = [self initWithTableView:tableView andDataSource:array]) {

        [self registerCellWithClass:cellClass forTableView:tableView];
    }

    return self;
}

- (void)registerCellWithClass:(Class)cellClass forTableView:(UITableView *)tableView {

    self.cellName = NSStringFromClass(cellClass);
    UINib *nib = [UINib nibWithNibName:self.cellName bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:self.cellName];

    self.cell = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellName];

    [self configureCell:cell atIndexPath:indexPath forTableView:tableView];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self configureCell:self.cell atIndexPath:indexPath forTableView:tableView];

    return [self.cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.selectionDelegate != nil && self.dataSource.count > indexPath.row) {

        [self.selectionDelegate tableView:tableView itemSelected:self.dataSource[indexPath.row] atIndexPath:indexPath];
    }
}

- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView {

    //This is where you do all your cell stuff. Though starting to see this kind of stuff should be done in the cell class not in here!
}

- (void)customInitForTableView:(UITableView *)tableView {

    //Override this to add your specific settings when it gets created
}
@end