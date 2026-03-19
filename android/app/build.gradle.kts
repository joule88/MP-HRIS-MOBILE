plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mpg_mobile"
    
    // UBAH 1: Hardcode ke 34 agar support ML Kit terbaru
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Pastikan applicationId ini sesuai dengan yang Anda inginkan
        applicationId = "com.example.mpg_mobile"
        
        // UBAH 2: Ubah minSdk ke 23 (Android 6.0) minimal untuk AI
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // UBAH 3: Aktifkan MultiDex karena library AI sangat besar
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// UBAH 4: Tambahkan blok dependencies ini manual di paling bawah
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
