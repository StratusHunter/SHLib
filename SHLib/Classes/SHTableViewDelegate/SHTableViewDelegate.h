//
//  SHTableViewDelegate.h
//

#import <UIKit/UIKit.h>

@protocol SHTableSelectionDelegate <NSObject>

- (void)tableView:(UITableView *)tableView itemSelected:(id)item atIndexPath:(NSIndexPath *)indexPath;

@end

@interface SHTableViewDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, weak) id <SHTableSelectionDelegate> selectionDelegate;

- (id)initWithTableView:(UITableView *)tableView;
- (id)initWithTableView:(UITableView *)tableView andCellClass:(Class)cellClass;
- (id)initWithTableView:(UITableView *)tableView withCellClass:(Class)cellClass andDataSource:(NSArray *)array;
- (id)initWithTableView:(UITableView *)tableView andDataSource:(NSArray *)array;

- (void)customInitForTableView:(UITableView *)tableView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;;

@end