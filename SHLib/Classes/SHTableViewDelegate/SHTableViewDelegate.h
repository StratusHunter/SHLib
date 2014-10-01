//
//  SHTableViewDelegate.h
//

#import <UIKit/UIKit.h>

/** Your subclass will implement these functions to add custom content to your cells and setup the table view as necessary **/
@protocol SHTableDelegate <NSObject>

@optional
- (void)customInitForTableView:(UITableView *)tableView;
- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView withDataItem:(id)dataItem;

@end

/** Protocol added as a wrapper that will tell you when the cell is selected and what item in the datasource is related to that cell **/
@protocol SHTableSelectionDelegate <NSObject>

- (void)tableView:(UITableView *)tableView cellSelected:(id)cell withDataItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

@end

@interface SHTableViewDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, SHTableDelegate>

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, weak) id <SHTableSelectionDelegate> selectionDelegate;

- (id)initWithTableView:(UITableView *)tableView cellClass:(Class)cellClass andDataSource:(NSArray *)array;

@end