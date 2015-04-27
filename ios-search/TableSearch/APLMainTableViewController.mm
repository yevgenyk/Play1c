#import "APLMainTableViewController.h"
#import "APLDetailViewController.h"
#import "APLResultsTableController.h"
#import "APLProduct.h"

#include "DataStoreImpl.h"

using namespace DataStoreImpl;


@interface APLMainTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) APLResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end


#pragma mark -

@implementation APLMainTableViewController
{
    NSString *sqliteFilePath;
}

- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];    

    _resultsTableController = [[APLResultsTableController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    
    sqliteFilePath  = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"sqlite"];
    assert(sqliteFilePath);
    
    [self findWords:@"" max:25];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    //NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    //NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    //NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    //NSLog(@"didDismissSearchController");
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsTableController.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APLProduct *product = self.resultsTableController.filteredProducts[indexPath.row];
    NSLog(@"%@", product.title);
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forProduct:product];
    return cell;
}

// here we are the table view delegate for both our main table and filtered table, so we can
// push from the current navigation controller (resultsTableController's parent view controller
// is not this UINavigationController)
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    APLProduct *selectedProduct = self.resultsTableController.filteredProducts[indexPath.row];
    
    APLDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"APLDetailViewController"];
    detailViewController.product = selectedProduct; // hand off the current product to the detail view controller
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text

    [self.resultsTableController.filteredProducts removeAllObjects];
    [self findWords:@"" max:25];
    [self.resultsTableController.filteredProducts count];
    [self.resultsTableController.tableView reloadData];
}

-(void)findWords:(NSString*)after000 max:(int)max000 {

    NSString *searchText = self.searchController.searchBar.text;
    NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    std::string after   = std::string([after000 UTF8String]);
    std::string term    = std::string([strippedStr UTF8String]);

    const char *cStringPath = [sqliteFilePath cStringUsingEncoding:NSASCIIStringEncoding];
    
    std::set<WordStruct> words;
    DataStoreImpl::findWords(cStringPath, words, term, after, max000);
    
    std::set<DataStoreImpl::WordStruct>::iterator it;
    for (it = words.begin(); it != words.end(); ++it)
    {
        DataStoreImpl::WordStruct word = *it;
        
        APLProduct *p=
        [APLProduct productWithType:[APLProduct deviceTypeTitle]
                               name:[NSString stringWithCString:word.value.c_str() encoding:[NSString defaultCStringEncoding]]
                               year:nil
                              price:nil];
        
        
        [self.resultsTableController.filteredProducts addObject:p];
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scroll {
    CGFloat currentOffset = scroll.contentOffset.y;
    CGFloat maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 10.0) { //distance from bottom
        
        if ([self.resultsTableController.filteredProducts count] <= 0) {
            return;
        }
        
        APLProduct *row = (APLProduct *)self.resultsTableController.filteredProducts[[self.resultsTableController.filteredProducts count]-1];
        __block NSString *after = row.title;
        NSLog(@"reached end: %@ %@",@"", after);
        
        dispatch_async(dispatch_queue_create("myqueue-000", 0), ^{

            [self findWords:after max:5];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                APLResultsTableController *tableController = (APLResultsTableController *)self.searchController.searchResultsController;
                [tableController.tableView reloadData];
                [self.tableView reloadData];
            });
        });
    }
}

@end

