//
//  MyTripsViewController.m
//  TrackaBuddy
//
//  Created by Alexander on 17/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "MyTripsViewController.h"
#import "TripDetailViewController.h"
#import "MGSwipeButton.h"

@implementation MyTripsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchOptionContainer.layer.cornerRadius = 8;
    _btnCancel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _btnCancel.layer.borderWidth = 1;
    _btnSearch.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _btnSearch.layer.borderWidth = 1;
    
//    _trackArray = [[NSMutableArray alloc] init];
    
    //DatePicker(From, To) Configure
    //---------------------------------------------------------------------------------------------------------------------------------------
    
    [self configureDatePicker];
    
    //---------------------------------------------------------------------------------------------------------------------------------------
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSearchOption)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_searchBackView addGestureRecognizer:tapRecognizer];
    
    [self extractSearchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource and Delegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ UITableView DataSource, Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_trackArray count];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger row  = indexPath.row;
//    
//    MyTripsTableCell * cell = (MyTripsTableCell *)[tableView dequeueReusableCellWithIdentifier:@"MyTripsTableCell"];
//    cell.delegate = self;
//    PFObject * cellObject = [_trackArray objectAtIndex:row];
//    if (cellObject) {
//        [cell setValue:cellObject index:row];
//    }
//    return cell;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    MyTripsTableCell * cell;
    
    static NSString * reuseIdentifier = @"programmaticCell";
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MyTripsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    PFObject * cellObject = [_trackArray objectAtIndex:row];
    
    if (cellObject) {
        [cell setValue:cellObject index:row];
    }
    cell.delegate = self;
    cell.allowsMultipleSwipe = NO;
    cell.leftButtons = nil;
    cell.rightButtons = [self createRightButtons:2];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selIndex = indexPath.row;
    [self performSegueWithIdentifier:@"showTripDetailView" sender:nil];
}

-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"Delete", @"Rename"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}


-(NSArray*) swipeTableCell:(MyTripsTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
//    TestData * data = [tests objectAtIndex:[_tableView indexPathForCell:cell].row];
    
    if (direction == MGSwipeDirectionRightToLeft) {
        swipeSettings.transition = MGSwipeTransitionClipCenter;
        expansionSettings.buttonIndex = -1;
        expansionSettings.fillOnTrigger = YES;
        return [self createRightButtons:2];
    }
    return nil;
}

-(BOOL) swipeTableCell:(MyTripsTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"TrackaBuddy" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.tag = 1;
        [alert show];
        
        //delete button
        NSIndexPath * path = [_tblList indexPathForCell:cell];
        _selIndex = path.row;
        return NO; //Don't autohide to improve delete expansion animation
    }
    else if (index == 1)
    {
        NSIndexPath * path = [_tblList indexPathForCell:cell];
        _selIndex = path.row;
        
        UIAlertView * inputAlert = [[UIAlertView alloc] initWithTitle:@"TrackaBuddy" message:@"Please input the name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        inputAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [inputAlert textFieldAtIndex:0];
        textField.text = cell.lblTitle.text;
        inputAlert.tag = 2;
        [inputAlert show];
        
        return NO;
    }
    
    return YES;
}



//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ UITableView DataSource, Delegate


#pragma mark - MyTripsTableCell Delegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ MyTripsTableCell Delegate

