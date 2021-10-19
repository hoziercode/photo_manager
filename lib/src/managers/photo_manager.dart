import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../internal/editor.dart';
import '../types/entity.dart';
import '../filter/filter_option_group.dart';
import 'notify_manager.dart';
import '../internal/enums.dart';
import '../internal/extensions.dart';
import '../internal/plugin.dart';
import '../types/types.dart';
import '../utils/convert_utils.dart';

/// use the class method to help user load asset list and asset info.
///
/// 这个类是整个库的核心类
class PhotoManager {
  @Deprecated(
    'Use requestPermissionExtend for better compatibility. '
    'This feature was deprecated after v1.4.0.',
  )
  static Future<bool> requestPermission() async {
    return (await requestPermissionExtend()).isAuth;
  }

  /// ### Android (AndroidManifest.xml)
  ///  * WRITE_EXTERNAL_STORAGE
  ///  * READ_EXTERNAL_STORAGE
  ///  * ACCESS_MEDIA_LOCATION
  ///
  /// ### iOS (Info.plist)
  ///  * NSPhotoLibraryUsageDescription
  ///  * NSPhotoLibraryAddUsageDescription
  ///
  /// ### macOS (Debug/Release.entitlements)
  ///  * com.apple.security.assets.movies.read-write
  ///  * com.apple.security.assets.music.read-write
  ///
  /// See also:
  ///  * [PermissionState] which defines the permission state
  ///    of the current application.
  static Future<PermissionState> requestPermissionExtend({
    PermisstionRequestOption requestOption = const PermisstionRequestOption(),
  }) async {
    final int resultIndex = await plugin.requestPermissionExtend(requestOption);
    return PermissionState.values[resultIndex];
  }

  /// Prompts the limited assets selection modal on iOS.
  ///
  /// This method only supports from iOS 14.0, and will behave differently on
  /// iOS 14 and 15:
  ///  * iOS 14: Immediately complete the future call since there is no complete
  ///    handler with the API on iOS 14.
  ///  * iOS 15: The Future will be completed after the modal was dismissed.
  ///
  /// See the documents from Apple:
  ///  * iOS 14: https://developer.apple.com/documentation/photokit/phphotolibrary/3616113-presentlimitedlibrarypickerfromv/
  ///  * iOS 15: https://developer.apple.com/documentation/photokit/phphotolibrary/3752108-presentlimitedlibrarypickerfromv/
  static Future<void> presentLimited() => plugin.presentLimited();

  static Editor editor = Editor();

  /// get gallery list
  ///
  /// 获取相册"文件夹" 列表
  ///
  /// [hasAll] contains all path, such as "Camera Roll" on ios or "Recent" on android.
  /// [hasAll] 包含所有项目的相册
  ///
  /// [onlyAll] If true, Return only one album with all resources.
  /// [onlyAll] 如果为真, 则只返回一个包含所有项目的相册
  static Future<List<AssetPathEntity>> getAssetPathList({
    bool hasAll = true,
    bool onlyAll = false,
    RequestType type = RequestType.common,
    FilterOptionGroup? filterOption,
  }) async {
    if (onlyAll) {
      assert(hasAll, "If only is true, then the hasAll must be not null.");
    }
    filterOption ??= FilterOptionGroup();

    assert(
      type != RequestType.all,
      'The request type must have video, image or audio.',
    );

    if (type == RequestType.all) {
      return [];
    }

    return plugin.getAllGalleryList(
      type: type,
      hasAll: hasAll,
      onlyAll: onlyAll,
      optionGroup: filterOption,
    );
  }

  static Future<void> setLog(bool isLog) => plugin.setLog(isLog);

  /// Ignore permission checks at runtime, you can use third-party permission plugins to request permission. Default is false.
  ///
  /// For Android, a typical usage scenario may be to use it in Service, because Activity cannot be used in Service to detect runtime permissions, but it should be noted that deleting resources above android10 require activity to accept the result, so the delete system does not apply to this Attributes.
  ///
  /// For iOS, this feature is only added, please explore the specific application scenarios by yourself
  static Future<void> setIgnorePermissionCheck(bool ignore) {
    return plugin.ignorePermissionCheck(ignore);
  }

