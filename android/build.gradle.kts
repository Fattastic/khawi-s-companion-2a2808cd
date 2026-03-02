allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Define global SDK versions for plugins to use
extra["compileSdkVersion"] = 35
extra["minSdkVersion"] = 24
extra["targetSdkVersion"] = 35

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val compileSdkVersion = rootProject.extra["compileSdkVersion"] as Int
    plugins.withId("com.android.application") {
        extensions.findByName("android")?.let { ext ->
            when (ext) {
                is com.android.build.gradle.AppExtension ->
                    ext.compileSdkVersion(compileSdkVersion)
                is com.android.build.api.dsl.ApplicationExtension ->
                    ext.compileSdk = compileSdkVersion
            }
        }
    }
    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { ext ->
            when (ext) {
                is com.android.build.gradle.LibraryExtension ->
                    ext.compileSdkVersion(compileSdkVersion)
                is com.android.build.api.dsl.LibraryExtension ->
                    ext.compileSdk = compileSdkVersion
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}
