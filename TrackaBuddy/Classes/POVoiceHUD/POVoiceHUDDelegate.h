//
//  POVoiceHUDDelegate.h
//  POVoiceHUD
//


#import <Foundation/Foundation.h>

@class POVoiceHUD;

@protocol POVoiceHUDDelegate <NSObject>

@optional

- (void)POVoiceHUD:(POVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength;
- (void)voiceRecordCancelledByUser:(POVoiceHUD *)voiceHUD;

@end

