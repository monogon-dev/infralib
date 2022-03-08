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
    sha256 = "59d5b42ac315e7eadffa944e86e90c2990110a1c8075f1cd145f487e999d22b3",
    strip_prefix = "rules_docker-0.17.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.17.0/rules_docker-v0.17.0.tar.gz"],
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
    sha256 = "a47a2660a62957ad1220a2e8493e72f62dc5a6b315d551b2fb91a3869461054a",
    urls = ["https://gerrit-releases.storage.googleapis.com/gerrit-3.4.1.war"],
)

# Plugin binaries are fetched from Gerrit's official plugin repository... which happens to be a Jenkins instance:
# https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.4/

http_file(
    name = "gerrit_oauth_plugin_release",
    downloaded_file_path = "oauth.jar",
    sha256 = "e6edbfd055106bf5b7cefa166d6f88918e7e61e20ea5a305ac35934a9aa79546",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.4/job/plugin-oauth-bazel-master-stable-3.4/2/artifact/bazel-bin/plugins/oauth/oauth.jar"],
)

http_file(
    name = "gerrit_checks_plugin_release",
    downloaded_file_path = "checks.jar",
    sha256 = "0fd40cd04b59d1246cc19d4af47a0005366c3b8cbcb326ed7a5be39a3a8f4333",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.4/job/plugin-checks-bazel-master-stable-3.4/10/artifact/bazel-bin/plugins/checks/checks.jar"],
)

http_file(
    name = "gerrit_simplesubmitrules_plugin_release",
    downloaded_file_path = "simple-submit-rules.jar",
    sha256 = "6e7b233d8478bea1ad444c93cdb8dd72463eba0225955334ad4459711c723595",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.4/job/plugin-simple-submit-rules-bazel-master-stable-3.4/4/artifact/bazel-bin/plugins/simple-submit-rules/simple-submit-rules.jar"],
)

container_pull(
    name = "gerrit_base",
    digest = "sha256:e2c5105534eb40096a43463399c34c250d865860b0591592ac0cac41366a7723",
    registry = "index.docker.io",
    repository = "gerritcodereview/gerrit",
    tag = "3.4.1",
)

load("//k8s/apps/jenkins/build:workspace.bzl", "jenkins_plugin_repositories")

jenkins_plugin_repositories()

container_pull(
    name = "jenkins_controller_base",
    digest = "sha256:af31f373adb421d32d4925a8205170d8403dfda5aac47869a0cb791784f2d3c8",
    registry = "index.docker.io",
    repository = "jenkins/jenkins",
    tag = "2.316-centos7",
)

container_pull(
    name = "monogon_builder",
    digest = "sha256:37c8d25d3751f211dc30d46d0fefbda8a1074d3c409339a44dd0b601ddff623e",
    registry = "gcr.io",
    repository = "monogon-infra/monogon-builder",
    tag = "1646697051",
)

# Forked version of smtprelay, which adds support for plain auth tokens and environment variables for secrets.
go_repository(
    name = "com_github_leoluk_smtprelay",
    importpath = "github.com/leoluk/smtprelay",
    sum = "h1:Ms5WjHimjP1LAl+7jMKnnmmrzkQmVkfOUm6kBbY/BqQ=",
    version = "v1.5.0-1",
)
