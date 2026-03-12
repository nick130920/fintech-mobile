allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for legacy Android plugins (e.g. telephony 0.2.0) that:
//   1. Don't declare a namespace (required by AGP 8+)
//   2. Use a compileSdk lower than what their transitive deps require (min 34)
subprojects {
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            // Inject namespace from AndroidManifest if missing
            if (namespace == null || namespace!!.isBlank()) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val match = Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifestFile.readText())
                    if (match != null) namespace = match.groupValues[1]
                }
            }
            // Force compileSdk to 36 for libraries stuck on an older SDK
            if (compileSdkVersion != null && compileSdkVersion!!.removePrefix("android-").toIntOrNull()?.let { it < 34 } == true) {
                compileSdkVersion(36)
            }
        }
    }
}

// Workaround for workmanager compilation issue
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }
        }
        
        // Forzar Kotlin JVM target también
        project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
            kotlinOptions {
                jvmTarget = "11"
            }
        }
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
