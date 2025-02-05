import jenkins.model.*
import hudson.model.*

// Get Jenkins instance
def jenkins = Jenkins.getInstance()

// Build the webserver job immediately after Jenkins starts
Thread.start {
    println "Starting web server job..."
    sleep(10000) // Wait for Jenkins to fully initialize
    def job = jenkins.getItem("webserver")
    if (job != null) {
        job.scheduleBuild2(0)
        println "Web server job started successfully"
    } else {
        println "Warning: Could not find webserver job"
    }
}
