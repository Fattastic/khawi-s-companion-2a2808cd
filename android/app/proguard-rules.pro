## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Google Play Core (deferred components — referenced by Flutter engine)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

## Supabase / GoTrue / Realtime (uses reflection)
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

## OkHttp (used internally by Supabase realtime)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

## Sentry crash reporting
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**
-keep class io.sentry.android.** { *; }

## Kotlin (reflection used by freezed / json_serializable)
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings { <fields>; }
-keepclassmembers class kotlin.Metadata { public <methods>; }

## Keep annotations and source info for readable stack traces in Sentry
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
