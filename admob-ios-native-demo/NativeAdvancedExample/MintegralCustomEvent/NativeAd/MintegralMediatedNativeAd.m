//
//  MintegralMediatedNativeAd.m
//  Admob_SampleApp
//
//  Created by Damon on 2019/11/24.
//  Copyright © 2019 Chark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MintegralMediatedNativeAd.h"
#import <MTGSDK/MTGAdChoicesView.h>

@interface MintegralMediatedNativeAd () <MTGNativeAdManagerDelegate,MTGMediaViewDelegate>

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property(nonatomic, strong) MTGCampaign *campaign;

@property (nonatomic) MTGMediaView *mediaView;
@property (nonatomic) BOOL video_enabled;
@property (nonatomic, readwrite, copy) NSString *unitId;

@property(nonatomic, copy) NSArray *mappedImages;
@property(nonatomic, strong) GADNativeAdImage *mappedIcon;
@property(nonatomic, copy) NSDictionary *extras;
@property(nonatomic, strong) NSCache *cache;

@end

@implementation MintegralMediatedNativeAd

- (nullable instancetype)initAdWithNativeManager:(MTGNativeAdManager *)nativeManager mtgCampaign:(MTGCampaign *)campaign withUnitId:(NSString *)unitId videoSupport:(BOOL)videoSupport nativeAdViewAdOptions:(GADNativeAdViewAdOptions *)nativeAdViewAdOptions shouldDownloadImage:(BOOL)shouldDownloadImage{
    
    NSLog(@"initAdWithNativeManager");
    
    if (!campaign) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        _mtgNativeAdManager = nativeManager;
        _mtgNativeAdManager.delegate = self;
        
        _cache = [[NSCache alloc] init];
        // 设置成本为5 当存储的数据超过总成本数，NSCache会自动回收对象
         _cache.totalCostLimit = 50*1024*1024;
        
//        if (shouldDownloadImage) {
//            if (campaign.imageUrl) {
//                [self loadImageWithURL:campaign.imageUrl
//                imageCache:_cache
//                  callback:^(UIImage *image) {
//                    self->_mappedImages = @[ [[GADNativeAdImage alloc] initWithImage:image] ];
//
//                  }];
//            }
//            if (campaign.iconUrl) {
//                [self loadImageWithURL:campaign.iconUrl
//                imageCache:_cache
//                  callback:^(UIImage *image) {
//                    self->_mappedIcon = [[GADNativeAdImage alloc] initWithImage:image];
//
//                  }];
//            }
//        }else{
            if (campaign.imageUrl) {
                UIImage *img;
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:campaign.imageUrl]];
                img = [UIImage imageWithData:imgData];
                _mappedImages = @[ [[GADNativeAdImage alloc] initWithImage:img] ];
            }
            
            
            if (campaign.iconUrl) {
//                iconURL = [[NSURL alloc] initWithString:campaign.iconUrl];
//                _mappedIcon = [[GADNativeAdImage alloc] initWithURL:iconURL scale:1.0];
                UIImage *icon;
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:campaign.iconUrl]];
                icon = [UIImage imageWithData:imgData];
                _mappedIcon = [[GADNativeAdImage alloc] initWithImage:icon];
            }
            
//        }
        
        _campaign = campaign;
        
        // If video ad is enabled, use mediaView, otherwise use coverImage.
        if (videoSupport) {
            [self MTGmediaView];
        }
        NSLog(@"videoSupport value: %@" ,videoSupport?@"YES":@"NO");
        _video_enabled = videoSupport;
        _unitId = unitId;
    }
    return self;
}

- (void)loadImageWithURL:(nonnull NSString *)urlString
              imageCache:(nonnull NSCache *)imageCache
                callback:(void (^)(UIImage *))callback {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSString *cacheKey = urlString;
    NSURL *url = [NSURL URLWithString:urlString];
    UIImage *cachedImage = [imageCache objectForKey:cacheKey];
    if (!cachedImage) {
      NSData *imageData = [NSData dataWithContentsOfURL:url];
      UIImage *image = [UIImage imageWithData:imageData];
      if (image) {
        cachedImage = image;
        [imageCache setObject:cachedImage forKey:cacheKey];
      }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(cachedImage);
    });
  });
}

-(void)dealloc{
    _mtgNativeAdManager.delegate = nil;
    _mtgNativeAdManager = nil;
    
    _mediaView.delegate = nil;
    _mediaView = nil;
    
    _campaign = nil;
    _unitId = nil;
    
    _mappedImages = nil;
    _mappedIcon = nil;
    _extras = nil;
}

