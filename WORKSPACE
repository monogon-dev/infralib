workspace(name = "infra")

# Basic imports

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

# rules_docker setup

http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "1698624e878b0607052ae6131aa216d45ebb63871ec497f26c67455b34119c80",
    strip_prefix = "rules_docker-0.15.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.15.0/rules_docker-v0.15.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    docker_toolchain_configure = "toolchain_configure",
)

docker_toolchain_configure(
    name = "docker_config",
    docker_path = "/usr/bin/docker",
)

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)


# rules_docker Java rules

load(
    "@io_bazel_rules_docker//java:image.bzl",
    _java_image_repos = "repositories",
)

_java_image_repos()

# Gerrit dependencies

# Plugin binaries are fetched from Gerrit's official plugin repository... which happens to be a Jenkins instance:
# https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.3/

http_file(
    name = "gerrit_oauth_plugin_release",
    downloaded_file_path = "oauth.jar",
    sha256 = "42ff6c3a8da36cc8e747529b6990274edddbf30338707ef231e28c15863175bd",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.3/job/plugin-oauth-bazel-master-stable-3.3/4/artifact/bazel-bin/plugins/oauth/oauth.jar"],
)

http_file(
    name = "gerrit_checks_plugin_release",
    downloaded_file_path = "checks.jar",
    sha256 = "87ae5238ed9a36ffca15ee780123f333f7f7b1136d207a43f7b90c6ac55a5607",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.3/job/plugin-checks-bazel-stable-3.3/6/artifact/bazel-bin/plugins/checks/checks.jar"],
)
http_file(
    name = "gerrit_phabricator_plugin_release",
    downloaded_file_path = "its-phabricator.jar",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.2/job/plugin-its-phabricator-bazel-stable-3.2/2/artifact/bazel-bin/plugins/its-phabricator/its-phabricator.jar"],
)

container_pull(
    name = "gerrit_base",
    digest = "sha256:72b0c95042c8dd2bed0f021661ce967c3e4c004275500510de3e39fb4e18aa27",
    registry = "index.docker.io",
    repository = "gerritcodereview/gerrit",
    tag = "3.3.1",
)
