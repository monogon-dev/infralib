load("@io_bazel_rules_docker//go:image.bzl", "go_image")
load("@io_bazel_rules_docker//container:container.bzl", "container_push")

# How to update the fork:
#   bazel run //:gazelle update-repos github.com/leoluk/smtprelay@v1.5.0-1

go_image(
    name = "smtprelay_image",
    binary = "@com_github_leoluk_smtprelay//:smtprelay",
    visibility = ["//visibility:public"],
)

container_push(
    name = "push",
    format = "Docker",
    image = ":smtprelay_image",
    registry = "gcr.io",
    repository = "nexantic-infra/smtprelay",
    tag = "1.5.0-1",
)
