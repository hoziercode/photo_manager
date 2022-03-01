//
//  PHAsset+PHAsset_checkType.h
//  photo_manager
//

#import <Photos/Photos.h>
#import <PMLogUtils.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (PM_COMMON)

- (bool)isImage;
- (bool)isVideo;
- (bool)isAudio;
- (bool)isImageOrVideo;
- (bool)isLivePhoto;
- (int)unwrappedSubtype;

- (NSString*)title;
/**
 Get the MIME type for this asset from UTI (`PHAssetResource.uniformTypeIdentifier`), such as `image/jpeg`, `image/heic`, `video/quicktime`, etc.
 
 @note For Live Photos, this returns a type representing its image file.
 @return The MIME type of this asset if available, otherwise `nil`.
 */
- (nullable NSString*)mimeType;
- (BOOL)isAdjust;
- (PHAssetResource *)getAdjustResource;
- (void)requestAdjustedData:(void (^)(NSData *_Nullable result))block;
- (PHAssetResource *)getLivePhotosResource;

@end

NS_ASSUME_NONNULL_END
