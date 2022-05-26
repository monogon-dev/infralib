workspace(name = "infra")

# Basic imports

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

# rules_go and gazelle

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "d6b2513456fe2229811da7eb67a444be7785f5323c6708b38d851d2b51e54d83",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.30.0/rules_go-v0.30.0.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.30.0/rules_go-v0.30.0.zip",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.6")

http_archive(
    name = "bazel_gazelle",
    sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
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
    sha256 = "85ffff62a4c22a74dbd98d05da6cf40f497344b3dbf1e1ab0a37ab2a1a6ca014",
    strip_prefix = "rules_docker-0.23.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.23.0/rules_docker-v0.23.0.tar.gz"],
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

http_file(
    name = "gerrit_release",
    downloaded_file_path = "gerrit.war",
    sha256 = "5312feff4998dd47b3ca762d52e45f0c2d4e23abf9693630f99936de0a4ebf88",
    urls = ["https://gerrit-releases.storage.googleapis.com/gerrit-3.6.0.war"],
)

# Plugin binaries are fetched from Gerrit's official plugin repository... which happens to be a Jenkins instance:
# https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.6/

http_file(
    name = "gerrit_oauth_plugin_release",
    downloaded_file_path = "oauth.jar",
    sha256 = "16a9888c8ff760e4eda744096fbc18054b5e22333823681102ee5bd7cb524e0e",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.6/job/plugin-oauth-bazel-master-stable-3.6/1/artifact/bazel-bin/plugins/oauth/oauth.jar"],
)

http_file(
    name = "gerrit_checks_plugin_release",
    downloaded_file_path = "checks.jar",
    sha256 = "ff435ea3cc7d671117205fe7f9c622b8e60b543e0ef39f3aeaaefe4714386e34",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.6/job/plugin-checks-bazel-master-stable-3.6/1/artifact/bazel-bin/plugins/checks/checks.jar"],
)

container_pull(
    name = "gerrit_base",
    digest = "sha256:b24689af2a6d75ff09cca599138a124a85d6f628220cff48b13bcb1b73967bda",
    registry = "index.docker.io",
    repository = "gerritcodereview/gerrit",
    tag = "3.6.0",
)

load("//k8s/apps/jenkins/build:workspace.bzl", "jenkins_plugin_repositories")

jenkins_plugin_repositories()

container_pull(
    name = "jenkins_controller_base",
    digest = "sha256:ddaea9c5ee0e37f4b73a65b39930d8f6b60be158739a76222f957bbb65423f7b",
    registry = "index.docker.io",
    repository = "jenkins/jenkins",
    tag = "2.337-centos7",
)

container_pull(
    name = "monogon_builder",
    digest = "sha256:264371cd940a57b840f42d4c3f18ab878a26d83e7bb6e70bfe79821b16af9584",
    registry = "gcr.io",
    repository = "monogon-infra/monogon-builder",
    tag = "1653395207:",
)

# Forked version of smtprelay, which adds support for plain auth tokens and environment variables for secrets.
go_repository(
    name = "com_github_leoluk_smtprelay",
    importpath = "github.com/leoluk/smtprelay",
    sum = "h1:Ms5WjHimjP1LAl+7jMKnnmmrzkQmVkfOUm6kBbY/BqQ=",
    version = "v1.5.0-1",
)
