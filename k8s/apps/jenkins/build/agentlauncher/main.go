// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"flag"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"syscall"
)

var (
	flagJARURL  string
	flagJNLPURL string
	flagSecret  string
)

func main() {
	flag.StringVar(&flagJARURL, "jarUrl", "", "Agent JAR URL")
	flag.StringVar(&flagJNLPURL, "jnlpUrl", "", "JNLP URL used by agent to connect to controller")
	flag.StringVar(&flagSecret, "secret", "", "Secret used by agent to authenticate to controller")
	flag.Parse()

	if flagJARURL == "" {
		log.Fatalf("-jarUrl must be set")
	}
	if flagJNLPURL == "" {
		log.Fatalf("-jnlpUrl must be set")
	}
	if flagSecret == "" {
		log.Fatalf("-secret must be set")
	}

	jarDir, err := ioutil.TempDir("", "agentlauncher-")
	if err != nil {
		log.Fatalf("TempDir failed: %v", err)
	}
	jarPath := jarDir + "/" + "agent.jar"

	log.Printf("Downloading agent JAR from %s to %s...", flagJARURL, jarPath)
	resp, err := http.Get(flagJARURL)
	if err != nil {
		log.Fatalf("Get(%q): %v", flagJARURL, err)
	}
	jarFile, err := os.Create(jarPath)
	if err != nil {
		resp.Body.Close()
		log.Fatalf("Create: %v", err)
	}
	_, err = io.Copy(jarFile, resp.Body)
	resp.Body.Close()
	jarFile.Close()

	if err != nil {
		log.Fatalf("Copy: %v", err)
	}

	log.Printf("Agent JAR downloaded, starting...")
	if err := syscall.Exec("/usr/bin/java", []string{"java", "-jar", jarPath, "-jnlpUrl", flagJNLPURL, "-secret", flagSecret}, os.Environ()); err != nil {
		log.Fatalf("exec failed: %v", err)
	}
}
