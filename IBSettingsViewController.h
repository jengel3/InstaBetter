#import "IGHeaders.h"
#import <UIKit/UIKit.h>

@interface IBSettingsViewController : IGPlainTableViewController <UITableViewDataSource, UITableViewDelegate>
  @property (nonatomic, weak) UITableView *settingsTable;

@end