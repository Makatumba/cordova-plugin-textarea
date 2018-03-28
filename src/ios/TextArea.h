#import <Cordova/CDV.h>

@interface TextArea : CDVPlugin

- (void)openTextView:(CDVInvokedUrlCommand*)command;

@property (nonatomic, copy) NSString* currentCallbackId;

@end

@interface TextAreaNavController : UINavigationController

@property (nonatomic, copy) UIColor* barTintColor;
@property (nonatomic) UITextView* textView;

@end

@interface MyTextAttachment : NSTextAttachment

@property (nonatomic, copy) NSString* filePath;

@end
