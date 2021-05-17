// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"crypto/hmac"
	"encoding/hex"
)

#GoogleAuth: {
	// Get credentials at https://console.cloud.google.com/apis/credentials
	clientID:     string
	clientSecret: string

	// List of 'employee' Google Workspace domains that can log in. Currently
	// this _must_ be set to at least one domain, as all authenticated users
	// get a set of basic 'employee' permissions that allows to run/cancel
	// builds. Thus, we want to prevent any external-but-logged-in user from
	// being granted these permissions.
	//
	// This approach to permissions might change in the future (and instead
	// non-employees might be allowed to log in, eg. open source contributors),
	// and then this requirement will be relaxed.
	restrictDomains: [string, ...string]
}

#Agent: {
	name: string
	// Name must be short enough and with a limited enough character set to
	// work as URL and potentially filesystem parts.
	name: =~"^[a-z0-9\\-_.]{1,16}$"

	// Secret used to provision agent against controller. Defaults to secret
	// generated from preconfigured controller HMAC key.
	secret: string | *hex.Encode(hmac.Sign("SHA256", config.agentSecret, name))

	// URL to download agent JAR from. Defaults to retrieving JAR from
	// controller.
	jarURL: string | *"https://\(config.publicHostname)/jnlpJars/agent.jar"

	// JNLP URL to connect agent JAR to. Defaults to standard URL for the
	// controller.
	jnlpURL: string | *"https://\(config.publicHostname)/computer/\(name)/jenkins-agent.jnlp"

	// Number of CPU cores available to the agent.
	cpus: int & >0 | *16
	// Gigabytes of memory available to the agent.
	// The agent always allocates one gigabyte of RAM for housekeeping, so this
	// has to be at least two gigabytes.
	memory: int & >1 | *16
}

// GerritPreSubmitJob is a Jenkins job that will run against open Gerrit
// changes and trigger the change's Jenkinsfile against the change directly
// (ie. not against the branch-as-if-merged - that should be done by 'landing
// strip' style integration).
#GerritPreSubmitJob: {
	// The generated 'Job DSL' script. This will be stuffed into the
	// controller's CasC YAML config, and will reconfigure the generated job on
	// Controller startup.
	//
	// This DSL is defined and implemented by the 'job-dsl' plugin. A reference
	// of options supported by a server is available at the following URL:
	//
	//    https://jenkins-dev.monogon.dev/plugin/job-dsl/api-viewer/index.html
	//
	// Note that installed plugins influence the available options, so it's
	// best to check directly on the controller that you're developing/testing
	// against.
	script: """
		multibranchPipelineJob('gerrit-presubmit-\(name)') {
			branchSources {
				branchSource {
					source {
						// This is gerrit-code-review (G-C-R)'s fetch from
						// gerrit functionality, that automatically discovers
						// open change requests.
						gerrit {
							id "gerrit-presubmit-\(name)"
							credentialsId "\(gerritCredentials)"
							remote "https://\(gerritDomain)/a/\(gerritProject)"
							traits {
								changeDiscoveryTrait {
									queryString "\(gerritQuery)"
								}
								// This refspec has to be configured, otherwise
								// the Git SCM fetch is ran with the following:
								//
								// git fetch --tags --progress --prune origin \\
								//    +refs/heads/:refs/remotes/origin/ \\
								//    refs/changes/22/122/2:refs/remotes/origin/22/122/2
								//
								// This seemingly causes the 22/122/2 remote
								// branch/change to be fetched into
								// refs/heads/22/122/2 instead of
								// refs/changes/22/122/2. This then causes
								// G-C-R to not find the change that it just
								// requested (as it expects the change to live
								// in refs/changs, not refs/heads, and
								// seemingly the above default refhead
								// overrides the change-specific fetch).
								//
								// We set the refSpecTemplate to a 'no-op'
								// refspec that the Git SCM plugin accepts, but
								// which doesn't squash the specifically
								// requested CR ref.
								//
								// This likely happens because we're using a
								// Git SCM plugin release that's not
								// tested/compatible with gerrit-code-review.
								// The only trace of someone having a similar
								// problem on the Internet is a G-C-R issue:
								//
								// https://issues.jenkins.io/browse/JENKINS-60965
								//
								refSpecsSCMSourceTrait {
									templates {
										refSpecTemplate {
											value "+refs/doesnotexist/*:refs/remotes/@{remote}/doesnotexist/*"
										}
									}
								}
								// Filter out everything that's not a change.
								// Without this, this job will build any
								// branches that are fetched by default on
								// repository initialization (eg. the main
								// branch). Building the main branch is
								// something that should be done, but not by
								// the presubmit job.
								headRegexFilter {
									regex "[0-9]+/[0-9]+/[0-9]+"
								}
								// This might not be strictly necessary, as no
								// code executes on the controller, but is
								// useful just in case.
								wipeWorkspaceTrait {
								}
								// We explicitly do not configure G-C-R's
								// filter-by-pending-checks functionality, as
								// it seems to be broken in combination with
								// filtering by change search.
								//
								// The failure mode has not been throughtly
								// investigated, but what seems to be happening
								// is the following:
								//
								// 1. G-C-R runs a reindex, either as scheduled
								//    or as triggered by a gerrit webhook.
								// 2. G-C-R discovers that there is a change
								//    open with pending checks, so it marks the
								//    checks as 'scheduled' and continues
								//    determining whether the changes should be
								//    run.
								// 3. G-C-R filters out branches corresponding
								//    to the discovered CR because they do not
								//    satisfy the search query string.
								// 4. G-C-R aborts executing the Jenkinsfile
								//    for the CR, but since it already marked
								//    the checks for this CR as 'scheduled'
								//    (or, in general, has enabled some
								//    integration functionality for checks), it
								//    flips these checks to 'succeeded', even
								//    though they have not been marked as such
								//    by the Jenkinsfile logic itelf.
								// 5. Some external action causes the change to
								//    now not be filtered by the queryString
								//    (eg., another label is change during code
								//    review, and a query which was filtering
								//    out by label now returns the change).
								// 6. G-C-R re-scans the change. However, as it
								//    filters by pending checks, and the change
								//    already has the checks marked as
								//    succeeded (in point 4), it ignores the
								//    change and never triggers CI.
								//
								// TODO(serge): investigate this further and
								// file an upstream issue if the above is true.
							}
						}
					}
				}
			}
			orphanedItemStrategy {
				// We discard all build items after 90 days. We do this to save space.
				//
				// This means, however (due to the fact that we do not filter
				// by checks in gerrit-code-review's branch source) that some
				// deleted items (ie. long-standing change requests) will be
				// spuriously rebuilt. That's because Jenkins has no way to
				// know that a given item has already been built for a given
				// SCM source. That is, unless, Jenkin's orphaned item
				// collection is smart enough to not remove things that are
				// immediately going to be rebuilt on SCM source reindex.
				//
				// Determining whether this is a bug or a feature is left as a
				// philosophical exercise to the reader.
				discardOldItems {
					daysToKeep 90
				}
			}
			triggers {
				periodicFolderTrigger {
					interval '30m'
				}
			}
		}
		"""
	// The name of the job. A limited alphabet/length ensures this is safe to
	// use as part of a larger name or within URL/path parts.
	name: =~"^[a-z0-9\\-]{3,16}$"
	// The ID of credentials used to authenticate against gerrit. This should
	// correspond to the name field of a Credential within #Config.credentials.
	gerritCredentials: string
	// The domain at which the Gerrit instance runs, eg. foo.example.com.
	gerritDomain: string
	// The Gerrit project/repository that this job should build, eg. monogon.
	gerritProject: string
	// The Gerrit search query used to find changes that need to be built.
	// Reference:
	//   https://gerrit-documentation.storage.googleapis.com/Documentation/user-search.html#search-operators
	gerritQuery: string
}

