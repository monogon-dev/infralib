// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

// We need to override the entrypoint in order to copy our config.
// See https://github.com/GerritCodeReview/docker-gerrit.
//
// We use an environment variable instead of a CM to pass the config:
//
//  - Only parts of the Gerrit config can be hot-reloaded. For correctness, we would have to
//    redeploy the container by hashing the config into an annotation.
//
//  - Gerrit *really* wants a writable fs, so we can't just mount the CM to /var/gerrit/etc.
//
let _gerritStartup = """
	set -euo pipefail
	
	export JAVA_OPTS='--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED'
	
	# Initialize storage
	if [[ ! -d /var/gerrit/git/All-Projects.git ]]; then
	  echo "Initializing Gerrit site ..."
	  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war init --batch --install-all-plugins -d /var/gerrit
	  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
	fi

	echo "${GERRIT_CONFIG}" > /var/gerrit/etc/gerrit.config
	
	echo "Running Gerrit ..."
	exec /var/gerrit/bin/gerrit.sh run
	"""

let _gerritConfig = """
[gerrit]
  basePath = git
  canonicalWebUrl = https://\(config.publicHostname)/
  serverId = \(config.serverID)

[sshd]
  advertisedAddress = \(config.publicHostname)

[container]
  javaOptions = "-Dflogger.backend_factory=com.google.common.flogger.backend.log4j.Log4jBackendFactory#getInstance"
  javaOptions = "-Dflogger.logging_context=com.google.gerrit.server.logging.LoggingContext#getInstance"
  user = gerrit
  javaHome = /usr/lib/jvm/java-11-openjdk-11.0.9.11-2.el8_3.x86_64
  javaOptions = -Djava.security.egd=file:/dev/./urandom
  javaOptions = --add-opens java.base/java.net=ALL-UNNAMED
  javaOptions = --add-opens java.base/java.lang.invoke=ALL-UNNAMED

[index]
  type = lucene

[auth]
  type = DEVELOPMENT_BECOME_ANY_ACCOUNT

[receive]
  enableSignedPush = false

[sendemail]
  smtpServer = localhost

[sshd]
  listenAddress = *:29418

[httpd]
  listenUrl = proxy-https://*:8080/

[cache]
  directory = cache
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
						command: ["/bin/bash", "-c", _gerritStartup]
						env: [{name: "GERRIT_CONFIG", value: _gerritConfig}]
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
