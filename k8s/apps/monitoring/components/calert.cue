// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

// TODO: restart the pod when value changes - right now, the pod needs to be manually restarted

k8s: {
	configmaps: calert: data: {
		"config.toml": """
[server]
address = "[::1]:6000"
socket = "/tmp/calert.sock"
name = "calert"

# WARNING If these timeouts are less than 1s,
# the server connection breaks.
read_timeout=5000
write_timeout=5000
keepalive_timeout=300000

[app]
template_file = "/etc/calert/message.tmpl"

[app.http_client]
max_idle_conns =  100
request_timeout = 8000

[app.chat.firehose-dev]
notification_url = "\(config.googleChatWebhooks.dev)"

[app.chat.firehose-prod]
notification_url = "\(config.googleChatWebhooks.prod)"
"""
		"message.tmpl": """
			*{{ .Labels.alertname | Title }} - {{.Status | Title }} ({{.Labels.severity | toUpper }})*
			{{ range .Annotations.SortedPairs -}}
			{{ .Name }}: {{ .Value}}
			{{ end -}}
			"""
	}
}
