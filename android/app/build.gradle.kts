plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Apply Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.zussgo.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.zussgo.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Required for flutter_local_notifications (Java 8+ APIs on older Android)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BoM — manages all Firebase library versions automatically
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))

    // Firebase Cloud Messaging
    implementation("com.google.firebase:firebase-messaging")

    // Firebase Analytics (included by default with BoM)
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}
