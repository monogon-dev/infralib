// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

k8s: {for agentConfig in config.agents {
	pvcs: "jenkins-agent-\(agentConfig.name)-bazel": spec: {
		resources: requests: storage: "200Gi"
		accessModes: ["ReadWriteOnce"]
	}
	configmaps: "jenkins-agent-\(agentConfig.name)-configuration": data: {
		".bazelrc": """
			build --local_ram_resources=15360
			build --local_cpu_resources=16
			build --jobs=16
			build --curses=no
			test --jobs=16
			test --curses=no
			"""
	}
	statefulsets: "jenkins-agent-\(agentConfig.name)": spec: {
		updateStrategy: type: "RollingUpdate"
		podManagementPolicy: "Parallel"
		replicas:            1
		template: spec: {
			containers: [
				{
					name:       "agent"
					image:      config.images.agent
					workingDir: "/home/ci"
					command: [
						"/monogon-infra/k8s/apps/jenkins/build/agentlauncher",
						"-jarUrl",
						agentConfig.jarURL,
						"-jnlpUrl",
						agentConfig.jnlpURL,
						"-secret",
						agentConfig.secret,
					]
					env: [
						{
							name:  "HOME"
							value: "/home/ci"
						},
					]
					resources: {
						requests: memory: "16G"
						requests: cpu:    "16"
						limits: memory:   "16G"
						limits: cpu:      "16"
					}
					volumeMounts: [
						{
							mountPath: "/home/ci/.cache"
							name:      "jenkins-agent-bazel"
						},
						{
							mountPath: "/home/ci/.bazelrc"
							name:      "jenkins-agent-configuration"
							subPath:   ".bazelrc"
						},
						{
							mountPath: "/dev/kvm"
							name:      "dev-kvm"
						},
					]
					securityContext: {
						privileged: true
					}
				},
			]
			securityContext: {
				runAsUser:  994
				runAsGroup: 992
				fsGroup:    992
			}
			restartPolicy: "Always"
			volumes: [
				{
					name: "jenkins-agent-bazel"
					persistentVolumeClaim: claimName: "jenkins-agent-\(agentConfig.name)-bazel"
				},
				{
					name: "jenkins-agent-configuration"
					configMap: name: "jenkins-agent-\(agentConfig.name)-configuration"
				},
				{
					name: "dev-kvm"
					hostPath: path: "/dev/kvm"
				},
			]
		}
	}
}}
