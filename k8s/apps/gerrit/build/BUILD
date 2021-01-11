load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")

container_image(
    name = "with_plugins",
    base = "@gerrit_base//image",
    directory = "/var/gerrit/plugins",
    files = [
        "@gerrit_checks_plugin_release//file:checks.jar",
        "@gerrit_oauth_plugin_release//file:oauth.jar",
    ],
)

container_image(
    name = "gerrit_image",
    base = ":with_plugins",
    directory = "/",
    entrypoint = ["/entrypoint.sh"],
    files = [":entrypoint.sh"],
)

container_push(
    name = "push",
    format = "Docker",
    image = ":gerrit_image",
    registry = "gcr.io",
    repository = "nexantic-infra/gerrit",
    tag = "3.3.1-1",
)
