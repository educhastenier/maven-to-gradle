import java.io.File
import groovy.util.XmlParser

def root = new File("").absoluteFile

root.eachFileRecurse { File file ->
    if(file.name.endsWith(".pom")){
        def rootNode = new XmlParser().parseText(file.text)
        def dependencies = []
        def dependenciesNode =rootNode.children().find{it.name().localPart=="dependencies"}
        if(dependenciesNode){
            dependenciesNode.children().each { dependency ->
            def scope = dependency.scope.text()
            def dep = dependency.groupId.text()+':'+dependency.artifactId.text()+':'+
            dependency.version.text() + ":" + (scope?scope:"compile")
            dependencies.add(dep)
            }
            dependencies.sort()
            def text = "dependencies:"
            dependencies.each{
               text+=it+"\n" 
            }
            def output = new File(file.parentFile,file.name+".normalized")
            output.text = text
            println "generated $output"
        }
        def dependencyManagementRoot =rootNode.children().find{it.name().localPart=="dependencyManagement"}
        def dependencyManagement 
        if(dependencyManagementRoot){
            dependencyManagement =dependencyManagementRoot.children().find{it.name().localPart=="dependencies"}
        }
        if(dependencyManagement){
            dependencyManagement.children().each { dependency ->
            def scope = dependency.scope.text()
            def dep = dependency.groupId.text()+':'+dependency.artifactId.text()+':'+
            dependency.version.text() + ":" + (scope?scope:"compile")
            dependencies.add(dep)
            }
            dependencies.sort()
            def text = "\ndependenciesMngt:"
            dependencies.each{
               text+=it+"\n" 
            }
            def output = new File(file.parentFile,file.name+".normalized")
            output.text = output.text + text
            println "generated $output"
        }
    }
}