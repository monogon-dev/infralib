// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package rules

import (
	"github.com/prometheus/prometheus/pkg/rulefmt"
)

rules: [Name=_]: rulefmt.#RuleGroup & {
	name: Name
	rules: [...{
		alert: string
		for:   string | *"3m"
		labels: severity: *"info" | "paging"
	}]
}
