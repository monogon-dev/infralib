// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package config

// This file contains complementary definitions for Prometheus/Alertmanager configs.

// github.com/prometheus/prometheus/config and github.com/prometheus/alertmanager/config
// are not not properly parsed by Cue, since it implements a custom marshaller.
//
// TODO: we could complete this definition and move it to cue.mod/usr - especially if we end up with other apps
// that define Prometheus scrape_configs.

#AlertmanagerConfig: {
	global:    null
	route:     #Route
	receivers: #Receivers
}

#Route: {
	receiver: string

	// Alert immediately, only use alert rules for delays.
	group_wait: "0s"
	// Disable alert grouping - individually send alerts to PagerDuty
	group_by?: [...string]

	repeat_interval?: string

	continue?: bool

	match?: [string]: string
	routes?: [...#Route]
}

#Receivers: [...{
	pagerduty_configs?: [...{
		service_key: string
		// For some reasons, alerts show up as Critical no matter what we set here
		severity: "critical" | "error" | "warning" | "info"
	}]
	webhook_configs?: [...{
		url:            string
		send_resolved?: bool
	}]
	...
}]

#ScrapeConfigs: [...{
	job_name:        string
	scrape_interval: string | *"5s"
	metrics_path?:   string
	metric_relabel_configs?: [
		...{
			source_labels: [string, ...string]
			target_label: string
			replacement:  string
		},
	]
	static_configs: [
		...{
			targets: [...string]
			labels?: [string]: string
		},
	]
}]