- (void)myTripTableCell:(MyTripsTableCell *)myTripTableCell didSelectedRow:(NSInteger)row
{
    NSLog(@"Cell Button Pressed %ld", (long)row);
    _selIndex = row;
    
    [self performSegueWithIdentifier:@"showTripDetailView" sender:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ MyTripsTableCell Delegate


#pragma mark - UITextField Delegate Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ UITextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger index = textField.tag;
    if (index == 2) {
        [textField resignFirstResponder];
    }
    else
    {
        UITextField * nextTextField = (UITextField *)[_searchOptionContainer viewWithTag:index + 1];
        [nextTextField becomeFirstResponder];
    }
    
    return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ UITextField Delegate Method

#pragma mark - Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Methods

//showSearchOption
//-------------------------------------------------------------------------------------------------------------------------------------------------------# showSearchOption

- (void)showSearchOption
{
    BOOL isHidden = _searchOptionContainer.hidden;
    
    CGRect f = _searchOptionContainer.frame;
    f.origin.y = isHidden ? -245 : -5;
    _searchOptionContainer.frame = f;
    _searchOptionContainer.hidden = isHidden ? NO : isHidden;
    _searchBackView.hidden = isHidden ? NO : isHidden;
    _searchBackView.layer.opacity = isHidden ? 0 : 0.4f;
    
    [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
        CGRect cf = _searchOptionContainer.frame;
        cf.origin.y = isHidden ? -5 : -245;
        _searchOptionContainer.frame = cf;
        _searchBackView.layer.opacity = isHidden ? 0.4f : 0;
    } completion:^(BOOL finished) {
        _searchOptionContainer.hidden = isHidden ? NO : YES;
        _searchBackView.hidden = isHidden ? NO : YES;
    }];
    
    [_txtName resignFirstResponder];
    [_txtAddr resignFirstResponder];
    [_txtFrom resignFirstResponder];
    [_txtTo resignFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## showSearchOption

//configureDatePicker
//-------------------------------------------------------------------------------------------------------------------------------------------------------# configureDatePicker

- (void)configureDatePicker
{
    RMActionControllerStyle style = RMActionControllerStyleWhite;
    
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
        [self didSelectedDatePicker:((UIDatePicker *)controller.contentView).date];
    }];
    
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
        NSLog(@"Date selection was canceled");
    }];
    
    _dateSelectionController = [RMDateSelectionViewController actionControllerWithStyle:style];
    
    [_dateSelectionController addAction:selectAction];
    [_dateSelectionController addAction:cancelAction];
    
    RMAction *nowAction = [RMAction actionWithTitle:@"Now" style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
        ((UIDatePicker *)controller.contentView).date = [NSDate date];
        NSLog(@"Now button tapped");
    }];
    nowAction.dismissesActionController = NO;
    
    [_dateSelectionController addAction:nowAction];
    
    _dateSelectionController.disableBouncingEffects = YES;
    _dateSelectionController.disableMotionEffects = YES;
    _dateSelectionController.disableBlurEffects = YES;
    
    _dateSelectionController.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _dateSelectionController.datePicker.minuteInterval = 5;
    _dateSelectionController.datePicker.date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
    if([_dateSelectionController respondsToSelector:@selector(popoverPresentationController)] && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _dateSelectionController.modalPresentationStyle = UIModalPresentationPopover;
    }
    
    _dtFromPicker = [DateUtils setupDatePickerInputViewByDatePickerMode:UIDatePickerModeDateAndTime
                                                                 textControl:_txtFrom
                                                                  withTarget:self
                                                selectorForDatePickerChanged:nil
                                                           selectorForCancel:nil
                                                             selectorForDone:@selector(onFromDatePickerChanged)];
    
    [_dtFromPicker setMinuteInterval:30];
    
    _dtToPicker = [DateUtils setupDatePickerInputViewByDatePickerMode:UIDatePickerModeDateAndTime
                                                          textControl:_txtTo
                                                           withTarget:self
                                         selectorForDatePickerChanged:nil
                                                    selectorForCancel:nil
                                                      selectorForDone:@selector(onToDatePickerChanged)];
    
    [_dtToPicker setMinuteInterval:30];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## configureDatePicker


//didSelectedDatePicker
//-------------------------------------------------------------------------------------------------------------------------------------------------------# didSelectedDatePicker

