package components

import (
	"infralib.monogon.dev/k8s/base"
)

k8s: base.#KubernetesBase

// See apps/jenkins/components
k8s: statefulsets: [Name=string]: spec: serviceName: Name
k8s: deployments: [Name=string]: spec: {
	selector: matchLabels: app: Name
	template: metadata: {
		labels: app: Name
		name: Name
	}
}
k8s: statefulsets: [Name=string]: spec: {
	selector: matchLabels: app: Name
	template: metadata: {
		labels: app: Name
		name: Name
	}
}

let digest = "sha256:137c9580e2ef897f764753ea3c3c7df163cecea09721533cb26a82b656359a1e"
config: images: agent: "gcr.io/monogon-infra/gha-agent@\(digest)"

k8s: {for agentConfig in config.agents {
	pvcs: "gha-agent-\(agentConfig.name)-cache": spec: {
		resources: requests: storage: "400Gi"
		accessModes: ["ReadWriteOnce"]
	}
	pvcs: "gha-agent-\(agentConfig.name)-config": spec: {
		resources: requests: storage: "1Gi"
		accessModes: ["ReadWriteOnce"]
	}

	secrets: "gha-agent-token-\(agentConfig.name)": {
		type: "Opaque"
		stringData: "api-token": agentConfig.token
	}

	statefulsets: "gha-agent-\(agentConfig.name)": spec: {
		updateStrategy: type: "RollingUpdate"
		podManagementPolicy: "Parallel"
		replicas:            1
		template: spec: {
			containers: [
				{
					name:  "agent"
					image: config.images.agent
					command: ["/run_agent.sh"]
					workingDir: "/home/ci"
					env: [
						{
							name:  "HOME"
							value: "/home/ci"
						},
						{
							name: "GHA_TOKEN"
							valueFrom: secretKeyRef: {
								name: "gha-agent-token-\(agentConfig.name)", key: "api-token"
							}
						},
					]
					volumeMounts: [
						{
							mountPath: "/home/ci/.cache"
							name:      "gha-agent-cache"
						},
						{
							mountPath: "/config"
							name:      "gha-agent-config"
						},
						{
							mountPath: "/dev/kvm"
							name:      "dev-kvm"
						},
					]
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
					name: "gha-agent-cache"
					persistentVolumeClaim: claimName: "gha-agent-\(agentConfig.name)-cache"
				},
				{
					name: "gha-agent-config"
					persistentVolumeClaim: claimName: "gha-agent-\(agentConfig.name)-config"
				},
				{
					name: "dev-kvm"
					hostPath: path: "/dev/kvm"
				},
			]
		}
	}
}}
