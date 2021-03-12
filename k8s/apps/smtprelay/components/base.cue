// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"infralib.monogon.dev/k8s/base"
)

k8s: base.#KubernetesBase

k8s: statefulsets: [Name=string]: spec: serviceName: Name
