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
    val project = this
    
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    val fixNamespace = {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val namespaceMethod = androidExt.javaClass.methods.find { it.name == "getNamespace" }
                val namespace = namespaceMethod?.invoke(androidExt) as? String
                if (namespace == null) {
                    val setNamespaceMethod = androidExt.javaClass.methods.find { it.name == "setNamespace" && it.parameterCount == 1 }
                    setNamespaceMethod?.invoke(androidExt, project.group.toString())
                }
            } catch (e: Exception) {
                // Ignore mistakes
            }
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate {
            fixNamespace()
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
