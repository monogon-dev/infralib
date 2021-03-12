#  Copyright 2020 The Monogon Project Authors.
#  SPDX-License-Identifier: Apache-2.0

load("@bazel_gazelle//:deps.bzl", "go_repository")

def go_repositories():
    go_repository(
        name = "com_github_chrj_smtpd",
        importpath = "github.com/chrj/smtpd",
        sum = "h1:QGbE4UQz7sKjvXpRgNLuiBOjcWTzBKu/dj0hyDLpD14=",
        version = "v0.2.0",
    )
    go_repository(
        name = "com_github_davecgh_go_spew",
        importpath = "github.com/davecgh/go-spew",
        sum = "h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=",
        version = "v1.1.1",
    )

    go_repository(
        name = "com_github_decke_smtprelay",
        importpath = "github.com/decke/smtprelay",
        sum = "h1:dnZqJ/RVwWWfoNfPHSy2MoHTPLgOTPSuXxR7XSWuAEw=",
        version = "v1.5.1-0.20210313100219-d1933a2e3533",
    )
    go_repository(
        name = "com_github_eaigner_dkim",
        importpath = "github.com/eaigner/dkim",
        sum = "h1:17kQ+7S0aEyRhZd9KCAofvKlL1N1/w+zUZKaxpLFpM0=",
        version = "v0.0.0-20150301120808-6fe4a7ee9cfb",
    )
    go_repository(
        name = "com_github_google_uuid",
        importpath = "github.com/google/uuid",
        sum = "h1:qJYtXnJRWmpe7m/3XlyhrsLrEURqHRM2kxzoxXqyUDs=",
        version = "v1.2.0",
    )
    go_repository(
        name = "com_github_pmezard_go_difflib",
        importpath = "github.com/pmezard/go-difflib",
        sum = "h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=",
        version = "v1.0.0",
    )
    go_repository(
        name = "com_github_sirupsen_logrus",
        importpath = "github.com/sirupsen/logrus",
        sum = "h1:ShrD1U9pZB12TX0cVy0DtePoCH97K8EtX+mg7ZARUtM=",
        version = "v1.7.0",
    )
    go_repository(
        name = "com_github_stretchr_testify",
        importpath = "github.com/stretchr/testify",
        sum = "h1:bSDNvY7ZPG5RlJ8otE/7V6gMiyenm9RtJ7IUVIAoJ1w=",
        version = "v1.2.2",
    )

    go_repository(
        name = "com_github_vharitonsky_iniflags",
        importpath = "github.com/vharitonsky/iniflags",
        sum = "h1:fkw+7JkxF3U1GzQoX9h69Wvtvxajo5Rbzy6+YMMzPIg=",
        version = "v0.0.0-20180513140207-a33cd0b5f3de",
    )
    go_repository(
        name = "org_golang_x_crypto",
        importpath = "golang.org/x/crypto",
        sum = "h1:DN0cp81fZ3njFcrLCytUHRSUkqBjfTo4Tx9RJTWs0EY=",
        version = "v0.0.0-20201221181555-eec23a3978ad",
    )
    go_repository(
        name = "org_golang_x_net",
        importpath = "golang.org/x/net",
        sum = "h1:0GoQqolDA55aaLxZyTzK/Y2ePZzZTUrRacwib7cNsYQ=",
        version = "v0.0.0-20190404232315-eb5bcb51f2a3",
    )
    go_repository(
        name = "org_golang_x_sys",
        importpath = "golang.org/x/sys",
        sum = "h1:YyJpGZS1sBuBCzLAR1VEpK193GlqGZbnPFnPV/5Rsb4=",
        version = "v0.0.0-20191026070338-33540a1f6037",
    )
    go_repository(
        name = "org_golang_x_term",
        importpath = "golang.org/x/term",
        sum = "h1:/ZHdbVpdR/jk3g30/d4yUL0JU9kksj8+F/bnQUVLGDM=",
        version = "v0.0.0-20201117132131-f5c789dd3221",
    )

    go_repository(
        name = "org_golang_x_text",
        importpath = "golang.org/x/text",
        sum = "h1:g61tztE5qeGQ89tm6NTjjM9VPIm088od1l6aSorWRWg=",
        version = "v0.3.0",
    )
