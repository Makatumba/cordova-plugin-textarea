var exec = require('cordova/exec');

function TextArea() {}

TextArea.openTextView = function(titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText, successCallback, errorCallback) {
  exec(successCallback, errorCallback, "TextArea", "openTextView", [titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText]);
}
TextArea.saveToDraft = function(text) {
  cordova.fireWindowEvent('TextArea.saveToDraft', {
    text: text
  });
}

module.exports = TextArea;
