// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"encoding/yaml"
	"strings"
)

k8s: {
	pvcs: {
		{[string]: spec: {
			resources: requests: storage: "50Gi"
			accessModes: ["ReadWriteOnce"]
		}}

		"jenkins-controller-home": {}
	}

	// TODO(q3k): migrate this to a secret, as this holds OAuth client
	// configuration.
	configmaps: {
		"jenkins-controller-configuration": data: "cue.yaml": yaml.Marshal({
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
			}
			unclassified: {
				location: {
					adminAddress: config.adminAddress
					url:          "https://\(config.publicHostname)/"
				}
			}
		})
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
						]
						env: [
							{
								name:  "MONOGON_CONFIG_SHASUM"
								value: k8s.configmaps."jenkins-controller-configuration"._dataSum.full
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
						configMap: name: "jenkins-controller-configuration"
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
