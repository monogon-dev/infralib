#  Copyright 2020 The Monogon Project Authors.
#  SPDX-License-Identifier: Apache-2.0

load(
    "@bazel_skylib//lib:shell.bzl",
    "shell",
)

def _plugingen_runner_impl(ctx):
    out_file = ctx.actions.declare_file(ctx.label.name + ".bash")
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = out_file,
        substitutions = {
            "@@PLUGINGEN_SHORT_PATH@@": shell.quote(ctx.executable.plugingen.short_path),
        },
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = [ ctx.executable.plugingen ])
    return [DefaultInfo(
        files = depset([out_file]),
        runfiles = runfiles,
        executable = out_file,
    )]

_plugingen_runner = rule(
    implementation = _plugingen_runner_impl,
    attrs = {
        "plugingen": attr.label(
            executable = True,
            cfg = 'host',
            default = "//k8s/apps/jenkins/build/plugingen",
        ),
        "_template": attr.label(
            default = "//k8s/apps/jenkins/build/plugingen:plugingen.bash.in",
            allow_single_file = True,
        ),
    },
)

def jenkins_plugingen(name):
    runner_name = name + "-runner"
    _plugingen_runner(
        name = runner_name
    )
    native.sh_binary(
        name = name,
        srcs = [runner_name],
    )
