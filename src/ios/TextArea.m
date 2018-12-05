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
UIColor *barTintColor;

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
    
    // The tint color to apply to the navigation bar background.
    self.navigationBar.barTintColor = barTintColor;
    self.navigationBar.translucent = NO;
    // The tint color to apply to the navigation items and bar button items.
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationBar setTitleTextAttributes:@ {NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
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
    UIBarButtonItem *cancelBarBtnItem;
    
    BOOL _isKeyboardVisible;
}

@end

@implementation TextArea

- (void)openTextView:(CDVInvokedUrlCommand*)command {
    // read js parameters
    [self setCommandProperties:command];
    
    // setup
    [self setupViewController];
    
    // present the controller
    [self.viewController presentViewController:navController animated:YES completion:NULL];
    
    // set keyboard events
    [self setupKeyboardEventsAndGestures];
}

- (void)setCommandProperties:(CDVInvokedUrlCommand*)command {
    self.currentCallbackId = command.callbackId;
    
    // reading arguments from js
    titleString = command.arguments[0];
    confirmButtonString = command.arguments[1];
    cancelButtonString = command.arguments[2];
    placeHolderString = command.arguments[3];
    bodyText = command.arguments[4];
    barTintColor = [self colorFromHexString:command.arguments[5]];
}

- (void)setupViewController {
    // create controllers
    UIViewController* viewController = [[UIViewController alloc] init];
    navController = [[TextAreaNavController alloc] initWithRootViewController:viewController];
    
    // create view
    textView = [self getTextView:viewController];
    
    // config title bar
    [self setupHeaderBar:viewController];
    
    // add view
    [viewController.view addSubview:textView];
    
    // add placeholder
    [textView addSubview:[self getConfiguredPlaceHolder:viewController]];
    
    viewController.view.backgroundColor = [UIColor whiteColor];
    navController.textView = textView;
}

- (void)setupHeaderBar:(UIViewController*)viewController {
    [viewController setTitle:titleString];
    
    [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    // buttons
    // confirm button
    confirmBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:confirmButtonString style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnPressed:)];
    [navController.topViewController.navigationItem setLeftBarButtonItem:confirmBarBtnItem animated:NO];
    
    //cancel button
    if (![cancelButtonString isEqualToString:@""]) {
        cancelBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:cancelButtonString style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];
        [navController.topViewController.navigationItem setRightBarButtonItem:cancelBarBtnItem animated:NO];
    }
}

- (UITextView*)getTextView:(UIViewController*)viewController {
    UITextView* _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, viewController.view.frame.size.width-20, viewController.view.frame.size.height-10)];
    [_textView becomeFirstResponder];
    
    [_textView setDelegate:self];
// this removes iOS 10 support but fixes an error on iOS 11.4.
// this check seems to still work on iOS 12.1.1 wtf o0
//    if ([self respondsToSelector:@selector(pasteDelegate)]) {
    _textView.pasteDelegate = self;
//    }
    [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_textView setTintColor:[UIColor blackColor]];
    
    [_textView setTextColor:[UIColor blackColor]];
    
    _textView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:[self getAttrsDictionary]];
    _textView.text = bodyText;
    
    // prevent scrolling to the end of the document, by setting cursor position to the beginning of the document.
    UITextPosition *beginning = [_textView beginningOfDocument];
    [_textView setSelectedTextRange:[textView textRangeFromPosition:beginning toPosition:beginning]];
    return _textView;
}

- (NSDictionary*)getAttrsDictionary {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 0;
    paragraphStyle.firstLineHeadIndent = 0;
    paragraphStyle.tailIndent = 0;
    NSDictionary *attrsDictionary = @ {NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:16], NSParagraphStyleAttributeName:paragraphStyle};
    return attrsDictionary;
}

- (UILabel*)getConfiguredPlaceHolder:(UIViewController*)viewController {
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, viewController.view.frame.size.width, 18)];
    
    placeholder.textColor = [UIColor lightGrayColor];
    placeholder.text = placeHolderString;
    placeholder.backgroundColor = [UIColor clearColor];
    
    if (![bodyText isEqualToString:@""]) {
        placeholder.hidden = YES;
    }
    
    return placeholder;
}

- (void)setupKeyboardEventsAndGestures {
    // registring keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // swipe down to hide keyboard
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [textView addGestureRecognizer:swipeGesture];
}

#pragma Actions

- (void)handleGesture:(UIGestureRecognizer*)gesture {
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
    sendingString = [NSMutableString stringWithString:textView.attributedText.string];
    NSMutableDictionary* textResult = [NSMutableDictionary dictionaryWithDictionary:@ {@"text":sendingString}];
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

//Set a Hook to know there's a paste action while I'm the first responder - fired when Paste was tapped
- (void)textPasteConfigurationSupporting:(id<UITextPasteConfigurationSupporting>)textPasteConfigurationSupporting transformPasteItem:(id<UITextPasteItem>)item API_AVAILABLE(ios(11.0)) {
    [self paste:textPasteConfigurationSupporting];
}

//generic paste action handler
- (void)paste:(id)sender {
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    if ([gpBoard hasStrings]) {
        id<UITextPasteConfigurationSupporting> pasteItem = (id<UITextPasteConfigurationSupporting>)sender;
        if ([pasteItem isKindOfClass:[UITextView class]]) {
            UITextView* myTextView = (UITextView*)pasteItem;
            [myTextView insertText:[gpBoard string]];
        }
    }
}

- (void)textViewDidChange:(UITextView *)tView {
    if (tView.attributedText.length == 0) {
        placeholder.hidden = NO;
    } else {
        placeholder.hidden = YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)tView {
    [tView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)tView {
    [tView resignFirstResponder];
}

#pragma keyboard Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    [self keyboardDidShow];
    [self setNewTextViewHeight:notification];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self keyboardDidHide];
    [self setNewTextViewHeight:notification];
}


- (void)setNewTextViewHeight:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.viewController.view convertRect:keyboardRect fromView:nil];
    
    // removing additional 70points for correct calculation
    [textView setFrame:CGRectMake(CGRectGetMinX(textView.frame), CGRectGetMinY(textView.frame), CGRectGetWidth(textView.frame), CGRectGetMinY(keyboardRect) - 70)];
    
    [UIView commitAnimations];
}

- (BOOL)isKeyboardVisible {
    return _isKeyboardVisible;
}

- (void)keyboardDidShow {
    _isKeyboardVisible = YES;
}

- (void)keyboardDidHide {
    _isKeyboardVisible = NO;
}

// Color conversion from hex to uicolor
// https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
