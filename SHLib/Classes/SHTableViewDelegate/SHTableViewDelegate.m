//
//  SHTableViewDelegate.m
//

#import "SHTableViewDelegate.h"
#import "NSObject+NibLoad.h"

@interface SHTableViewDelegate ()

@property(nonatomic, strong) id cellView; //Used for autoresizing the cells
@property(nonatomic, strong) NSString *cellName; //Used to dequeue cells

@end

@implementation SHTableViewDelegate

- (id)initWithTableView:(UITableView *)tableView cellClass:(Class)cellClass andDataSource:(NSArray *)array {

    if (self = [super init]) {

        [tableView setDelegate:self];
        [tableView setDataSource:self];

        self.dataSource = array;
        [self registerCellWithClass:cellClass forTableView:tableView];

        if ([self respondsToSelector:@selector(customInitForTableView:)]) {

            [self customInitForTableView:tableView];
        }
    }

    return self;
}

/** Get data out of the datasource safely otherwise return nil **/
- (id)dataItemAtIndexPath:(NSIndexPath *)indexPath {

    id item = nil;

    if (self.dataSource.count > indexPath.row) {

        item = self.dataSource[indexPath.row];
    }

    return item;
}

/** Use reflection to load and register the nib from a class **/
- (void)registerCellWithClass:(Class)cellClass forTableView:(UITableView *)tableView {

    self.cellName = NSStringFromClass(cellClass);

    UINib *nib = [UINib nibWithNibName:self.cellName bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:self.cellName];

    self.cellView = [NSClassFromString(self.cellName) loadFromDefaultNib];
}

/** Default behaviour to have as many cells as you have in your datasource. Override for a different amount of cells **/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

/** Dequeue cell using the cells class name as the identifier **/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellName];

    [self safeConfigureCell:cell atIndexPath:indexPath forTableView:tableView];

    return cell;
}

/** Default behaviour is to get the cell to resize to it's content using autolayouts. Override for a fixed size **/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self safeConfigureCell:self.cellView atIndexPath:indexPath forTableView:tableView];

    return [self.cellView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

/** If the selection delegate is set then load up some useful variables and call the delegate function **/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.selectionDelegate respondsToSelector:@selector(tableView:cellSelected:withDataItem:atIndexPath:)]) {

        id dataItem = [self dataItemAtIndexPath:indexPath];
        id cellView = [tableView cellForRowAtIndexPath:indexPath];
        [self.selectionDelegate tableView:tableView cellSelected:cellView withDataItem:dataItem atIndexPath:indexPath];
    }
}

/** Centralise a 'safe' way to call configureCell: **/
- (void)safeConfigureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView {

    if ([self respondsToSelector:@selector(configureCell:atIndexPath:forTableView:withDataItem:)]) {

        id dataItem = [self dataItemAtIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath forTableView:tableView withDataItem:dataItem];
    }
}
@end