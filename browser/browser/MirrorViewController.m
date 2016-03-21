//
//  MirrorViewController.m
//  MyHelper
//
//  Created by zhaolu  on 15-3-5.
//  Copyright (c) 2015年 myHelper. All rights reserved.
//

#import "MirrorViewController.h"

@interface MirrorViewController ()
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat topX;
    CGFloat topY;
    BOOL isImageResized;
    BOOL isSaveWaitingForResizedImage;
    BOOL isCapturingImage;
    //
    UIImagePickerController *imagePickerVC;
}

@end

@implementation MirrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
//        [self setup];
//    }
//    else {
//        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//        switch (status) {
//            case AVAuthorizationStatusAuthorized:
//                [self setup];
//                break;
//            default:
//                break;
//        }
//        
//    }
    if (IOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    
    imagePickerVC = [[UIImagePickerController alloc] init];
    [imagePickerVC setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePickerVC setShowsCameraControls:NO];
    imagePickerVC.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    imagePickerVC.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    imagePickerVC.cameraViewTransform = CGAffineTransformScale(imagePickerVC.cameraViewTransform, scale, scale);
    [self.view addSubview:imagePickerVC.view];
    
    UIImage *image =  [UIImage imageNamed:@"nav_categoryIcon.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(10, 18, image.size.width/2, image.size.height/2);
    [self.view addSubview:btn];
}

-(void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:{
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开失败" message:@"请在\"设置-->隐私-->相机\"中\"应用宝贝\"对应的开关调为打开状态，然后再次尝试" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
    }
            break;
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(!granted){
               UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"打开失败" message:@"请在\"设置-->隐私-->相机\"中\"应用宝贝\"对应的开关调为打开状态，然后再次尝试"  delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [alert1 show];
                } 
            }];
    }
            break;
           default:
            break;
    
    }
    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
//        // Pre iOS 8 -- No camera auth required.
//        [self animateIntoView];
//    }
//    else {
//        __block UIAlertView *alert = nil;
//        // iOS 8
//        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//        switch (status) {
//            case AVAuthorizationStatusDenied:
//            case AVAuthorizationStatusRestricted:
//                alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not authorized or restricted, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                [alert show];
//                break;
//            case AVAuthorizationStatusAuthorized:
//                [self animateIntoView];
//                break;
//            case AVAuthorizationStatusNotDetermined: {
//                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                    if(granted){
//                        [self setup];
//                        [self animateIntoView];
//                    } else {
//                        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not authorized or restricted, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                        [alert show];
//                        [self cleanupCameraSession];
//                    }
//                }];
//            }
//            default:
//                break;
//        }
//    }
}

#pragma mark alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
  
}



- (void) animateIntoView
{
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _imageStreamV.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DeLog(@"DID RECEIVE MEMORY WARNING");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - CAMARA SETUP

- (void) setup {
    
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat currentWidth = CGRectGetWidth(screen);
    CGFloat currentHeight = CGRectGetHeight(screen);
    screenWidth = currentWidth < currentHeight ? currentWidth : currentHeight;
    screenHeight = currentWidth < currentHeight ? currentHeight : currentWidth;
    if (_imageStreamV == nil) _imageStreamV = [[UIView alloc]init];
    _imageStreamV.alpha = 0;
    _imageStreamV.frame = self.view.bounds;
    
    if (_capturedImageV == nil) _capturedImageV = [[UIImageView alloc]init];
    _capturedImageV.frame = _imageStreamV.frame; // just to even it out
    _capturedImageV.backgroundColor = [UIColor clearColor];
    _capturedImageV.userInteractionEnabled = YES;
    _capturedImageV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:_capturedImageV belowSubview:self.toolBar];
    [self.view insertSubview:_imageStreamV belowSubview:_capturedImageV];
    _mirrorTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toogleCapturePhoto)];
    _mirrorTap.numberOfTapsRequired = 1;
    [_capturedImageV addGestureRecognizer:_mirrorTap];
    if (_mySesh == nil) _mySesh = [[AVCaptureSession alloc] init];
    _mySesh.sessionPreset = AVCaptureSessionPresetPhoto;
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_mySesh];
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.frame = _imageStreamV.layer.bounds; // parent of layer
    [_imageStreamV.layer addSublayer:_captureVideoPreviewLayer];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No devices found with camera." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
    } else {
        _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    }
    if ([_myDevice isFlashAvailable] && _myDevice.flashActive && [_myDevice lockForConfiguration:nil]) {
        _myDevice.flashMode = AVCaptureFlashModeOff;
        [_myDevice unlockForConfiguration];
    }
    
    NSError * error = nil;
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:&error];
    if (!input) {
        NSString *errorMsg = [NSString stringWithFormat:@"Error: trying with camera input: %@", error];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    [_mySesh addInput:input];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_mySesh addOutput:_stillImageOutput];
    [_mySesh startRunning];
}


