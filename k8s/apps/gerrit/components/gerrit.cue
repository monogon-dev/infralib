// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

// https://gerrit-review.googlesource.com/Documentation/config-gerrit.html
let _gerritConfig = """
[gerrit]
  basePath = git
  canonicalWebUrl = https://\(config.publicHostname)/
  serverId = \(config.serverID)
  instanceName = \(config.instanceName)

[sshd]
  advertisedAddress = \(config.publicHostname):\(config.sshPort)

[container]
  javaOptions = "-Dflogger.backend_factory=com.google.common.flogger.backend.log4j.Log4jBackendFactory#getInstance"
  javaOptions = "-Dflogger.logging_context=com.google.gerrit.server.logging.LoggingContext#getInstance"
  user = gerrit
  javaHome = /usr/lib/jvm/java-11-openjdk-11.0.9.11-3.el8_3.x86_64
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
  email = \(config.userEmail)

[sendemail]
  smtpServer = \(config.smtpServer)
  smtpServerPort = \(config.smtpPort)
  smtpUser = \(config.smtpUser)
  smtpPass = \(config.smtpPass)

  smtpEncryption = tls

  addInstanceNameInSubject = true

[sshd]
  listenAddress = *:29418

[httpd]
  listenUrl = proxy-https://*:8080/

[cache]
  directory = cache

[plugin "gerrit-oauth-provider-google-oauth"]
  client-id = \(config.googleAuth.clientID)
  client-secret = \(config.googleAuth.clientSecret)
  use-email-as-username = true

[plugin "webhooks"]
  sslVerify = true

[experiments]
  # Fancy new checks tab
  enabled = UiFeature__ci_reboot_checks
  # https://gerrit-review.googlesource.com/c/gerrit/+/286259
  enabled = UiFeature__new_change_summary_ui
  # https://gerrit-review.googlesource.com/c/gerrit/+/297181
  enabled = UiFeature__new_image_diff_ui
  # https://gerrit-review.googlesource.com/c/gerrit/+/293506
  enabled = UiFeature__comment_context

# Match Gerrit change IDs and link them to the same instance
[commentlink "changeid"]
  match = (I[0-9a-f]{8,40})
  link = "#/q/$1"

# Match fully-qualified issue links like github.com/monogon-dev/monogon#1
[commentlink "github-projectlink"]
  match = "([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)#([0-9]+)"
  link = "https://github.com/$1/$2/issues/$3"

\(config.extraConfig)
"""

let _customThemePlugin = """
const customTheme = document.createElement('dom-module');
customTheme.innerHTML = `<template>
    <style>
        html {
            --header-background-color: \(config.headerBackgroundColor);
            --header-text-color: \(config.headerForegroundColor);
            --header-title-content: "\(config.headerName)";
        }
    </style>
</template>
`;
customTheme.register('theme-plugin');

Gerrit.install(plugin => {
  plugin.registerStyleModule('app-theme', 'theme-plugin');
});
"""

k8s: {
	pvcs: {
		{[string]: spec: {
			resources: requests: storage: "50Gi"
			accessModes: ["ReadWriteOnce"]
		}}

		"gerrit-data": {}
	}

	ingressroutes: "gerrit-tls": {
		spec: {
			entryPoints: ["websecure"]
			routes: [
				{
					match: "Host(`\(config.publicHostname)`) && PathPrefix(`/`)"
					kind:  "Rule"
					services: [
						{
							kind:     "Service"
							name:     "gerrit"
							port:     80
							protocol: "TCP"
						},
					]
				},
			]
		}
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
				containers: [
					{
						name:  "gerrit"
						image: config.images.gerrit

						// We use an environment variable instead of a CM to pass the config:
						//
						//  - Only parts of the Gerrit config can be hot-reloaded. For correctness, we would have to
						//    redeploy the container by hashing the config into an annotation.
						//
						//  - Gerrit *really* wants a writable fs, so we can't just mount the CM to /var/gerrit/etc.
						env: [
							{name: "GERRIT_CONFIG", value:       _gerritConfig},
							{name: "GERRIT_THEME_PLUGIN", value: _customThemePlugin},
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
							for k in ["git", "etc", "db", "index", "cache", "logs", "data"] {
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
