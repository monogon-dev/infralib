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

http_file(
    name = "gerrit_release",
    downloaded_file_path = "gerrit.war",
    sha256 = "f26b044257bf3e9e265bd015d20e40ddfe4201d9bf0a13dc51e5c90960a7c437",
    urls = ["https://gerrit-ci.gerritforge.com/view/Gerrit/job/Gerrit-bazel-java11-master/1101/artifact/gerrit/bazel-bin/gerrit.war"],
)

http_archive(
    name = "gerrit_core_plugins",
    sha256 = "1e94f6caa1d8996d8b2a302f1391ae3e7f87cc6d2576f50353182aba1174073e",
    urls = ["https://gerrit-ci.gerritforge.com/view/Gerrit/job/Gerrit-bazel-java11-master/1101/artifact/gerrit/bazel-bin/plugins/*zip*/plugins.zip"],
    build_file = "@//k8s/apps/gerrit/build:BUILD.plugins"
)

# Plugin binaries are fetched from Gerrit's official plugin repository... which happens to be a Jenkins instance:
# https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.3/

http_file(
    name = "gerrit_oauth_plugin_release",
    downloaded_file_path = "oauth.jar",
    sha256 = "b4f27666ebef9db5352089a6cd394415aeacf741ea62de3901f674da74bdfbb4",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-oauth-bazel-master-master/47/artifact/bazel-bin/plugins/oauth/oauth.jar"],
)

http_file(
    name = "gerrit_checks_plugin_release",
    downloaded_file_path = "checks.jar",
    sha256 = "7c28b26660661a149a3c20b5de01f7ab24bac8f0a95bfb177e3ef04a830e50fd",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-checks-bazel-master/41/artifact/bazel-bin/plugins/checks/checks.jar"],
)

http_file(
    name = "gerrit_phabricator_plugin_release",
    downloaded_file_path = "its-phabricator.jar",
    sha256 = "54993eaf91198d72af6e0fbe2321cccbbed394abb84988a1b9d3055b81e29e12",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-its-phabricator-bazel-master/4/artifact/bazel-bin/plugins/its-phabricator/its-phabricator.jar"],
)

http_file(
    name = "gerrit_lfs_plugin_release",
    downloaded_file_path = "lfs.jar",
    sha256 = "a8c0e55b2f3541f8763a7348df97f58cea1964fc3c541564255c9289a68e6951",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-lfs-bazel-master-master/30/artifact/bazel-bin/plugins/lfs/lfs.jar"],
)

http_file(
    name = "gerrit_gravatar_plugin_release",
    downloaded_file_path = "avatars-gravatar.jar",
    sha256 = "86179eb325085da90ca7ae5b6058a0056949fca40c9e8c523571430e9380cb5c",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-avatars-gravatar-bazel-master/2/artifact/bazel-bin/plugins/avatars-gravatar/avatars-gravatar.jar"],
)

http_file(
    name = "gerrit_uploadvalidator_plugin_release",
    downloaded_file_path = "uploadvalidator.jar",
    sha256 = "bc546ef9a2610eb03f9f4dd6b154e579f37e08cbd77c6a14b86060808c349feb",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-uploadvalidator-bazel-master/14/artifact/bazel-bin/plugins/uploadvalidator/uploadvalidator.jar"],
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
