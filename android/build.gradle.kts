allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Apply NDK and SDK settings to all Android modules
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            val androidExtension = android as com.android.build.gradle.BaseExtension
            androidExtension.ndkVersion = "30.0.15729638"
            androidExtension.compileSdkVersion(36)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}