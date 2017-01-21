//
//  DateUtils.h
//  Gathr
//
//  Created by Ping Ahn(Alex) on 5/8/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSDate *)convertGMTtoLocal:(NSDate *)date;
+ (NSDate *)convertLocaltoGMT:(NSDate *)date;
+ (int)getDiffMinsFromDate:(NSDate *)fromDate;
+ (NSString *)getDiffTimeFromDate:(NSDate *)fromDate;
+ (int)getDiffMinsBetweenTwoDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSString *)getDiffTimeBetweenTwoDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSDate *)beginningOfDay:(NSDate *)date;
+ (NSDate *)endOfDay:(NSDate *)date;
+ (NSString *)getTimeFromDate:(NSDate *)date;
+ (NSString *)getDateStringFromDateType1:(NSDate *)date;
+ (NSString *)getDateStringFromDateType2:(NSDate *)date;
+ (BOOL)isDateIn24HoursAgoFromNow:(NSDate *)now Date:(NSDate *)date;

#pragma mark - DatePicker Input Accessory View
+ (UIDatePicker *)setupDatePickerInputViewByDatePickerMode:(UIDatePickerMode)datePickerMode
                                               textControl:(UITextField *)textControl
                                                withTarget:(id)target
                              selectorForDatePickerChanged:(SEL)selectorDatePickerChanged
                                         selectorForCancel:(SEL)selectorCancel
                                           selectorForDone:(SEL)selectorDone;

@end
