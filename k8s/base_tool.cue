// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

// Read context from command line argument (i.e. -t context=example.com), in addition to the implicit scope. We
// currently support deployment to only one, explicitly specified context at the time. The alternative would be to
// iterate over all contexts by default if no context is specified, deploying all contexts defined in the scope.
contextName: string @tag(context)
context:     contexts[contextName]

objects: [ for v in objectSets for x in v {x}]

// Specify order in which to apply k8s objects.
objectSets: [
	context.objects.serviceaccounts,
	context.objects.secrets,
	context.objects.configmaps,
	context.objects.pvcs,
	context.objects.services,
	context.objects.statefulsets,
	context.objects.deployments,
	context.objects.validatingwebhookconfigurations,
	context.objects.mutatingwebhookconfigurations,
	context.objects.clusterrolebindings,
	context.objects.clusterroles,
	context.objects.rolebindings,
	context.objects.roles,

	context.objects.ingressroutes,
]

// Prerequisite objects to apply first, in a separate kubectl call.
preObjects: [ for v in [
	context.objects.namespaces,
	context.objects.crdsLegacy,
	context.objects.crds,
] for x in v {x}]

RemoteTask: {
	_cmd: string

	if context.hostname == "local" {
		cmd: _cmd
	}
	if context.hostname != "local" {
		cmd: "ssh \(context.hostname) \(_cmd)"
	}
}
