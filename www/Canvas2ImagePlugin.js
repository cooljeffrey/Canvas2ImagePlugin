//
//  Canvas2ImagePlugin.js
//  Canvas2ImagePlugin PhoneGap/Cordova plugin
//
//  Created by Tommy-Carlos Williams on 29/03/12.
//  Copyright (c) 2012 Tommy-Carlos Williams. All rights reserved.
//  MIT Licensed
//

module.exports = {
    IMAGE_TYPE: {
        'PNG': 1,
        'JPEG': 2
    },
    saveImageDataToLibrary: function (successCallback, failureCallback, canvasId) {
        // successCallback required
        if (typeof successCallback != "function") {
            console.log("Canvas2ImagePlugin Error: successCallback is not a function");
        }
        else if (typeof failureCallback != "function") {
            console.log("Canvas2ImagePlugin Error: failureCallback is not a function");
        }
        else {
            var canvas = (typeof canvasId === "string") ? document.getElementById(canvasId) : canvasId;
            var imageData = canvas.toDataURL().replace(/data:image\/png;base64,/, '');
            return cordova.exec(successCallback, failureCallback, "Canvas2ImagePlugin", "saveImageDataToLibrary", [imageData]);
        }
    },
    saveImageDataUrlToLibrary: function (successCallback, failureCallback, dataUrl, mimeType, folder, filename) {
        // successCallback required
        if (typeof successCallback != "function") {
            console.log("Canvas2ImagePlugin Error: successCallback is not a function");
        }
        else if (typeof failureCallback != "function") {
            console.log("Canvas2ImagePlugin Error: failureCallback is not a function");
        }
        else {
            var imageData = '';
            if(mimeType == 1){
                imageData = dataUrl.replace(/data:image\/png;base64,/, '');
            }else if (mimeType == 2){
                imageData = dataUrl.replace(/data:image\/jpeg;base64,/, '');
            }else {
                imageData = dataUrl.replace(/data:image\/png;base64,/, '');
            }
            var params = [];
            params.push(imageData);
            params.push(folder || "");
            params.push(filename || "");
            return cordova.exec(successCallback, failureCallback, "Canvas2ImagePlugin", "saveImageDataToLibrary", params);
        }
    }
};

  

