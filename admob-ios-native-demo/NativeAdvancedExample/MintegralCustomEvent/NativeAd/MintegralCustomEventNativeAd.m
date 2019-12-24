//
//  MintegralCustomEventNativeAd.m
//  MediationExample
//
//  Copyright © 2017年 Mintegral. All rights reserved.
//

#import "MintegralCustomEventNativeAd.h"
#import <MTGSDK/MTGSDK.h>
#import "MintegralMediatedNativeAd.h"
#import "MintegralHelper.h"


@interface MintegralCustomEventNativeAd()<MTGNativeAdManagerDelegate>{
    GADNativeAdViewAdOptions *_nativeAdViewAdOptions;
}

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property (nonatomic, readwrite, strong) NSArray *adTypes;

@property (nonatomic, readwrite, copy) NSString * localNativeUnitId;
@property (nonatomic) BOOL video_enabled;
@property (nonatomic) BOOL shouldDownloadImage;

@end



@implementation MintegralCustomEventNativeAd

@synthesize delegate;


- (void)requestNativeAdWithParameter:(NSString *)serverParameter
                             request:(GADCustomEventRequest *)request
                             adTypes:(NSArray *)adTypes
                             options:(NSArray *)options
                  rootViewController:(UIViewController *)rootViewController
{
    NSLog(@"requestNativeAdWithParameter");
    BOOL requestedUnified = [adTypes containsObject:kGADAdLoaderAdTypeUnifiedNative];
    
    if (!requestedUnified) {
        NSString *description = @"You must request the unified native ad format.";
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        NSError *error =
        [NSError errorWithDomain:kMintegralAdapterErrorDomain code:0 userInfo:userInfo];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];
        return;
    }
    
    for (GADAdLoaderOptions *loaderOptions in options) {
        if ([loaderOptions isKindOfClass:[GADNativeAdImageAdLoaderOptions class]]) {
            GADNativeAdImageAdLoaderOptions *imageOptions =
            (GADNativeAdImageAdLoaderOptions *)loaderOptions;
        
            
            // If the GADNativeAdImageAdLoaderOptions' disableImageLoading property is YES, the adapter
            // should send just the URLs for the images.
                 self.shouldDownloadImage = !imageOptions.disableImageLoading;
        } else if ([loaderOptions isKindOfClass:[GADNativeAdViewAdOptions class]]) {
            _nativeAdViewAdOptions = (GADNativeAdViewAdOptions *)loaderOptions;
        }
    }
    
    NSDictionary *mintegralInfoDict = [MintegralHelper dictionaryWithJsonString:serverParameter];
    
    NSString *appId = nil;
    if ([mintegralInfoDict objectForKey:@"appId"]) {
        appId = [mintegralInfoDict objectForKey:@"appId"];
    }
    
    NSString *appKey = nil;
    if ([mintegralInfoDict objectForKey:@"appKey"]) {
        appKey = [mintegralInfoDict objectForKey:@"appKey"];
    }
    
    if (![MintegralHelper isSDKInitialized]) {
        
        
        //init SDK
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralHelper sdkInitialized];
    }
    
    if ([mintegralInfoDict objectForKey:@"unitId"]) {
        _localNativeUnitId = [mintegralInfoDict objectForKey:@"unitId"];
    }
    NSString *fbPlacementId = nil;
    if ([mintegralInfoDict objectForKey:@"fbPlacementId"]) {
        fbPlacementId = [mintegralInfoDict objectForKey:@"fbPlacementId"];
    }
    
    NSUInteger numsOfAdsRequest = 1;
    if ([mintegralInfoDict objectForKey:@"numsOfAdsRequest"]) {
        numsOfAdsRequest = [[mintegralInfoDict objectForKey:@"numsOfAdsRequest"] unsignedIntegerValue];
    }
    
    BOOL autoCacheImage = YES;
    if ([mintegralInfoDict objectForKey:@"autoCacheImage"]) {
        autoCacheImage = [[mintegralInfoDict objectForKey:@"autoCacheImage"] boolValue];
    }
    
    //get video parameter
    _video_enabled = YES;
    if ([mintegralInfoDict objectForKey:@"video_enabled"]) {
        _video_enabled = [[mintegralInfoDict objectForKey:@"video_enabled"] boolValue];
    }
    //add num parameter
    MTGAdTemplateType reqNum = [mintegralInfoDict objectForKey:@"reqNum"] ? [[mintegralInfoDict objectForKey:@"reqNum"] integerValue]:1;
    
    MTGAdCategory adCategory = MTGAD_CATEGORY_ALL;
    if ([mintegralInfoDict objectForKey:@"adCategory"]) {
        adCategory = [[mintegralInfoDict objectForKey:@"adCategory"] integerValue];
    }
    
    MTGAdTemplateType templateType = MTGAD_TEMPLATE_BIG_IMAGE;
    if ([mintegralInfoDict objectForKey:@"templateType"]) {
        templateType = [[mintegralInfoDict objectForKey:@"templateType"] integerValue];
    }
    
    MTGTemplate *template = [MTGTemplate templateWithType:templateType adsNum:1];
    NSArray *templates = @[template];
    
    self.adTypes = adTypes;
    
    if(_video_enabled){
        self.mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithUnitID:_localNativeUnitId fbPlacementId:fbPlacementId
                                                                videoSupport:_video_enabled forNumAdsRequested: reqNum
                                                    presentingViewController:nil];
    }else{
        self.mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithUnitID:_localNativeUnitId fbPlacementId:fbPlacementId  supportedTemplates:templates autoCacheImage:autoCacheImage adCategory:adCategory presentingViewController:nil];
    }
    
    self.mtgNativeAdManager.delegate = self;
    [self.mtgNativeAdManager loadAds];
}


#pragma mark - nativeAdManager delegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds {
    
    if (nativeAds.count == 0) {
        
        NSString *description = @"No Fill.";
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        NSError *error =
        [NSError errorWithDomain:customEventErrorDomain code:kGADErrorMediationNoFill userInfo:userInfo];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];
        
        return;
    }
    
    MTGCampaign *campaign = nativeAds.firstObject;
    
    MintegralMediatedNativeAd *mediatedAd = [[MintegralMediatedNativeAd alloc] initAdWithNativeManager:self.mtgNativeAdManager mtgCampaign:campaign withUnitId:self.localNativeUnitId videoSupport:self.video_enabled nativeAdViewAdOptions:_nativeAdViewAdOptions shouldDownloadImage:self.shouldDownloadImage];
    [self.delegate customEventNativeAd:self didReceiveMediatedUnifiedNativeAd:mediatedAd];
    
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
    
    NSError *customError = [NSError errorWithDomain:customEventErrorDomain code:error.code userInfo:error.userInfo];
    [self.delegate customEventNativeAd:self didFailToLoadWithError:customError];
}



- (BOOL)handlesUserClicks{
    return YES;
}


- (BOOL)handlesUserImpressions{
    return YES;
}



@end
