//
//  BasicAI.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "TestController.h"

TestController::TestController(NSImageView* processedImageView, NSImageView *unprocessedImageView, NSImageView* targetImageView, NSImageView* foundImage, NSTextView* logText) {
    this->processedImageView = processedImageView;
    this->unprocessedImageView = unprocessedImageView;
    this->targetImageView = targetImageView;
    this->foundImageView = foundImage;
    this->logText = logText;
    testImage.imageData = NULL;
    playButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(1) Play Button" ofType:@"png"]);
    
    testGame1 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame1" ofType:@"png"]);
    testGame2 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame2" ofType:@"png"]);
    
    [targetImageView setImage:getImageFromBGRABuffer(testGame1.imageData, testGame1.imageWidth, testGame1.imageHeight)];
}
void TestController::copyScreenShot(uint8 *baseAddress, int bufferWidth, int bufferHeight) {
    if (testImage.imageData != NULL) {
        free(testImage.imageData);
    }
    testImage.imageWidth = bufferWidth;
    testImage.imageHeight = bufferHeight;
    testImage.imageData = copyImageBuffer(baseAddress, bufferWidth, bufferHeight);
    //Screenshot copied as BGRA
    
    displayPreprocessedScreenShot();
}
void TestController::displayPreprocessedScreenShot() {
    NSImage* image = getImageFromBGRABuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testPlayButton() {
    [targetImageView setImage:getImageFromBGRABuffer(playButton.imageData, playButton.imageWidth, playButton.imageHeight)];
    log(@"Testing Play Button Detection...");
    uint64 startTime = mach_absolute_time();
    double returnPercentage;
    Position playLocation;
    detectExactImageToImage(playButton, testImage, 0, 0, testImage.imageWidth, testImage.imageHeight, returnPercentage, playLocation, 0.5, true);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Location: %d, %d with percentage %f%% and took %f seconds", playLocation.x, playLocation.y, returnPercentage*100, getTimeInMilliseconds(endTime-startTime)/1000.0]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            if ((x < playLocation.x || x > playLocation.x+playButton.imageWidth) || (y < playLocation.y || y > playLocation.y+playButton.imageHeight)) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, playLocation.x, playLocation.y, playButton.imageWidth, playButton.imageHeight);
    [foundImageView setImage: getImageFromBGRABuffer(image2, playButton.imageWidth, playButton.imageHeight)];
}

void TestController::testGameImage1() {
    
    [targetImageView setImage:getImageFromBGRABuffer(testGame1.imageData, testGame1.imageWidth, testGame1.imageHeight)];
    log(@"Testing Game Image 1 Detection...");
    uint64 startTime = mach_absolute_time();
    double returnPercentage;
    Position playLocation;
    detectExactImageToImage(testGame1, testImage, 0, 0, testImage.imageWidth, testImage.imageHeight, returnPercentage, playLocation, 0.5, true);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Location: %d, %d with percentage %f%% and took %f seconds", playLocation.x, playLocation.y, returnPercentage*100, getTimeInMilliseconds(endTime-startTime)/1000.0]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            if ((x < playLocation.x || x > playLocation.x+testGame1.imageWidth) || (y < playLocation.y || y > playLocation.y+testGame1.imageHeight)) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, playLocation.x, playLocation.y, testGame1.imageWidth, testGame1.imageHeight);
    [foundImageView setImage: getImageFromBGRABuffer(image2, testGame1.imageWidth, testGame1.imageHeight)];
}

void TestController::log(NSString* string) {
    [[logText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]]];
    [logText scrollRangeToVisible: NSMakeRange(logText.string.length, 0)];
}
