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
    sha256 = "8e5edec29f7d317a842f1165a8cabd03e8e40cbba232ed672a2c040ddb767003",
    urls = ["https://gerrit-ci.gerritforge.com/view/Gerrit/job/Gerrit-bazel-java11-master/1337/artifact/gerrit/bazel-bin/gerrit.war"],
)

http_archive(
    name = "gerrit_core_plugins",
    sha256 = "396b679dda6efe6e364807454ed7ba9067405159d84ae5d1964c46c1890f4461",
    urls = ["https://gerrit-ci.gerritforge.com/view/Gerrit/job/Gerrit-bazel-java11-master/1231/artifact/gerrit/bazel-bin/plugins/*zip*/plugins.zip"],
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
    sha256 = "f06c2327d6bbb1f25deba3be285b443a9b508ee3ec6eb237fe39b2b035d85880",
    urls = ["https://gerrit-ci.gerritforge.com/job/plugin-checks-bazel-master/lastSuccessfulBuild/artifact/bazel-bin/plugins/checks/checks.jar"],
)

http_file(
    name = "gerrit_phabricator_plugin_release",
    downloaded_file_path = "its-phabricator.jar",
    sha256 = "721713e94b805d5211544fd9be74f0ca308889636dbf085c6ea419c3067f2d7a",
    urls = ["https://gerrit-ci.gerritforge.com/job/plugin-its-phabricator-bazel-master/5/artifact/bazel-bin/plugins/its-phabricator/its-phabricator.jar"],
)

http_file(
    name = "gerrit_gravatar_plugin_release",
    downloaded_file_path = "avatars-gravatar.jar",
    sha256 = "69ee77971acda8ba2bb6c93673b07f114d930ef8e7e92c4d353f36e11c67e73b",
    urls = ["https://gerrit-ci.gerritforge.com/view/Plugins-master/job/plugin-avatars-gravatar-bazel-master/3/artifact/bazel-bin/plugins/avatars-gravatar/avatars-gravatar.jar"],
)

http_file(
    name = "gerrit_uploadvalidator_plugin_release",
    downloaded_file_path = "uploadvalidator.jar",
    sha256 = "37fefa565196798a2032667a3b101b7ebd0dde20ead6a5e496ee45499efb0117",
    urls = ["https://gerrit-ci.gerritforge.com/job/plugin-uploadvalidator-bazel-master/23/artifact/bazel-bin/plugins/uploadvalidator/uploadvalidator.jar"],
)

http_file(
    name = "gerrit_simplesubmitrules_plugin_release",
    downloaded_file_path = "simple-submit-rules.jar",
    sha256 = "faed15caddf665a9e4d0fda0afe9b76b76898e9d508875066d936934596f09c5",
    urls = ["https://gerrit-ci.gerritforge.com/job/plugin-simple-submit-rules-bazel-master-master/4/artifact/bazel-bin/plugins/simple-submit-rules/simple-submit-rules.jar"],
)

# Manually built from gerrit Git clone and gerrit/plugins/webhook Git clone:
#
#     gerrit $ git rev-parse HEAD
#     bbc7de3c0adf9ad74e0cb848a126a91b5a244709
#     gerrit $ (cd plugins/webhooks && git rev-parse HEAD)
#     9fc9c2d4e69f7e2701cbcd873977d3312a231a81
#     gerrit $ bazel build //plugins/webhooks
#     gerrit $ gsutil cp bazel-bin/plugins/webhooks/webhooks.jar monogon-infra-public/webhooks-114abfec5105b3d175e1aae0a00ca0b62069bbe374caf5f619a275daad22a2a7.jar
#
http_file(
    name = "gerrit_webhooks_plugin_release",
    downloaded_file_path = "webhooks.jar",
    sha256 = "114abfec5105b3d175e1aae0a00ca0b62069bbe374caf5f619a275daad22a2a7",
    urls = ["https://storage.googleapis.com/monogon-infra-public/webhooks-114abfec5105b3d175e1aae0a00ca0b62069bbe374caf5f619a275daad22a2a7.jar"],
)

container_pull(
    name = "gerrit_base",
    digest = "sha256:43ae9db61fc8de201f1e707b29daef39ebd789821a85e6d21fe4000b82acbf51",
    registry = "index.docker.io",
    repository = "gerritcodereview/gerrit",
    tag = "3.3.2",
)

load("//k8s/apps/jenkins/build:workspace.bzl", "jenkins_plugin_repositories")
jenkins_plugin_repositories()

container_pull(
    name = "jenkins_controller_base",
    digest = "sha256:a487a419ef87244de6ba6ae0af88ce4eefdcf369a752f7f1412a893650d7a2fc",
    registry = "index.docker.io",
    repository = "jenkins/jenkins",
    tag = "2.289-centos7",
)

container_pull(
    name = "monogon_builder",
    digest = "sha256:2f2e6e0f078e88ecd2872b4a7671203fd062cfae79138aa5b36e7ebf689c3692",
    registry = "gcr.io",
    repository = "monogon-infra/monogon-builder",
    tag = "1620723905",
)

# Forked version of smtprelay, which adds support for plain auth tokens and environment variables for secrets.
go_repository(
    name = "com_github_leoluk_smtprelay",
    importpath = "github.com/leoluk/smtprelay",
    sum = "h1:Ms5WjHimjP1LAl+7jMKnnmmrzkQmVkfOUm6kBbY/BqQ=",
    version = "v1.5.0-1",
)
