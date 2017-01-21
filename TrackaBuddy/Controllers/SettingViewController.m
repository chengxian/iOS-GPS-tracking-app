//
//  SettingViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 18/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _m_TableCellIDArr = [[NSMutableArray alloc] initWithObjects:@"TrafficEnableCell", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView DataSource and Delegate Methods
//-----------------------------------------------------------------------------------------------------------------------------------$ UITableView DataSource, Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_m_TableCellIDArr count];
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell * cell;
    
    if (section == 0 ) {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:[_m_TableCellIDArr objectAtIndex:row]];
            UISwitch * switchTrafficEnable = (UISwitch *)[cell.contentView viewWithTag:TRAFFIC_ENABLE_SWITCH_TAG];
            [switchTrafficEnable setOn:[[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_enable"] boolValue]];
        }
    }
    else if (section == 1)
    {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MapTypeCell"];
            UISegmentedControl * segMapType = (UISegmentedControl *)[cell.contentView viewWithTag:MAP_TYPE_SEGMENTCONTROL_TAG];
            NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica Neue" size:17.0f], NSFontAttributeName, nil];
            [segMapType setTitleTextAttributes:attr forState:UIControlStateNormal];
            NSInteger segIndex = [[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"map_type"] integerValue];
            
            segIndex = segIndex < 0 ? 0 : segIndex;
            
            [segMapType setSelectedSegmentIndex:segIndex];
        }
    }
    else if (section == 2)
    {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TrafficModeCell"];
            UISegmentedControl * segTrafficMode = (UISegmentedControl *)[cell.contentView viewWithTag:TRAFFIC_MODE_SEGMENTCONTROL_TAG];
            NSDictionary * attr = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica Neue" size:17.0f], NSFontAttributeName, nil];
            [segTrafficMode setTitleTextAttributes:attr forState:UIControlStateNormal];
            NSInteger segIndex = [[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_mode"] integerValue] - 1;
            
            segIndex = segIndex < 0 ? 0 : segIndex;
            
            [segTrafficMode setSelectedSegmentIndex:segIndex];
        }
    }
   
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * sectionName;
    switch (section) {
        case 0:
            sectionName = @"Traffic Setting";
            break;
        case 1:
            sectionName = @"Mapview Type";
            break;
        case 2:
            sectionName = @"Traffic Mode";
            break;
        case 3:
            sectionName = @"Accuracy Mode";
            break;
        default:
            break;
    }
    
    return sectionName;
}

//-----------------------------------------------------------------------------------------------------------------------------------$$ UITableView DataSource, Delegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actoins
//-----------------------------------------------------------------------------------------------------------------------------------$ Actions

- (IBAction)switchTrafficEnableChanged:(id)sender {
    
    UISwitch * switchTrafficEnable = (UISwitch *)sender;
    [[UserDataSingleton sharedSingleton].userDefaults setObject:[NSNumber numberWithBool:switchTrafficEnable.isOn] forKey:@"traffic_enable"];
}

- (IBAction)btnBackPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mapTypeChanged:(id)sender {
    UISegmentedControl * segMapType = (UISegmentedControl *)sender;
    NSLog(@"mapType : %ld", (long)[segMapType selectedSegmentIndex]);
    
//    GMSMapViewType mapType = (GMSMapViewType)([segMapType selectedSegmentIndex] + 1);
    MKMapType mapType = (MKMapType)[segMapType selectedSegmentIndex];

    [[UserDataSingleton sharedSingleton].userDefaults setObject:[NSNumber numberWithInteger:mapType] forKey:@"map_type"];
}

- (IBAction)trafficModeChanged:(id)sender {
    UISegmentedControl * segTrafficMode = (UISegmentedControl *)sender;
    NSInteger trafficMode = [segTrafficMode selectedSegmentIndex] + 1;
    [[UserDataSingleton sharedSingleton].userDefaults setObject:[NSNumber numberWithInteger:trafficMode] forKey:@"traffic_mode"];
}

//-----------------------------------------------------------------------------------------------------------------------------------$$ Actions
@end
