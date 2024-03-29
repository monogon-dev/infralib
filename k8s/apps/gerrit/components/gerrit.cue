// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"text/template"
)

// https://gerrit-review.googlesource.com/Documentation/config-gerrit.html
let _gerritConfig = template.Execute("""
[gerrit]
  basePath = git
  canonicalWebUrl = https://{{.publicHostname}}/
  serverId = {{.serverID}}
  instanceName = {{.instanceName}}

[experiments]
  enabled = UiFeature__mention_users
  enabled = UiFeature__render_markdown
  enabled = UiFeature__copy_link_dialog
  enabled = UiFeature__suggest_edit
  enabled = UiFeature__auto_app_theme

[sshd]
  advertisedAddress = {{.sshHostname}}:{{.sshPort}}

[container]
  javaOptions = "-Dflogger.backend_factory=com.google.common.flogger.backend.log4j.Log4jBackendFactory#getInstance"
  javaOptions = "-Dflogger.logging_context=com.google.gerrit.server.logging.LoggingContext#getInstance"
  user = gerrit
  javaOptions = -Djava.security.egd=file:/dev/./urandom
  javaOptions = --add-opens java.base/java.net=ALL-UNNAMED
  javaOptions = --add-opens java.base/java.lang.invoke=ALL-UNNAMED

[index]
  type = lucene

[auth]
  type = OAUTH
  gitBasicAuthPolicy = HTTP
  userNameToLowerCase = true

[oauth]
  allowRegisterNewEmail = true

[receive]
  enableSignedPush = false

[user]
  email = {{.userEmail}}

[sendemail]
  smtpServer = {{.smtpServer}}
  smtpServerPort = {{.smtpPort}}
{{ if .smtpUser -}}
  smtpUser = {{.smtpUser}}
  smtpPass = {{.smtpPass}}
{{- end }}

  smtpEncryption = tls

  addInstanceNameInSubject = true

[sshd]
  listenAddress = *:29418

[httpd]
  listenUrl = proxy-https://*:8080/

[cache]
  directory = cache

[change]
  mergeabilityComputationBehavior = API_REF_UPDATED_AND_CHANGE_REINDEX

[cache "web_sessions"]
  maxAge = 90 days
  memoryLimit = 8192
  diskLimit = 256m

{{if .googleAuth -}}
[plugin "gerrit-oauth-provider-google-oauth"]
  client-id = {{.googleAuth.clientID}}
  client-secret = {{.googleAuth.clientSecret}}
  use-email-as-username = true
{{- end}}

[plugin "webhooks"]
  sslVerify = true

# Match Gerrit change IDs and link them to the same instance
[commentlink "changeid"]
  match = (I[0-9a-f]{8,40})
  link = "#/q/$1"

# Match fully-qualified issue links like github.com/monogon-dev/monogon#1
[commentlink "github-projectlink"]
  match = "([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)#([0-9]+)"
  link = "https://github.com/$1/$2/issues/$3"

\(config.extraConfig)
""", config)

// See https://gerrit.googlesource.com/gerrit/+/master/polygerrit-ui/app/styles/themes/app-theme.ts
// for available CSS variables.
let _customThemePlugin = """
const customTheme = document.createElement('dom-module');
customTheme.innerHTML = `<template>
    <style>
        html {
            --header-background-color: \(config.headerBackgroundColor);
            --header-text-color: \(config.headerForegroundColor);
            --header-title-content: "\(config.headerName)";
            --header-icon: url("\(config.headerIcon)");
            --header-icon-size: \(config.headerIconHeight);
        }
    </style>
</template>
`;
customTheme.register('theme-plugin');

Gerrit.install(plugin => {
  plugin.registerStyleModule('app-theme', 'theme-plugin');
});
"""

