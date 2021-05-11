// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"encoding/yaml"
	"encoding/base64"
	"strings"
)

k8s: {
	pvcs: {
		"jenkins-controller-home": spec: {
			resources: requests: storage: "50Gi"
			accessModes: ["ReadWriteOnce"]
		}
	}

	secrets: {
		"jenkins-controller-configuration": data: "cue.yaml": '\(base64.Encode(null, yaml.Marshal({
			jenkins: {
				numExecutors:          0
				scmCheckoutRetryCount: 2
				mode:                  "NORMAL"
				remotingSecurity: enabled: true
				authorizationStrategy: roleBased: roles: {
					// Configure global permissions as follows:
					// - A very small set of administrators have full access to
					//   the Jenkins UI
					// - All Monogon employees can do some basic job
					//   management, but not configuration
					// - Everyone else only has read-only access to jobs.
					//
					// At some point we will probably want to allow
					// non-Monogon-employeed to log in and manage jobs? Or
					// maybe that will just be deferred to Gerrit integration.
					global: [
						{
							name:        "admin"
							description: "Jenkins Administrators"
							permissions: [ "Overall/Administer"]
							assignments: config.admins
						},
						{
							name:        "monogon-internal"
							description: "Monogon Employees"
							permissions: [
								"Overall/Read",
								"Job/Build",
								"Job/Cancel",
								"Job/Discover",
								"Job/Read",
							]
							assignments: ["authenticated"]
						},
						{
							name:        "public"
							description: "Everyone"
							permissions: [
								"Overall/Read",
								"Job/Read",
							]
							assignments: ["unauthenticated"]
						},
					]
				}
				securityRealm: {
					googleOAuth2: {
						clientId:     config.googleAuth.clientID
						clientSecret: config.googleAuth.clientSecret
						domain:       strings.Join(config.googleAuth.restrictDomains, ",")
					}
				}
				nodes: [
					for agent in config.agents {
						permanent: {
							name:     agent.name
							remoteFS: "/home/ci/work"
						}
					},
				]
			}
			unclassified: {
				location: {
					adminAddress: config.adminAddress
					url:          "https://\(config.publicHostname)/"
				}
			}
		})))'

		// This script gets executed on the controller's startup and does the following:
		// - sets the HMAC key for agent secrets as configured by config.agentSecret.
		// - sets the agent listener hostname to the controller's kubernetes
		//   DNS name. This allows us to run agents on the same service fabric
		//   as the controller without having to expose the controller's agent
		//   listener port to the Internet.
		"jenkins-controller-init-scripts": data: "cue.groovy.override": '\(base64.Encode(null, '''
			logger = java.util.logging.Logger.getLogger('dev.monogon.infra.k8s.apps.jenkins')
			logger.info("Monogon: checking JNLP agent secret is as configured...")
			byte[] keyWant = ("\( base64.Encode(null, config.agentSecret) )").decodeBase64()
			hk = new jenkins.security.HMACConfidentialKey(jenkins.slaves.JnlpSlaveAgentProtocol.class, "secret");
			cs = jenkins.security.ConfidentialStore.get()
			byte[] keyGot = cs.load(hk)
			if (keyGot != keyWant) {
			    jenkins.security.ConfidentialStore.get().store(hk, keyWant)
			    logger.info("Monogon: secret differs, replaced, restarting instance...")
			    jenkins.model.Jenkins.instance.restart()
			} else {
			    logger.info("Monogon: secret correct, continuing startup...")
			}
			System.setProperty("hudson.TcpSlaveAgentListener.hostName", "\(config.internalHostname)")
			'''))'
	}

	deployments: "jenkins-controller": spec: {
		replicas: 1
		strategy: {
			type: "RollingUpdate"
			rollingUpdate: {
				maxUnavailable: 1
				maxSurge:       0
			}
		}
		template: {
			spec: {
				containers: [
					{
						name:  "jenkins"
						image: config.images.controller
						ports: [
							{
								protocol:      "TCP"
								containerPort: 8080
								name:          "web"
							},
							{
								protocol:      "TCP"
								containerPort: 50000
								name:          "agent"
							},
						]
						volumeMounts: [
							{
								mountPath: "/var/jenkins_home"
								name:      "jenkins-controller-home"
							},
							{
								mountPath: "/var/jenkins_config"
								name:      "jenkins-controller-configuration"
							},
							{
								mountPath: "/usr/share/jenkins/ref/init.groovy.d"
								name:      "jenkins-controller-init-scripts"
							},
						]
						env: [
							{
								name:  "MONOGON_CONFIG_SHASUM"
								value: k8s.secrets."jenkins-controller-configuration"._dataSum.full
							},
							{
								name:  "MONOGON_INIT_SCRIPTS_SHASUM"
								value: k8s.secrets."jenkins-controller-init-scripts"._dataSum.full
							},
							{
								name:  "CASC_JENKINS_CONFIG"
								value: "/var/jenkins_config"
							},
							{
								// Disable setup wizard. This leaves Jenkins in
								// an unsecure, unconfigured state by default.
								//
								// However, that is immediately reconfigured by
								// the Configuration-As-Code plugin, which
								// reads the configuration YAML from the
								// controller configuration configmap.
								//
								// This is the only way to get a pure
								// configured-by-code Jenkins, without having
								// administrators go through a setup wizard and
								// click things.
								name:  "JAVA_OPTS"
								value: "-Djenkins.install.runSetupWizard=false"
							},
							{
								// Force upgrade of plugins that ship with the
								// Jenkins image, or that have been installed
								// manually.
								name:  "TRY_UPGRADE_IF_NO_MARKER"
								value: "true"
							},
						]
					},
				]

				restartPolicy: "Always"
				volumes: [
					{
						name: "jenkins-controller-home"
						persistentVolumeClaim: claimName: "jenkins-controller-home"
					},
					{
						name: "jenkins-controller-configuration"
						secret: secretName: "jenkins-controller-configuration"
					},
					{
						name: "jenkins-controller-init-scripts"
						secret: secretName: "jenkins-controller-init-scripts"
					},
				]
			}
		}
	}

	services: "jenkins-controller": spec: {
		ports: [
			{
				name:       "web"
				protocol:   "TCP"
				port:       80
				targetPort: "web"
			},
			{
				name:       "agent"
				protocol:   "TCP"
				port:       50000
				targetPort: "agent"
			},
		]
		selector: deployments."jenkins-controller".spec.selector.matchLabels
	}

	ingressroutes: "jenkins-controller-tls": spec: {
		entryPoints: ["websecure"]
		routes: [
			{
				match: "Host(`\(config.publicHostname)`) && PathPrefix(`/`)"
				kind:  "Rule"
				services: [
					{
						kind:     "Service"
						name:     "jenkins-controller"
						port:     80
						protocol: "TCP"
					},
				]
			},
		]
	}
}
