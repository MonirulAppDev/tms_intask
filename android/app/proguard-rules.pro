# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hivedb.** { *; }
-keepnames class * extends com.hivedb.HiveObject
-keep class * extends io.hive.TypeAdapter { *; }

# Models
-keep class com.pts.app_scheduler.features.scheduler.data.models.** { *; }

# Google Play Core Missing Classes Fix
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
