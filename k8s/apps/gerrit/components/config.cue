// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#GoogleAuth: {
	// Get credentials at https://console.cloud.google.com/apis/credentials
	clientID:     string
	clientSecret: string
}

#Config: {
	images: {
		gerrit: "gcr.io/nexantic-infra/gerrit:3.3.2-6@sha256:99ac0c257ddb27259801664669c1f9d326c8eb1455d9647d61b45359f531098c"
	}

	// Hostname for Gerrit to run on (without https://)
	publicHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// UUID4 which identifies this instance.
	serverID: string

	// Google OAuth credentials
	googleAuth: #GoogleAuth

	// SMTP authentication
	smtpServer: string
	smtpPort:   uint
	smtpUser:   string
	smtpPass:   string

	// Gerrit's own email address (for Git commits and notification mails)
	userEmail: string

	// NodePort requested from the cluster. The service needs to be manually
	// deleted before changing this on an existing cluster.
	sshPort: uint & >=30000 & <=32767

	// Human-readable short name for the instance (will be part of the email subject line)
	instanceName: string

	// Custom title displayed in Gerrit's header
	headerName:            string
	headerBackgroundColor: string & =~"^#(?:[0-9a-fA-F]{3}){1,2}$"
	headerForegroundColor: string & =~"^#(?:[0-9a-fA-F]{3}){1,2}$"

	// Extra configuration to add to the main Gerrit config file
	extraConfig: string | *""
}

config: #Config
