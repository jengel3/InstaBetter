// #import "IBSettingsViewController.h"
#import "IGHeaders.h"

@interface IBSettingsViewController : IGPlainTableViewController <UITableViewDataSource, UITableViewDelegate>
  @property (nonatomic, weak) UITableView *settingsTable;

@end

@implementation IBSettingsViewController
  - (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView = [[IGPlainTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.view addSubview:self.tableView];
  }

  -(NSInteger)tableView:(id)table numberOfRowsInSection:(NSInteger)index {
    if (index == 0) {
      return 1;
    } else if (index == 1) {
      return 3;
    } else if (index == 2) {
      return 7;
    } else if (index == 3) {
      return 2;
    } else if (index == 4) {
      return 1;
    } else if (index == 5) {
      return 3;
    } else if (index == 6) {
      return 3;
    } else if (index == 7) {
      return 2;
    }
    return 0;
  }

  -(id)tableView:(id)table cellForRowAtIndexPath:(NSIndexPath*)index {
    NSString *CellIdentifier = @"Cell";

    IGPlainTableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      cell = [[IGPlainTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    if (index.section == 0) {
      if (index.row == 0) {
        cell.textLabel.text = @"Enable";
      }
    } else if (index.section == 1) {

    } else if (index.section == 2) {

    }
    return cell;  
  }

  -(NSInteger)numberOfSectionsInTableView:(id)table {
    return 8;
  }

  -(id)titleForHeaderInSection:(NSInteger)sec {
    if (sec == 0) {
      return nil;
    } else if (sec == 1) {
      return @"Features";
    }
    return nil;
  }
@end