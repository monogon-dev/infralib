load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")

container_image(
    name = "jenkins_image",
    base = "@jenkins_base//image",
    directory = "/usr/share/jenkins/ref/plugins",
    files = [
        # Configuration-as-code plugin, allowing Jenkins to be configured from
        # a file instead of manually through the web UI or through groovy
        # scripts.
        "@jenkins_configuration_as_code_plugin_release//file:configuration-as-code.hpi",
        # Depended on by configuration-as-code.
        "@jenkins_snakeyaml_api_plugin_release//file:snakeyaml-api.hpi",

        # Google OAuth plugin.
        "@jenkins_google_login_plugin_release//file:google-login.hpi",
        # Depended on by google-login.
        "@jenkins_mailer_plugin_release//file:mailer.hpi",
        # Depended on by mailer (for google-login)
        "@jenkins_display_url_api_plugin_release//file:display-url-api.hpi",

        # RBAC authorization plugin, used to established fine-grained
        # permissions per user.
        "@jenkins_role_strategy_plugin_release//file:role-strategy.hpi",
        # Depended on by role-strategy
        "@jenkins_matrix_auth_plugin_release//file:matrix-auth.hpi",
    ],
)

container_push(
    name = "push",
    format = "Docker",
    image = "jenkins_image",
    registry = "gcr.io",
    repository = "monogon-infra/jenkins",
    tag = "2.77.3-lts-centos7-4",
)
