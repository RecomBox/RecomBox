import java.util.Properties


val env = Properties()
val envFile = rootProject.file(".env")
if (envFile.exists()) {
    envFile.inputStream().use { env.load(it) }
}


plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}



android {
    namespace = "io.github.RecomBox.RecomBox"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.github.RecomBox.RecomBox"
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
            // Local Fallback Logic: Properties File -> System Environment -> Null
            keyAlias = env.getProperty("FLUTTER_KEY_ALIAS") ?: System.getenv("FLUTTER_KEY_ALIAS")
            keyPassword = env.getProperty("FLUTTER_KEY_PASSWORD") ?: System.getenv("FLUTTER_KEY_PASSWORD")
            storePassword = env.getProperty("FLUTTER_STORE_PASSWORD") ?: System.getenv("FLUTTER_STORE_PASSWORD")
            
            val keystoreName = env.getProperty("FLUTTER_STORE_FILE") ?: System.getenv("FLUTTER_STORE_FILE")
            
            // In GitHub Actions, the file might be in a different path, 
            // so we handle the file reference carefully.
            storeFile = if (keystoreName != null) {
                if (File(keystoreName).isAbsolute) file(keystoreName) else file("../$keystoreName")
            } else null
        }

        getByName("debug") {
            // No extra config needed, it uses the default ~/.android/debug.keystore
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }

        getByName("debug") {
            // Use the default debug keys
            signingConfig = signingConfigs.getByName("debug")
            
            // Debug builds usually don't need minification
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
