#import "MGLFoundation.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Indicates how the map view load glyphs.
typedef NS_CLOSED_ENUM(NSUInteger, MGLGlyphsRasterizationMode) {
    /// The MGLGlyphsRasterizationMode was unset.
    MGLGlyphsRasterizationModeNone,
    /// Ideographs are rasterized locally, and they are not loaded from the server.
    MGLGlyphsRasterizationModeIdeographsRasterizedLocally,
    /// No glyphs are rasterized locally. All glyphs are loaded from the server.
    MGLGlyphsRasterizationModeNoGlyphsRasterizedLocally,
    /// All glyphs are rasterized locally. No glyphs are loaded from the server.
    MGLGlyphsRasterizationModeAllGlyphsRasterizedLocally
};

/**
 The MGLRendererConfiguration object represents configuration values for the
 renderer.
 */
MGL_EXPORT
@interface MGLRendererConfiguration : NSObject

/** Returns an instance of the current renderer configuration. */
@property (class, nonatomic, readonly) MGLRendererConfiguration *currentConfiguration;

/** The scale factor to use.

 Based on the native scale where available, otherwise the standard screen scale. */
@property (nonatomic, readonly) const float scaleFactor;

/** The name of the font family to use for client-side text rendering of CJK ideographs.
 
 Set MGLIdeographicFontFamilyName in your containing application's Info.plist to
 font family name(s) that will be available at run time, such as “PingFang TC”
 or “Marker Felt”. This plist key accepts:
 
 - A string value of a single font family name.
 
 - An array of font family names. Fonts will be used in the defined order,
 eventually falling back to default system font if none are available.
 
 - A boolean value NO to disable client-side rendering of CJK glyphs —
 remote fonts specified in your style will be used instead.
 */
@property (nonatomic, readonly, nullable) NSString *localFontFamilyName;

- (nullable NSString *)localFontFamilyNameWithInfoDictionaryObject:(nullable id)infoDictionaryObject;

/**
 A Boolean value indicating whether symbol layers may enable per-source symbol
 collision detection.
 
 Set `MGLCollisionBehaviorPre4_0` in your containing app's Info.plist or by using
 `[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"MGLCollisionBehaviorPre4_0"]`.
 If both are set, the value from `NSUserDefaults` takes priority.
 
 Setting this property to `YES` in the plist results in symbol layers only running
 collision detection against other symbol layers that are part of the same source.
 */
@property (nonatomic, readonly) BOOL perSourceCollisions;

- (BOOL)perSourceCollisionsWithInfoDictionaryObject:(nullable id)infoDictionaryObject;

/**
 Indicates how the map view load glyphs.

 Set `MGLGlyphsRasterizationOptions` in your containing app's Info.plist.
 */
@property (nonatomic, readonly) MGLGlyphsRasterizationMode glyphsRasterizationMode;

- (MGLGlyphsRasterizationMode)glyphsRasterizationModeWithInfoDictionaryObject:(nullable id)infoDictionaryObject;

@end

NS_ASSUME_NONNULL_END
