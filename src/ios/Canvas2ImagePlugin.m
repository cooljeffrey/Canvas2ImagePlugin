//
//  Canvas2ImagePlugin.m
//  Canvas2ImagePlugin PhoneGap/Cordova plugin
//
//  Created by Tommy-Carlos Williams on 29/03/12.
//  Copyright (c) 2012 Tommy-Carlos Williams. All rights reserved.
//	MIT Licensed
//
//Updated to return file path in success callback

#import "Canvas2ImagePlugin.h"
#import <Cordova/CDV.h>

@implementation Canvas2ImagePlugin
@synthesize callbackId;

//-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
//{
//    self = (Canvas2ImagePlugin*)[super initWithWebView:theWebView];
//    return self;
//}

- (void)saveImageDataToLibrary:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    NSString* imageDataUrl = [command.arguments objectAtIndex:0];
    NSString* folderName = [command.arguments objectAtIndex:1];
//    NSString* filename = [command.arguments objectAtIndex:2];

	NSData* imageData = [NSData cdv_dataFromBase64String: imageDataUrl];
	UIImage* image = [[[UIImage alloc] initWithData:imageData] autorelease];
    
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    __block ALAssetsGroup* groupToAddTo;
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
       usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
           if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:folderName]) {
               NSLog(@"found album %@", folderName);
               groupToAddTo = group;
               [self saveImageToAlbum:library image:image groupToAddTo:groupToAddTo command:command];
           }
       }
     failureBlock:^(NSError* error) {
         NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
         [library addAssetsGroupAlbumWithName:folderName
          resultBlock:^(ALAssetsGroup *group) {
              NSLog(@"added album:%@", folderName);
              [self saveImageToAlbum:library image:image groupToAddTo:group command:command];
          }
         failureBlock:^(NSError *error) {
             NSLog(@"error adding album");
             [library release];
             CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
             [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
         }];
     }];
}

- (void) saveImageToAlbum:(ALAssetsLibrary*) library image:(UIImage*) image groupToAddTo:(ALAssetsGroup*) groupToAddTo command:(CDVInvokedUrlCommand*)command
{
    [library writeImageToSavedPhotosAlbum: image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
        if (error)
        {
            // Show error message...
            NSLog(@"ERROR: %@",error);
            [library release];
            CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        else
        {
            // Show message image successfully saved
            NSLog(@"Saved URL : %@", assetURL);
            // try to get the asset
            [library assetForURL:assetURL
                     resultBlock:^(ALAsset *asset) {
                         // assign the photo to the album
                         [groupToAddTo addAsset:asset];
                         NSLog(@"Added %@ to %@", assetURL, [groupToAddTo valueForProperty:ALAssetsGroupPropertyName]);
                         [library release];
                         CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:[assetURL absoluteString]];
                         [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                     }
                    failureBlock:^(NSError* error) {
                        NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                        [library release];
                        CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
                        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                    }];
        }
    }];
}
- (void)dealloc
{
	[callbackId release];
    [super dealloc];
}


@end