- (void) toogleCapturePhoto {
    if (_isHiddenControls) {
        [self capturePhoto];
    } else {
        [self showCamera];
    }
}

- (void) showCamera {
    [self cleanCaptureView];
}

- (void) capturePhoto {
    if (isCapturingImage) {
        return;
    }
    if (!_isHiddenControls) {
        return;
    }
    
    isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if(!CMSampleBufferIsValid(imageSampleBuffer))
         {
             return;
         }
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage * capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
         isCapturingImage = NO;
         isImageResized = NO;
         _capturedImageV.image = capturedImage;
         imageData = nil;
     }];
}

#pragma mark - RESIZE IMAGE

- (void) resizeImage {
    CGSize size = CGSizeMake(screenWidth, screenHeight);
    CGRect drawRect = ({
        CGFloat targetWidth = screenHeight * 0.75; //
        CGFloat offsetTop = (screenHeight - size.height) / 2;
        CGFloat offsetLeft = (targetWidth - size.width) / 2;
        CGRectMake(-offsetLeft, -offsetTop, targetWidth, screenHeight);
    });
    
    // START CONTEXT
    UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
    [_capturedImageV.image drawInRect:drawRect];
    _capturedImageV.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // END CONTEXT
    
    isImageResized = YES;
}

#pragma mark CLEAN CAPTURE IMAGE AND SETTINGS

- (void) cleanCaptureView {
    if (_capturedImageV.image) {
        _capturedImageV.contentMode = UIViewContentModeScaleAspectFill;
        _capturedImageV.backgroundColor = [UIColor clearColor];
        _capturedImageV.image = nil;
        
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
    }
}

- (void) cleanupCameraSession {
    
    // Clean Up
    isImageResized = NO;
    isSaveWaitingForResizedImage = NO;
    
    [_mySesh stopRunning];
    _mySesh = nil;
    
    _capturedImageV.image = nil;
    [_capturedImageV removeFromSuperview];
    _capturedImageV = nil;
    
    [_imageStreamV removeFromSuperview];
    _imageStreamV = nil;
    
    _stillImageOutput = nil;
    _myDevice = nil;
}

#pragma mark - SAVE PHOTO

- (void)saveImageToPhotoAlbum {
    UIImageWriteToSavedPhotosAlbum(_capturedImageV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - SHARE PHOTO

- (void)sharePhotoImage {
    
    UIImage *shareImage = _capturedImageV.image;
    
    NSArray *items = @[shareImage];
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    //check to display Popover on iPad or present view on iPhone
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {//iPad
        
        //iOS8 fix sourceview for Popover
        if ([activity respondsToSelector:@selector(popoverPresentationController)] ) {
            activity.popoverPresentationController.sourceView = self.view;
        }
        if (self.sharePopoverController.popoverVisible) {
            [self.sharePopoverController dismissPopoverAnimated:YES];
            return;
        }
        if (!self.sharePopoverController) {
            self.sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:activity];
        }
        self.sharePopoverController.delegate = self;
        
    } else {

        [self presentViewController:activity animated:YES completion:nil];
        
    }
}

#pragma mark - Popover controller delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    //reset popover
    self.sharePopoverController = nil;
}

#pragma mark - BUTTON ACTIONS


- (void) savePhotoResized {
    if (!isImageResized) {
        isSaveWaitingForResizedImage = YES;
        [self resizeImage];
    }
    [self saveImageToPhotoAlbum];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end