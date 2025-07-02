plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mobile_app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.supmap.mobile"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0.0"
        ndkVersion = "27.0.12077973"
        manifestPlaceholders["appAuthRedirectScheme"] = "com.supmap.mobile"

        manifestPlaceholders.putAll(
            mapOf(
                "auth0Domain" to "dev-bm0sid7ybtowbw6r.us.auth0.com",
                "auth0Scheme" to "com.supmap.mobile"
            )
        )
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}