//
//  DateUtils.m
//  Gathr
//
//  Created by Ping Ahn(Alex) on 5/8/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils
+ (NSDate *)convertGMTtoLocal:(NSDate *)date
{
    NSTimeZone *curTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger curGMTOffset = [curTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = curGMTOffset - gmtOffset;
    
    NSDate *destDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
    
    return destDate;
}

+ (NSDate *)convertLocaltoGMT:(NSDate *)date
{
    NSTimeZone *curTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger curGMTOffset = [curTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = gmtOffset - curGMTOffset;
    
    NSDate *destDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
    
    return destDate;
}

+ (int)getDiffMinsFromDate:(NSDate *)fromDate
{
    NSDate *toDate = [NSDate date];
    NSTimeInterval secs = [toDate timeIntervalSinceDate:fromDate];
    
    return (int)(secs / 60);
}

+ (int)getDiffMinsBetweenTwoDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSTimeInterval secs = [toDate timeIntervalSinceDate:fromDate];
    
    return (int)(secs / 60);
}

+ (NSString *)getDiffTimeFromDate:(NSDate *)fromDate
{
    int mins = [DateUtils getDiffMinsFromDate:fromDate];
    if (mins > 0) {
        int hours = (int)(mins / 60);
        mins = mins % 60;
        return [NSString stringWithFormat:@"%@ %@", hours > 0 ? [NSString stringWithFormat:@"%dh", hours] : @"", mins > 0 ? [NSString stringWithFormat:@"%dm", mins] : @""];
    }
    return @"";
}

+ (NSString *)getDiffTimeBetweenTwoDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    int mins = [DateUtils getDiffMinsBetweenTwoDate:fromDate toDate:toDate];
    
    if (mins > 0) {
        int hours = (int)(mins / 60);
        mins = mins % 60;
        return [NSString stringWithFormat:@"%@ %@", hours > 0 ? [NSString stringWithFormat:@"%dh", hours] : @"", mins > 0 ? [NSString stringWithFormat:@"%dm", mins] : @""];
    }
    return @"";
}

+ (NSDate *)beginningOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];

    return [cal dateFromComponents:comps];
}

+ (NSDate *)endOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    [comps setHour:23];
    [comps setMinute:59];
    
    return [cal dateFromComponents:comps];
}

+ (NSString *)getTimeFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *time = [dateFormatter stringFromDate:date];
    
    return time;
}

+ (NSString *)getDateStringFromDateType1:(NSDate *)date
{
    NSString * string = [self getDateStringFromDate:date formatString:@"yyyy-MM-dd hh:mm"];
    return string;
}

+ (NSString *)getDateStringFromDateType2:(NSDate *)date
{
    NSString * string = [self getDateStringFromDate:date formatString:@"MMM d, yyyy - hh:mm a"];
    return string;
}

+ (NSString *)getDateStringFromDate:(NSDate *)date formatString:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    NSString *string = [dateFormatter stringFromDate:date];
    
    return string;
}

+ (BOOL)isDateIn24HoursAgoFromNow:(NSDate *)now Date:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
    [comps setDay:(comps.day-1)];
    NSDate *prevDate = [cal dateFromComponents:comps];
    if ([date compare:prevDate] == NSOrderedAscending) return NO;
    else return YES;
}

#pragma mark - DatePicker Input Accessory View
+ (UIDatePicker *)setupDatePickerInputViewByDatePickerMode:(UIDatePickerMode)datePickerMode
                                               textControl:(UITextField *)textControl
                                                withTarget:(id)target
                              selectorForDatePickerChanged:(SEL)selectorDatePickerChanged
                                         selectorForCancel:(SEL)selectorCancel
                                           selectorForDone:(SEL)selectorDone
{
    UIDatePicker *datePickerInputView  = [[UIDatePicker alloc] init];
    CGRect frame = datePickerInputView.frame;
    frame.size.height = 190;
    datePickerInputView.frame = frame;
    datePickerInputView.datePickerMode = datePickerMode;
    [datePickerInputView addTarget:target action:selectorDatePickerChanged forControlEvents:UIControlEventValueChanged];
    
    textControl.inputView = datePickerInputView;
    
    UIBarButtonItem *barButtonCancel = [self initInputAccessoryViewBarButtonByStyle:UIBarButtonSystemItemCancel
                                                                             target:target
                                                                           selector:selectorCancel
                                                                     forTextControl:textControl];
    UIBarButtonItem *barButtonSpace = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                       target:self action:nil];
    UIBarButtonItem *barButtonDone = [self initInputAccessoryViewBarButtonByStyle:UIBarButtonSystemItemDone
                                                                           target:target
                                                                         selector:selectorDone
                                                                   forTextControl:textControl];
    
//    [FMAThemeManager decorateInputAccessoryViewBarButton:barButtonCancel textColor:nil];
//    [FMAThemeManager decorateInputAccessoryViewBarButton:barButtonDone   textColor:nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    toolbar.items = [NSArray arrayWithObjects:barButtonCancel, barButtonSpace, barButtonDone, nil];
    
    textControl.inputAccessoryView = toolbar;
    
    return datePickerInputView;
}

+ (UIBarButtonItem *)initInputAccessoryViewBarButtonByStyle:(UIBarButtonSystemItem)style target:(id)target selector:(SEL)selector forTextControl:(id)textControl
{
    if (selector)
    {
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:target action:selector];
    }
    
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:textControl action:@selector(resignFirstResponder)];
}

@end
