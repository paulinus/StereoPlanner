//
//  SettingsViewController.mm
//  StereoPlanner
//
//  Created by Pau Gargallo on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SensorSizeViewController.h"
#import "ViewerDistanceViewController.h"
#import "SettingsViewController.h"


@implementation SettingsViewController


#pragma mark -
#pragma mark Initialization

- (id)initWithDocument:(SpDocument *)document delegate:(id)dele {
  doc_ = document;
  delegate_ = dele;
  return [self initWithStyle:UITableViewStyleGrouped];
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = @"Settings";
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Done"
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(doneButton)];
}



- (void)viewWillAppear:(BOOL)animated {
  [self.tableView setNeedsLayout]; 
  
  {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
      [self setSensorSizeDetailText:cell];
    }
  }
  {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: 1 inSection: 0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
      [self setViewerDistanceDetailText:cell];
    }
  }
  [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
  // Configure the cell...
  switch (indexPath.row) {
    case 0:
    {
      cell.textLabel.text = @"Sensor size";
      [self setSensorSizeDetailText:cell];
      cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
      break;
    }
    case 1:
      cell.textLabel.text = @"Viewer distance";
      [self setViewerDistanceDetailText:cell];
      cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
      break;
  }
  return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case 0:
    {
      SensorSizeViewController *s = [[SensorSizeViewController alloc] initWithDocument:doc_];
      [self.navigationController pushViewController:s animated:YES];
      [s release];
    } break;
    case 1:
    {
      ViewerDistanceViewController *s = [[ViewerDistanceViewController alloc] initWithDocument:doc_];
      [self.navigationController pushViewController:s animated:YES];
      [s release];
    } break;
  }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)doneButton {
  [delegate_ settingsDone];
}
       
#pragma mark -
#pragma mark DetailText updates
   
- (void)setSensorSizeDetailText:(UITableViewCell *)cell {
  const SensorType &st = doc_->SensorTypeAt(doc_->SelectedSensorType());
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%gmm x %gmm", st.width * 1000, st.height * 1000];
}

- (void)setViewerDistanceDetailText:(UITableViewCell *)cell {
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%g%s", doc_->ObserverZRatio() * 100, "% of screen width"];
}

@end