  /// get video asset
  /// open setting page
  static Future<void> openSetting() => plugin.openSetting();

  /// Release all native(ios/android) caches, normally no calls are required.
  ///
  /// The main purpose is to help clean up problems where memory usage may be too large when there are too many pictures.
  ///
  /// Warning:
  ///
  ///   Once this method is invoked, unless you call the [getAssetPathList] method again, all the [AssetEntity] and [AssetPathEntity] methods/fields you have acquired will fail or produce unexpected results.
  ///
  ///   This method should only be invoked when you are sure you really want to do so.
  ///
  ///   This method is asynchronous, and calling [getAssetPathList] before the Future of this method returns causes an error.
  ///
  ///
  /// 释放资源的方法,一般情况下不需要调用
  ///
  /// 主要目的是帮助清理当图片过多时,内存占用可能过大的问题
  ///
  /// 警告:
  ///
  /// 一旦调用这个方法,除非你重新调用  [getAssetPathList] 方法,否则你已经获取的所有[AssetEntity]/[AssetPathEntity]的所有字段都将失效或产生无法预期的效果
  ///
  /// 这个方法应当只在你确信你真的需要这么做的时候再调用
  ///
  /// 这个方法是异步的,在本方法的Future返回前调用getAssetPathList 可能会产生错误
  static Future releaseCache() async {
    await plugin.releaseCache();
  }

  /// Notification class for managing photo changes.
  static NotifyManager _notifyManager = NotifyManager();

  /// see [NotifyManager]
  static void addChangeCallback(ValueChanged<MethodCall> callback) =>
      _notifyManager.addCallback(callback);

  /// see [NotifyManager]
  static void removeChangeCallback(ValueChanged<MethodCall> callback) =>
      _notifyManager.removeCallback(callback);

  /// Whether to monitor the change of photo album.
  static bool notifyingOfChange = false;

  /// See [NotifyManager.notifyStream]
  static Stream<bool> get notifyStream => _notifyManager.notifyStream;

  /// see [NotifyManager]
  static void startChangeNotify() {
    _notifyManager.startHandleNotify();
    notifyingOfChange = true;
  }

  /// see [NotifyManager]
  static void stopChangeNotify() {
    _notifyManager.stopHandleNotify();
    notifyingOfChange = false;
  }

  /// [AssetPathEntity.refreshPathProperties]
  static Future<AssetPathEntity?> fetchPathProperties({
    required AssetPathEntity entity,
    required FilterOptionGroup filterOptionGroup,
  }) async {
    final result = await plugin.fetchPathProperties(
      entity.id,
      entity.type,
      entity.filterOption,
    );
    if (result == null) {
      return null;
    }
    final list = result["data"];
    if (list is List && list.isNotEmpty) {
      return ConvertUtils.convertPath(
        result,
        type: entity.type,
        optionGroup: entity.filterOption,
      )[0];
    } else {
      return null;
    }
  }

  /// Only valid for Android 29. The API of API 28 must be used with the property of `requestLegacyExternalStorage`.
  static Future<void> forceOldApi() async {
    await plugin.forceOldApi();
  }

  /// Get system version
  static Future<String> systemVersion() async {
    return plugin.getSystemVersion();
  }

  /// Clear all file cache.
  static Future<void> clearFileCache() async {
    await plugin.clearFileCache();
  }

  /// When set to true, origin bytes in Android Q will be cached as a file. When use again, the file will be read.
  static Future<bool> setCacheAtOriginBytes(bool cache) =>
      plugin.cacheOriginBytes(cache);

  /// Refresh the property of asset.
  static Future<AssetEntity?> refreshAssetProperties(String id) async {
    final Map? map = await plugin.getPropertiesFromAssetEntity(id);

    final asset = ConvertUtils.convertToAsset(map);

    if (asset == null) {
      return null;
    }

    return asset;
  }
}