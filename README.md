# Cordova-Plugin-TextArea for iOS

This is a native Text editor for iOS.

## Install
To install this plugin run:
```
cordova plugin add https://github.com/smartcrm/cordova-plugin-textarea
```

## Usage

```
TextArea.openTextView(titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText, successCallback, errorCallback);
```

To disable cancel button pass an empty string as `cancelButtonString` value.

## Known Issues
- [All]: Textarea cursor become sometimes invisible
- [iPhone]: TextArea is approx. 20 points above the keyboard in landscape mode
