workspace(name = "infra")

# Basic imports

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

# rules_go and gazelle

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "7904dbecbaffd068651916dce77ff3437679f9d20e1a7956bff43826e7645fcc",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.25.1/rules_go-v0.25.1.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.25.1/rules_go-v0.25.1.tar.gz",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.15.6")

http_archive(
    name = "bazel_gazelle",
    sha256 = "222e49f034ca7a1d1231422cdb67066b885819885c356673cb1f72f748a3c9d4",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.3/bazel-gazelle-v0.22.3.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.3/bazel-gazelle-v0.22.3.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies", "go_repository")

gazelle_dependencies()

load("//go:deps.bzl", "go_repositories")

# gazelle:repository_macro go/deps.bzl%go_repositories
go_repositories()

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

load(
    "@io_bazel_rules_docker//go:image.bzl",
    _go_image_repos = "repositories",
)

_go_image_repos()

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
    sha256 = "a3462d7c977be025f394c749178bfb91b9830b9b9e54d1ce8ba7af0cabdfbba0",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.3/job/plugin-oauth-bazel-master-stable-3.3/8/artifact/bazel-bin/plugins/oauth/oauth.jar"],
)

http_file(
    name = "gerrit_checks_plugin_release",
    downloaded_file_path = "checks.jar",
    sha256 = "9cf9699c851495fc8ac98766244d1f20a5cc68e4f41d41c46a73c61dd8292ba5",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.3/job/plugin-checks-bazel-stable-3.3/8/artifact/bazel-bin/plugins/checks/checks.jar"],
)

http_file(
    name = "gerrit_phabricator_plugin_release",
    downloaded_file_path = "its-phabricator.jar",
    sha256 = "ccec5e09d95b9dc0d3e7423f6fb78da1094737c4a1c7402b201a6da061c77c66",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.2/job/plugin-its-phabricator-bazel-stable-3.2/3/artifact/bazel-bin/plugins/its-phabricator/its-phabricator.jar"],
)

container_pull(
    name = "gerrit_base",
    digest = "sha256:43ae9db61fc8de201f1e707b29daef39ebd789821a85e6d21fe4000b82acbf51",
    registry = "index.docker.io",
    repository = "gerritcodereview/gerrit",
    tag = "3.3.2",
)

# Forked version of smtprelay, which adds support for plain auth tokens and environment variables for secrets.
go_repository(
    name = "com_github_leoluk_smtprelay",
    importpath = "github.com/leoluk/smtprelay",
    sum = "h1:Ms5WjHimjP1LAl+7jMKnnmmrzkQmVkfOUm6kBbY/BqQ=",
    version = "v1.5.0-1",
)
