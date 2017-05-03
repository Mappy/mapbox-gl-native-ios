# By default, the flags in this file are appended to flags specified
# in ../sdk/tools/proguard/proguard-android.txt,
# contents of this file will be appended into proguard-android.txt
-keepattributes Signature, *Annotation*, EnclosingMethod

# Square okio, ignoring warnings,
# see https://github.com/square/okio/issues/60
-dontwarn okhttp3.**
-dontwarn okio.**

# Package annotations
-keep class com.mapbox.mapboxsdk.annotations.Icon { *; }
-keep class com.mapbox.mapboxsdk.annotations.Marker { *; }
-keep class com.mapbox.mapboxsdk.annotations.Polygon { *; }
-keep class com.mapbox.mapboxsdk.annotations.Polyline { *; }

# Package camera
-keep class com.mapbox.mapboxsdk.camera.CameraPosition { *; }

# Package geometry
-keep class com.mapbox.mapboxsdk.geometry.LatLng { *; }
-keep class com.mapbox.mapboxsdk.geometry.LatLngBounds { *; }
-keep class com.mapbox.mapboxsdk.geometry.ProjectedMeters { *; }

# Package http
-keep class com.mapbox.mapboxsdk.http.HTTPRequest { *; }

# Package maps
-keep class com.mapbox.mapboxsdk.maps.** { *; }

# Package net
-keep class com.mapbox.mapboxsdk.net.** { *; }

# Package offline
-keep class com.mapbox.mapboxsdk.offline.** { *; }

# Package storage
-keep class com.mapbox.mapboxsdk.storage.** { *; }

# Package style
-keep class com.mapbox.mapboxsdk.style.layers.Layer { *; }
-keep class com.mapbox.mapboxsdk.style.layers.NoSuchLayerException { *; }
-keep class com.mapbox.mapboxsdk.style.sources.NoSuchSourceException { *; }
-keep class com.mapbox.mapboxsdk.style.sources.Source { *; }
-keep class com.mapbox.mapboxsdk.style.functions.** { *; }

#
# Mapbox-java Proguard rules
# We include these rules since libjava is a Jar file not AAR
#

# Gesture package
-dontshrink

# Retrofit 2
# Platform calls Class.forName on types which do not exist on Android to determine platform.
-dontnote retrofit2.Platform
# Platform used when running on RoboVM on iOS. Will not be used at runtime.
-dontnote retrofit2.Platform$IOS$MainThreadExecutor
# Platform used when running on Java 8 VMs. Will not be used at runtime.
-dontwarn retrofit2.Platform$Java8
# Retain generic type information for use by reflection by converters and adapters.
-keepattributes Signature
# Retain declared checked exceptions for use by a Proxy instance.
-keepattributes Exceptions

# For using GSON @Expose annotation
-keepattributes *Annotation*
# Gson specific classes
-dontwarn sun.misc.**

# Prevent proguard from stripping interface information from TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# MAS Data Models
-keep class com.mapbox.services.commons.geojson.** { *; }

-dontwarn javax.annotation.**

-keepclassmembers class rx.internal.util.unsafe.** {
    long producerIndex;
    long consumerIndex;
}

-keep class com.google.gson.GsonBuilder {*;}
-keep class com.google.gson.JsonElement {*;}
-keep class com.google.gson.JsonObject {*;}
-keep class com.google.gson.JsonPrimitive {*;}
-dontwarn com.google.**
