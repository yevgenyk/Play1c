#import "APLResultsTableController.h"
#import "APLProduct.h"

@implementation APLResultsTableController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.filteredProducts = [NSMutableArray array];
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APLProduct *product = self.filteredProducts[indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    assert(cell != nil);    // we should always have a cell
    
    [self configureCell:cell forProduct:product];
    return cell;
}


@end