// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

// Static imports for Cue definitions

import (
	_ "github.com/prometheus/prometheus/pkg/rulefmt"
	_ "k8s.io/api/apps/v1"
	_ "k8s.io/api/core/v1"
	_ "k8s.io/api/rbac/v1"
	_ "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1beta1"
	- "k8s.io/api/networking/v1"
)
