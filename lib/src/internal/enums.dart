/// {@template photo_manager.AssetType}
/// The type of the asset.
///
/// Most of assets are [image] and [video],
/// some assets might be [audio] on Android.
/// The [other] type won't show in general.
/// {@endtemplate}
///
/// **IMPORTANT FOR MAINTAINERS:** **DO NOT** change orders of values.
enum AssetType {
  /// Assets other than [image], [video] and [audio].
  other,
  image,
  video,
  audio,
}

/// Generally support JPG and PNG.
enum ThumbFormat { jpeg, png }

/// The delivery mode enumeration for `PHImageRequestOptionsDeliveryMode`.
///
/// See also:
///  * [Apple documentation](https://developer.apple.com/documentation/photokit/phimagerequestoptionsdeliverymode)
enum DeliveryMode { opportunistic, highQualityFormat, fastFormat }

/// A mode that specifies how to resize the requested image on iOS/macOS.
///
/// See also:
///  * [Apple documentation](https://developer.apple.com/documentation/photokit/phimagerequestoptions/1616988-resizemode)
enum ResizeMode { none, fast, exact }

/// Options for fitting an image’s aspect ratio to a requested size.
///
/// See also:
///  * [Apple documentation](https://developer.apple.com/documentation/photokit/phimagecontentmode)
enum ResizeContentMode { fit, fill, def }

enum OrderOptionType { createDate, updateDate }

/// Indicate the current state when an asset is loading with [PMProgressHandler].
enum PMRequestState { prepare, loading, success, failed }

/// Information about your app’s authorization to access the user’s photo library.
///  * Android: Only [authorized] and [denied] are valid.
///  * iOS/macOS: All valid.
///
/// See also:
///  * [Apple documentation](https://developer.apple.com/documentation/photokit/phauthorizationstatus)
enum PermissionState {
  /// The user hasn’t set the app’s authorization status.
  notDetermined,

  /// The app isn’t authorized to access the photo library, and the user can’t grant such permission.
  restricted,

  /// The user explicitly denied this app access to the photo library.
  denied,

  /// The user explicitly granted this app access to the photo library.
  authorized,

  /// The user authorized this app for limited photo library access.
  ///
  /// This state only supports iOS 14 and above.
  limited,
}

/// The app’s level of access to the user’s photo library.
///
/// See also:
///  * [Apple documentation](https://developer.apple.com/documentation/photokit/phaccesslevel)
enum IosAccessLevel { addOnly, readWrite }