// GerritSite.css is only applied to the "classic" Gerrit UI, which is almost nothing
// these days (most is PolyGerrit and styled through plugins). However, some internal
// pages like the OAuth login page still use this and this is how to style them.
let _gerritSiteCss = """
	/* Clean up OAuth login form */

	#login_oauth {
			text-align: center;
	}

	#login_oauth form#login_form {
			margin: auto;
			width: 12em;
	}

	/* Button-ify the links */
	#login_oauth div#providers div {
			padding: 1em;
			border-style: solid;
			margin: 1em;
	}

	/* Replace button texts */
	#login_oauth div#providers a {
			font-size: 0;
	}

	#login_oauth div#-azure-oauth a:after {
			content: "Azure / Office365 (internal)";
			font-size: initial;
	}

	#login_oauth div#-google-oauth a:after {
			content: "Google";
			font-size: initial;
	}

	#login_oauth div#-github-oauth a:after {
			content: "GitHub";
			font-size: initial;
	}

	/* Remove the oversized oauth logo */
	#login_oauth #logo_img {
			display: none;
	}

	/* Why would anyone need a Cancel link? */
	#login_oauth div#providers + div {
			display: none;
	}

	/* Kill the generic "What is OAuth protocol" text */
	#login_oauth div#providers + div + div {
			display: none;
	}

	/* Remove "Available OAuth providers" text */
	#login_oauth #logo_box + div {
			display: none !important;
	}
	"""

k8s: {
	pvcs: {
		{[string]: spec: {
			resources: requests: storage: "50Gi"
			accessModes: ["ReadWriteOnce"]
		}}

		"gerrit-data": {}
	}

	services: gerrit: spec: {
		ports: [
			{
				name:       "web"
				protocol:   "TCP"
				port:       80
				targetPort: "web"
			},
			{
				name:       "git-ssh"
				protocol:   "TCP"
				port:       29418
				targetPort: "git-ssh"
			},
		]
		selector: app: "gerrit"
	}

	if config.sshLoadBalancerIP == _|_ {
		services: "gerrit-ssh": spec: {
			type: "NodePort"
			ports: [
				{
					name:       "git-ssh"
					protocol:   "TCP"
					port:       29418
					nodePort:   config.sshPort
					targetPort: "git-ssh"
				},
			]
			selector: app: "gerrit"
		}
	}

	if config.sshLoadBalancerIP != _|_ {
		services: "gerrit-ssh-lb": spec: {
			type:                  "LoadBalancer"
			externalTrafficPolicy: "Local"
			loadBalancerIP:        config.sshLoadBalancerIP
			ports: [
				{
					name:       "git-ssh"
					protocol:   "TCP"
					port:       config.sshPort
					targetPort: "git-ssh"
				},
			]
			selector: app: "gerrit"
		}
	}

	statefulsets: gerrit: spec: {
		updateStrategy: type: "RollingUpdate"
		podManagementPolicy: "Parallel"
		selector: matchLabels: app: "gerrit"
		template: {
			metadata: {
				labels: app: "gerrit"
				name: "gerrit"
			}
			spec: {
				securityContext: {
					runAsUser: 1000
					fsGroup:   1000
				}
				containers: [
					{
						name:  "gerrit"
						image: config.images.gerrit

						resources: {
							requests: memory: *"2Gi" | _
							requests: cpu:    *"2" | _
						}

						// We use an environment variable instead of a CM to pass the config:
						//
						//  - Only parts of the Gerrit config can be hot-reloaded. For correctness, we would have to
						//    redeploy the container by hashing the config into an annotation.
						//
						//  - Gerrit *really* wants a writable fs, so we can't just mount the CM to /var/gerrit/etc.
						env: [
							{name: "GERRIT_SITECSS", value:            _gerritSiteCss},
							{name: "GERRIT_CONFIG", value:             _gerritConfig},
							{name: "GERRIT_REPLICATION_CONFIG", value: config.replicationConfig},
							{name: "GERRIT_THEME_PLUGIN", value:       _customThemePlugin},
							if config.reinit {
								{name: "GERRIT_REINIT", value: "true"}
							},
						]

						ports: [
							{
								protocol:      "TCP"
								containerPort: 8080
								name:          "web"
							},
							{
								protocol:      "TCP"
								containerPort: 29418
								name:          "git-ssh"
							},
						]
						volumeMounts: [
							for k in ["git", "etc", "db", "index", "cache", "logs", "data", ".ssh"] {
								mountPath: "/var/gerrit/\(k)"
								name:      "gerrit-data"
								subPath:   k
							},
						]
					},
				]

				restartPolicy: "Always"
				volumes: [
					{
						name: "gerrit-data"
						persistentVolumeClaim: claimName: "gerrit-data"
					},
				]
			}
		}
	}
}