// A Jenkins credential, currently always a username:password pair. This
// credential will be saved into the Jenkins Controller CasC YAML.
#Credential: {
	name:     =~"^[a-z0-9\\-]{3,16}$"
	username: string
	password: string
}

#Config: {
	images: {
		controller: "gcr.io/monogon-infra/jenkins-controller:2.289-centos7-6"
		agent:      "gcr.io/monogon-infra/jenkins-agent:monogon-builder-19c98c7be48005d26d813c66ff9d491a5b39375b"
	}

	// Hostname for Jenkins to run on (without https://)
	publicHostname: string

	// Internal hostname that agents will connect to via the Jenkins binary agent protocol.
	// If agents and controller run within the same Kubernetes service/DNS
	// fabric, this should be set to
	// "jenkins-controller.<controllernamespace>.svc.cluster.local".
	//
	// TODO(q3k): can we populate a default automatically? It doesn't seem like
	// we have access to the context's namespace, and the k8s objects available
	// in this scope don't have their namespace set...
	internalHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// Email address of Jenkins administrator. Currently unused, but in the
	// future might receive administrative emails.
	adminAddress: string

	// List of admin accounts, as Google account email addresses. These
	// accounts will have a permission to fully manage the Jenkins installation
	// at runtime. This permission shouldn't need to be exercised often, as all
	// configuration should be managed by code, and is more of a break-glass
	// procedure than anything else.
	admins: [...string]

	googleAuth: #GoogleAuth

	// 32 bytes of secret data used as HMAC key by the controller for
	// generating Agent secrets. This key is usually autogenerated by the
	// Jenkins controller and kept secret, but we override it on startup to the
	// configured value.
	//
	// This HMAC key is then used by Jenkins to generate secrets for Agents
	// (agentSecret = HMAC_SHA256(secret, agentName)). These secrets are used
	// by Agents to authenticate to the Controller, and we want to have these
	// secrets available within CUE to configure the agents.
	//
	// Thus, without sequencing the controller startup and retrieving data from
	// when it's running, we have no way of knowing these agent secrets other
	// than to preconfigure the key and replicate the HMAC secret derivation.
	agentSecret:        bytes
	_agentSecretLength: len(agentSecret) == 32
	_agentSecretLength: true

	// List of agents to run within the same namespace as the controller.
	agents: [...#Agent]

	// Gerrit presubmit jobs that this Jenkins controller should manage.
	gerritPreSubmitJobs: [...#GerritPreSubmitJob]
	jobs: [ for j in gerritPreSubmitJobs {
		script: j.script
	}]

	// Credentials that should be available to the Jenkins Controller.
	credentials: [...#Credential]
}

config: #Config
