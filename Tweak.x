#import <YouTubeHeader/ASCollectionElement.h>
#import <YouTubeHeader/ELMCellNode.h>
#import <YouTubeHeader/ELMNodeController.h>
#import <YouTubeHeader/YTIElementRenderer.h>
#import <YouTubeHeader/YTVideoWithContextNode.h>

%hook YTGlobalConfig

- (BOOL)shouldBlockUpgradeDialog { return YES; }

%end

%hook YTIPlayerResponse

- (BOOL)isMonetized { return NO; }

%end

%hook YTIPlayabilityStatus

- (BOOL)isPlayableInBackground { return YES; }

%end

%hook MLVideo

- (BOOL)playableInBackground { return YES; }

%end

%hook YTDataUtils

+ (id)spamSignalsDictionary { return nil; }
+ (id)spamSignalsDictionaryWithoutIDFA { return nil; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context {}

%end

%hook YTAccountScopedAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context {}

%end

%hook YTIElementRenderer

- (NSData *)elementData {
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData) return nil;
    return %orig;
}

%end

BOOL isAd(id node) {
    if ([node isKindOfClass:NSClassFromString(@"YTVideoWithContextNode")]
        && [node respondsToSelector:@selector(parentResponder)]
        && [[(YTVideoWithContextNode *)node parentResponder] isKindOfClass:NSClassFromString(@"YTAdVideoElementsCellController")])
        return YES;
    if ([node isKindOfClass:NSClassFromString(@"ELMCellNode")]) {
        NSString *description = [[[node controller] owningComponent] description];
        if ([description containsString:@"brand_promo"]
            || [description containsString:@"statement_banner"]
            || [description containsString:@"product_carousel"]
            || [description containsString:@"product_engagement_panel"]
            || [description containsString:@"product_item"]
            || [description containsString:@"text_search_ad"]
            || [description containsString:@"text_image_button_layout"]
            || [description containsString:@"carousel_headered_layout"]
            || [description containsString:@"carousel_footered_layout"]
            || [description containsString:@"square_image_layout"] // install app ad
            || [description containsString:@"landscape_image_wide_button_layout"]
            || [description containsString:@"feed_ad_metadata"])
            return YES;
    }
    return NO;
}

%hook ASCollectionView

- (CGSize)sizeForElement:(ASCollectionElement *)element {
    ASCellNode *node = [element node];
    return isAd(node) ? CGSizeZero : %orig;
}

%end
