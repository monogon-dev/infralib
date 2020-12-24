// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package rules

rules: snitch: rules: [
	{
		alert: "SnitchHeartbeat"
		expr:  "vector(1)"
		for:   "0m"
		labels: type: "heartbeat"
	},
]
