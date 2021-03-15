load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")

container_image(
    name = "with_plugins",
    base = "@gerrit_base//image",
    directory = "/var/gerrit/plugins",
    files = [
        "@gerrit_checks_plugin_release//file:checks.jar",
        "@gerrit_oauth_plugin_release//file:oauth.jar",
        "@gerrit_phabricator_plugin_release//file:its-phabricator.jar",
        "@gerrit_lfs_plugin_release//file:lfs.jar",
        "@gerrit_gravatar_plugin_release//file:avatars-gravatar.jar",
        "@gerrit_uploadvalidator_plugin_release//file:uploadvalidator.jar",
        "@gerrit_simplesubmitrules_plugin_release//file:simple-submit-rules.jar",
        "@gerrit_core_plugins//:plugins",
    ]
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

    # Apparently, the directories created by rules_docker are owned by
    # root:root and there's no way of changing the owner. This means that we
    # need this ugly hack to put this file in a place where we can write to it
    # from the entrypoint script.
    symlinks = {
    	"/var/gerrit/plugins/custom-theme.js": "/var/gerrit/tmp/custom-theme.js"
    },
)

container_push(
    name = "push",
    format = "Docker",
    image = ":gerrit_image",
    registry = "gcr.io",
    repository = "nexantic-infra/gerrit",
    tag = "3.3.2-6",
)