- (void)didSelectedDatePicker:(NSDate *)date
{
    NSLog(@"Successfully selected date: %@", date);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## didSelectedDatePicker


//onFromDatePickerChanged
//-------------------------------------------------------------------------------------------------------------------------------------------------------# onFromDatePickerChanged

- (void)onFromDatePickerChanged
{
    NSLog(@"Successfully selected date: %@", _dtFromPicker.date);
    
    _fromDate = _dtFromPicker.date;
    
    _txtFrom.text = [DateUtils getDateStringFromDateType1:_fromDate];
    [_txtFrom resignFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## onFromDatePickerChanged


//onToDatePickerChanged
//-------------------------------------------------------------------------------------------------------------------------------------------------------# onToDatePickerChanged

- (void)onToDatePickerChanged
{
    NSLog(@"Successfully selected date: %@", _dtToPicker.date);
    
    _toDate = _dtToPicker.date;
    
    _txtTo.text = [DateUtils getDateStringFromDateType1:_toDate];
    [_txtTo resignFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## onToDatePickerChanged


//extractSearchData
//-------------------------------------------------------------------------------------------------------------------------------------------------------# extractSearchData

- (void)extractSearchData
{
    [self disableControls];

    [ProgressHUD show:@"Loading..."];
    [[UserDataSingleton sharedSingleton] getTripsByUser:[PFUser currentUser] trip_name:_txtName.text address:_txtAddr.text fromDate:_fromDate toDate:_toDate completion:^(BOOL finished, NSMutableArray *trip_array, NSError *error) {
        if (finished) {
            _trackArray = trip_array;
            [_tblList reloadData];
            [ProgressHUD showSuccess:[NSString stringWithFormat:@"%ld Trips", (unsigned long)[_trackArray count]]];
            [self performSelector:@selector(enableControls) withObject:nil afterDelay:0.7f];
        }
        else
        {
            [ProgressHUD showError:@"Network Error!"];
            NSLog(@"Error : %@ userinfo : %@", error.description, [error userInfo]);
            [self performSelector:@selector(enableControls) withObject:nil afterDelay:0.7f];
        }
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## extractSearchData

- (void)enableControls
{
    _btnBack.enabled = YES;
    _btnSearchView.enabled = YES;
    _tblList.userInteractionEnabled = YES;
}

- (void)disableControls
{
    _btnBack.enabled = NO;
    _btnSearchView.enabled = NO;
    _tblList.userInteractionEnabled = NO;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Methods

#pragma mark - Actions
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Actions

//btnBackPressed
//-------------------------------------------------------------------------------------------------------------------------------------------------------# btnBackPressed

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSearchViewPressed:(id)sender {
    [self showSearchOption];
}

- (IBAction)btnSearchPressed:(id)sender {
    _filterIsApplied = YES;
    
    [self extractSearchData];
    
    [self showSearchOption];
}

- (IBAction)btnCancelSearchPrssed:(id)sender {
    _filterIsApplied = NO;
    
    _txtName.text = @"";
    _txtAddr.text = @"";
    _txtFrom.text = @"";
    _txtTo.text = @"";
    _fromDate = nil;
    _toDate = nil;
    
    [self extractSearchData];
    
    [self showSearchOption];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------## btnBackPressed

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Actions

#pragma mark - Navigation
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showTripDetailView"]) {
        TripDetailViewController * vc = [segue destinationViewController];
        vc.currTrip = [_trackArray objectAtIndex:_selIndex];
    }
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1 && _selIndex >= 0) {
        NSLog(@"Delete sure : %ld", (long)_selIndex);
        NSIndexPath * path = [NSIndexPath indexPathForRow:_selIndex inSection:0];
        PFObject * trackObj = _trackArray[_selIndex];
        [ProgressHUD show:@"Deleting..."];
        [[UserDataSingleton sharedSingleton] deleteTrack:trackObj completion:^(BOOL finished, NSError *error) {
            if (finished) {
                [ProgressHUD dismiss];
                [_trackArray removeObjectAtIndex:_selIndex];
                [_tblList deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                _selIndex = -1;
            }
            else
            {
                [ProgressHUD showError:[NSString stringWithFormat:@"Error: %@", error.description]];
                _selIndex = -1;
            }
        }];
    }
    else if (alertView.tag == 2 && buttonIndex == 1 && _selIndex >= 0)
    {
        NSString * title = [[alertView textFieldAtIndex:0] text];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (title.length > 0) {
            PFObject * trackObj = _trackArray[_selIndex];
            [ProgressHUD show:@"Saving..."];
            [[UserDataSingleton sharedSingleton] renameTrack:trackObj name:title completion:^(BOOL isOnline, BOOL finished, NSError *error) {
                if (finished) {
                    if (isOnline)
                        [ProgressHUD showSuccess:@"Saved!"];
                    else
                        [ProgressHUD showSuccess:@"Offline Saved!"];
                    
                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_selIndex inSection:0];
                    MyTripsTableCell * cell = (MyTripsTableCell *)[_tblList cellForRowAtIndexPath:indexPath];
                    [cell setValue:title details:cell.lblDetails.text index:_selIndex];
                    _selIndex = -1;
                }
                else
                {
                    [ProgressHUD showError:[NSString stringWithFormat:@"Error: %@", error.description]];
                    _selIndex = -1;
                }
            }];
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------$$ Navigation
@end
