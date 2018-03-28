var exec = require('cordova/exec');

function TextArea() {}

TextArea.openTextView = function(titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText, successCallback, errorCallback) {
  exec(successCallback, errorCallback, "TextArea", "openTextView", [titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText, '#3B8EB9']);
}
TextArea.saveToDraft = function(text) {
  cordova.fireWindowEvent('TextArea.saveToDraft', {
    text: text
  });
}

module.exports = TextArea;
