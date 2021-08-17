Jenkins plugingen
=================

This is a tiny tool to generate BUILD/WORKSPACE macros to import Jenkins plugins.

To change the top-level list of plugins that are being imported, edit flagPlugins in main.go.

To regenerate `//k8s/apps/jenkins/build/{workspace,build}.bzl`, run `bazel run //:jenkins_plugingen`.

Known issues
------------

The list of plugins requested is hardcoded.

The tool always grabs the newest available version of each plugin - doing anything smarter would require introspecting .hpi files to get per-version dependencies (as the Jenkins plugin API service does not expose this information) and implementing some version selection plugin like MVS.

The tool relies on scraping updates.jenkins.io for SHA256 sums of plugins, as that information is not available in the plugin API service.
