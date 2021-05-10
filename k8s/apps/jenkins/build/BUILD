load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")
load("//k8s/apps/jenkins/build:build.bzl", "jenkins_plugin_files_all")

container_image(
    name = "controller_image",
    base = "@jenkins_controller_base//image",
    directory = "/usr/share/jenkins/ref/plugins",
    files = jenkins_plugin_files_all(),
)

container_push(
    name = "controller_push",
    format = "Docker",
    image = "controller_image",
    registry = "gcr.io",
    repository = "monogon-infra/jenkins-controller",
    tag = "2.289-centos7-1",
)
