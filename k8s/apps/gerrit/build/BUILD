load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")

container_image(
    name = "with_plugins",
    base = "@gerrit_base//image",
    directory = "/var/gerrit/custom-plugins",
    files = [
        "@gerrit_checks_plugin_release//file:checks.jar",
        "@gerrit_plugins_oauth//:oauth.jar",
    ],
)

container_image(
    name = "override_gerrit",
    base = ":with_plugins",
    directory = "/var/gerrit/bin",
    files = [
        "@gerrit_release//file:gerrit.war",
    ],
)

container_image(
    name = "gerrit_image",
    base = ":override_gerrit",
    directory = "/",
    entrypoint = ["/entrypoint.sh"],
    files = [":entrypoint.sh"],
)

container_push(
    name = "push",
    format = "Docker",
    image = ":gerrit_image",
    registry = "gcr.io",
    repository = "monogon-infra/gerrit",
    tag = "3.7.0-2",
)
