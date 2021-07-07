// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

k8s: {for agentConfig in config.agents {
	pvcs: "jenkins-agent-\(agentConfig.name)-bazel": spec: {
		resources: requests: storage: "200Gi"
		accessModes: ["ReadWriteOnce"]
	}
	configmaps: "jenkins-agent-\(agentConfig.name)-configuration": data: {
		// Configure available resources and other CI 'niceties'.
		// Set available RAM to be slightly less than the amount of RAM
		// guaranteed by the container, so that the Jenkins agent, Bazel server
		// and source code in tmpfs fit.
		".bazelrc": """
			build --local_ram_resources=\(agentConfig.memory*1024-1024)
			build --local_cpu_resources=\(agentConfig.cpus)
			build --jobs=\(agentConfig.cpus)
			build --curses=no
			test --jobs=\(agentConfig.cpus)
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
						requests: memory: "\(agentConfig.memory)G"
						requests: cpu:    "\(agentConfig.cpus)"
						limits: memory:   "\(agentConfig.memory)G"
						limits: cpu:      "\(agentConfig.cpus)"
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
				// uid of 'ci' user in image.
				runAsUser: 500
				// gid of 'ci' group in image.
				runAsGroup: 1000
				fsGroup:    1000
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