- (NSString *)headline {
    return self.campaign.appName;
}

- (NSArray *)images {
    return self.mappedImages;
}

- (NSString *)body {
    return self.campaign.appDesc;
}

- (GADNativeAdImage *)icon {
    
    return self.mappedIcon;
}

- (NSString *)callToAction {
    return self.campaign.adCall;
}

- (NSDecimalNumber *)starRating {

    NSString *star = [NSString stringWithFormat:@"%@",[_campaign valueForKey:@"star"]];
    return [NSDecimalNumber decimalNumberWithString:star];
}

- (NSString *)store {

    return @"";
}

- (NSString *)price {
    return @"";
}


- (NSDictionary *)extraAssets {
    return self.extras;
}


- (UIView *)adChoicesView {
    if (CGSizeEqualToSize(_campaign.adChoiceIconSize, CGSizeZero)) {
        return nil;
    } else {
        MTGAdChoicesView * adChoicesView = [[MTGAdChoicesView alloc] initWithFrame:CGRectMake(0, 0, _campaign.adChoiceIconSize.width, _campaign.adChoiceIconSize.height)];
        adChoicesView.campaign = _campaign;
        return adChoicesView;
    }
  
}

//- (id<GADMediatedNativeAdDelegate>)mediatedNativeAdDelegate {
//    return self;
//}


#pragma mark - MVSDK NativeAdManager Delegate

- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd;
{
    
//report to admob
//    [GADMediatedNativeAdNotificationSource  mediatedNativeAdDidRecordClick:self];
//    [GADMediatedNativeAdNotificationSource  mediatedNativeAdWillLeaveApplication:self];
    
    [GADMediatedUnifiedNativeAdNotificationSource  mediatedNativeAdDidRecordClick:self];
    [GADMediatedUnifiedNativeAdNotificationSource  mediatedNativeAdWillLeaveApplication:self];
    
}


- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error{

//    [GADMediatedNativeAdNotificationSource mediatedNativeAdDidDismissScreen:self];
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type nativeManager:(nonnull MTGNativeAdManager *)nativeManager{
    NSLog(@"nativeAdImpressionWithType");
//    [GADMediatedNativeAdNotificationSource  mediatedNativeAdDidRecordImpression:self];
    [GADMediatedUnifiedNativeAdNotificationSource  mediatedNativeAdDidRecordImpression:self];
}
#pragma mark - GADMediatedUnifiedNativeAd

- (void)didRenderInView:(UIView *)view
       clickableAssetViews:
           (NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
    nonclickableAssetViews:
        (NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *)nonclickableAssetViews
            viewController:(UIViewController *)viewController {
//  NSArray *assets = clickableAssetViews.allValues;
//  UIImageView *iconView = nil;
//  if ([clickableAssetViews[GADUnifiedNativeIconAsset] isKindOfClass:[UIImageView class]]) {
//    iconView = (UIImageView *)clickableAssetViews[GADUnifiedNativeIconAsset];
//  }

  [_mtgNativeAdManager registerViewForInteraction:view withCampaign:_campaign];
}

- (void)didUntrackView:(UIView *)view {
  [_mtgNativeAdManager unregisterView:view];
}

- (void)didRecordImpression {
    NSLog(@"didRecordImpression");
}

- (void)didRecordClickOnAssetWithName:(GADUnifiedNativeAssetIdentifier)assetName
                                 view:(UIView *)view
                       viewController:(UIViewController *)viewController {
 NSLog(@"didRecordClickOnAssetWithName");
}
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

#pragma mark - MVMediaViewDelegate implementation

-  (UIView *GAD_NULLABLE_TYPE)mediaView{
    [_mediaView setMediaSourceWithCampaign:_campaign unitId:_unitId];
    return _mediaView;
}

- (BOOL)hasVideoContent{
    if(self.video_enabled){
        return [_mediaView isVideoContent];
    }else{
        return self.video_enabled;
    }
}

-(MTGMediaView *)MTGmediaView{
    
    if (_mediaView) {
        return _mediaView;
    }
    
    MTGMediaView *mediaView = [[MTGMediaView alloc] initWithFrame:CGRectZero];
    mediaView.delegate = self;
    _mediaView = mediaView;
    
    return mediaView;
}

@end
