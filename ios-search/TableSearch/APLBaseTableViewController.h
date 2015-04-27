#import <UIKit/UIKit.h>

@class APLProduct;

static NSString * const kCellIdentifier = @"cellID";

@interface APLBaseTableViewController : UITableViewController

- (void)configureCell:(UITableViewCell *)cell forProduct:(APLProduct *)product;

@end
