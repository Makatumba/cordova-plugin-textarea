/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "TextArea.h"

@implementation MyTextAttachment
@end

@implementation TextAreaNavController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];

    // The tint color to apply to the navigation bar background.
    self.navigationBar.barTintColor = [UIColor colorWithRed:(39/255.0) green:(71/255.0) blue:(92/255.0) alpha:1];
    self.navigationBar.translucent = NO;
    // The tint color to apply to the navigation items and bar button items.
    self.navigationBar.tintColor = [UIColor whiteColor];

    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

}

@end

@interface TextArea()<UITextViewDelegate> {

    NSString* titleString;
    NSString* confirmButtonString;
    NSString* cancelButtonString;
    NSString* placeHolderString;
    NSString* bodyText;
    BOOL isRichText;

    TextAreaNavController* navController;
    UITextView* textView;
    UILabel* placeholder;
    CGRect originalTextViewFrame;
    UISwipeGestureRecognizer* swipeGesture;
    UIColor* themeColor;
    UIBarButtonItem *confirmBarBtnItem;
}

@end

@implementation TextArea

- (void)openTextView:(CDVInvokedUrlCommand*)command {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    themeColor = [UIColor colorWithRed:(39/255.0) green:(71/255.0) blue:(92/255.0) alpha:1];

    self.currentCallbackId = command.callbackId;

    titleString = command.arguments[0];
    confirmButtonString = command.arguments[1];
    cancelButtonString = command.arguments[2];
    placeHolderString = command.arguments[3];
    bodyText = command.arguments[4];

    UIFont* textFont = [UIFont fontWithName:@"STHeitiSC-Light" size:16];

    // create controllers
    UIViewController* viewController = [[UIViewController alloc] init];
    navController = [[TextAreaNavController alloc] initWithRootViewController:viewController];

    // create view
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, viewController.view.frame.size.width-20, viewController.view.frame.size.height-10)];
    [textView becomeFirstResponder];

    // for keyboard hide
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [textView addGestureRecognizer:swipeGesture];

    // load body for textView and add border
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 0;
    paragraphStyle.firstLineHeadIndent = 0;
    paragraphStyle.tailIndent = 0;
    NSDictionary *attrsDictionary = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:paragraphStyle};
    [textView setDelegate:self];
    [textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [textView setTintColor:themeColor];
    //[textView setFont:textFont];
    //[textView setTextColor:[UIColor blackColor]];

    textView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attrsDictionary];
    textView.text = bodyText;

    [viewController setTitle:titleString];

    [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];

    UIBarButtonItem* cancelBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:cancelButtonString style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];
    //[cancelBarBtnItem setTintColor:[UIColor grayColor]];
    confirmBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:confirmButtonString style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnPressed:)];

    [navController.topViewController.navigationItem setLeftBarButtonItem:cancelBarBtnItem animated:NO];
    [navController.topViewController.navigationItem setRightBarButtonItem:confirmBarBtnItem animated:NO];

    // add view
    [viewController.view addSubview:textView];

    // add placeholder
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, viewController.view.frame.size.width, 18)];
    //placeholder.font = textFont;
    placeholder.textColor = [UIColor lightGrayColor];
    placeholder.text = placeHolderString;
    placeholder.backgroundColor = [UIColor clearColor];

    if (![bodyText isEqualToString:@""]) {
        placeholder.hidden = YES;
        //[confirmBarBtnItem setTintColor:themeColor];
    }

    [textView addSubview:placeholder];

    viewController.view.backgroundColor = [UIColor whiteColor];
    navController.textView = textView;

    // present the controller
    [self.viewController presentViewController:navController animated:YES completion:NULL];
}

#pragma Actions

- (NSString *)getPlainString
{
    // final plain text
    NSMutableString* plainString = [NSMutableString stringWithString:textView.attributedText.string];
    // substitute the offset of the subscript
    __block NSUInteger base = 0;
    // traversing
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:0
                                     usingBlock:^(id value, NSRange range, BOOL *stop) {
                                         // Check whether the type is the NSTextAttachment class
                                         if (value && [value isKindOfClass:[MyTextAttachment class]]) {
                                             // replace
                                             MyTextAttachment* myAttachment = (MyTextAttachment *) value;
                                             NSString* imgStr = [NSString stringWithFormat:@"<img src=\"%@\" width=\"%d\" height=\"%d\">", myAttachment.filePath, (int)myAttachment.image.size.width, (int)myAttachment.image.size.height];
                                             [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:imgStr];
                                             // Increase the offset
                                             base += imgStr.length - 1;
                                         }
                                     }];
    return plainString;
}

-(void)handleGesture:(UIGestureRecognizer*)gesture
{
    [textView resignFirstResponder];
}

- (void)cancelBtnPressed: (id) sender {
        [self canceled];
        return;
}

- (void)canceled {
    [textView resignFirstResponder];
    [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
        [self removeObservers];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
    }];
}

- (void)confirmBtnPressed: (id) sender {
    [textView resignFirstResponder];
    NSString *sendingString = @"";
    sendingString = [self getPlainString];
    NSMutableDictionary* textResult = [NSMutableDictionary dictionaryWithDictionary:@{@"text":sendingString}];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:textResult];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];

    [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
        [self removeObservers]; //closed
    }];
}

- (void) removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textView removeGestureRecognizer:swipeGesture];
}

#pragma TextView Delegate methods

- (void)textViewDidChange:(UITextView *)tView
{
    if (tView.attributedText.length == 0) {
        placeholder.hidden = NO;
    } else {
        placeholder.hidden = YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)tView
{
    [tView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)tView
{
    [tView resignFirstResponder];
}

#pragma keyboard Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:NO];
}

- (void)moveTextViewForKeyboard:(NSNotification*)notification up:(BOOL)up {

    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;

    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.viewController.view convertRect:keyboardRect fromView:nil];

    if (up == YES) {
        CGRect newTextViewFrame = textView.frame;
        originalTextViewFrame = textView.frame;
        newTextViewFrame.size.height = originalTextViewFrame.size.height - keyboardRect.size.height;

        textView.frame = newTextViewFrame;
    } else {
        // Keyboard is going away (down) - restore original frame
        textView.frame = originalTextViewFrame;
    }

    [UIView commitAnimations];
}

@end
