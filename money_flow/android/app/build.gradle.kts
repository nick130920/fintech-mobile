plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.money_flow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.money.flow" // Nombre único para tu app
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val keystorePath = requireNotNull(System.getenv("CM_KEYSTORE_PATH")) {
                "CM_KEYSTORE_PATH is required for release signing"
            }
            storeFile = file(keystorePath)
            storePassword = requireNotNull(System.getenv("CM_KEYSTORE_PASSWORD")) {
                "CM_KEYSTORE_PASSWORD is required for release signing"
            }
            keyAlias = requireNotNull(System.getenv("CM_KEY_ALIAS")) {
                "CM_KEY_ALIAS is required for release signing"
            }
            keyPassword = requireNotNull(System.getenv("CM_KEY_PASSWORD")) {
                "CM_KEY_PASSWORD is required for release signing"
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")  // Activar firma
            isMinifyEnabled = false  // Desactivar minificación temporalmente para CI
            isShrinkResources = false // Desactivar resource shrinking temporalmente para CI
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
