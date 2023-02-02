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
    sha256 = "a5b39eed937420ce0f4dd472c060b2189ec62323ee75b549dd0a2454fd5b6b3a",
    urls = ["https://gerrit-releases.storage.googleapis.com/gerrit-3.7.0.war"],
)

# Gerrit OAuth plugin.

git_repository(
    name = "gerrit_plugins_oauth",
    commit = "024c1d9e625b783b2d2cde6c2882188aeda68736",
    remote = "https://gerrit.googlesource.com/plugins/oauth",
    shallow_since = "1642236535 +0100",
)

load("@gerrit_plugins_oauth//:bazlets.bzl", "load_bazlets")

# Imports @com_googlesource_gerrit_bazlets.
# Should match our Gerrit version as closely as possible:
# https://gerrit.googlesource.com/bazlets
load_bazlets(commit = "8fa44957c3b3b89ce1d96eba67441882c54503fc")

load(
    "@com_googlesource_gerrit_bazlets//:gerrit_api.bzl",
    "gerrit_api",
)

gerrit_api()

load("@gerrit_plugins_oauth//:external_plugin_deps.bzl", "external_plugin_deps")

external_plugin_deps(omit_commons_codec = False)

# Plugin binaries are fetched from Gerrit's official plugin repository... which happens to be a Jenkins instance:
# https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.7/

http_file(
    name = "gerrit_checks_plugin_release",
    downloaded_file_path = "checks.jar",
    sha256 = "f23b05bc147f4b1c9978e0bc4a21a171a5e1cf38ea359aa2df34e5a065dac4b1",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.7/job/plugin-checks-bazel-stable-3.7/1/artifact/bazel-bin/plugins/checks/checks.jar"],
)

container_pull(
    name = "gerrit_base",
    digest = "sha256:cc3ea550e18be7ae81f1878bbadc4f68a6c51430f2c8c35414096dcd365b4b06",
    registry = "index.docker.io",
    repository = "gerritcodereview/gerrit",
    tag = "3.7.0",
)

load("//k8s/apps/jenkins/build:workspace.bzl", "jenkins_plugin_repositories")

jenkins_plugin_repositories()

container_pull(
    name = "jenkins_controller_base",
    digest = "sha256:0916193b654836c6e95fd50c9f58e613dd79a54c2e8cbd8279fdc2d8c5afd409",
    registry = "index.docker.io",
    repository = "jenkins/jenkins",
    tag = "2.385-almalinux",
)

container_pull(
    name = "monogon_builder",
    digest = "sha256:db55c8d732c5b174fd4178241b4d7c32ba8c666d864b002aa6106359eab3a902",
    registry = "gcr.io",
    repository = "monogon-infra/monogon-builder",
    tag = "1656611307:",
)

# Forked version of smtprelay, which adds support for plain auth tokens and environment variables for secrets.
go_repository(
    name = "com_github_leoluk_smtprelay",
    importpath = "github.com/leoluk/smtprelay",
    sum = "h1:Ms5WjHimjP1LAl+7jMKnnmmrzkQmVkfOUm6kBbY/BqQ=",
    version = "v1.5.0-1",
)
