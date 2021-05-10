// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

const (
	// pluginAPIURL is a template URL for retrieving information about a
	// Jenkins plugin. This API is public, but not publicly documented.
	pluginAPIURL = "https://plugins.jenkins.io/api/plugin/%s"
	// pluginDownloadURL is a template URL for retrieving an HTML page
	// containing download links and SHA256 sums for plugins. There is no
	// public API for this, so we scrape this download page instead.
	pluginDownloadURL = "https://updates.jenkins.io/download/plugins/%s/"
)

var (
	// downloadSHA256 is a regex that matches SHA256 sums in updates.jenkins.io
	// HTML.
	downloadSHA256 = regexp.MustCompile(`SHA-256: ([0-9a-f]{64})`)
)

// pluginsAPIPlugin is information about a plugin retrieved from
// plugins.jenkins.io
type pluginsAPIPlugin struct {
	Dependencies []pluginsAPIDependency `json:"dependencies"`
	Name         string                 `json:"name"`
	URL          string                 `json:"url"`
	Version      string                 `json:"version"`
}

// pluginsAPIDependency is information about a plugins' dependencies, part of
// the pluginsAPIPlugin structure.
type pluginsAPIDependency struct {
	Name     string `json:"name"`
	Version  string `json:"version"`
	Optional bool   `json:"optional"`
	Implied  bool   `json:"implied"`
}

// getPluginsInfo retrieves information about a plugin from plugins.jenkins.io.
func getPluginInfo(ctx context.Context, plugin string) (*pluginsAPIPlugin, error) {
	url := fmt.Sprintf(pluginAPIURL, plugin)
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("NewRequest(GET %q): %w", url, err)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("Client.Do(GET %q): %w", url, err)
	}
	defer res.Body.Close()
	switch res.StatusCode {
	case 200:
	case 404:
		return nil, fmt.Errorf("plugin not found")
	default:
		return nil, fmt.Errorf("unexpected response %v", res.Status)
	}

	pi := pluginsAPIPlugin{}
	err = json.NewDecoder(res.Body).Decode(&pi)
	if err != nil {
		return nil, fmt.Errorf("Decode(%q): %w", url, err)
	}
	return &pi, nil
}

// getPluginSHA256 retrieves the lowercase-hex-encoded SHA256 sum of a plugin
// at a given version from updates.jenkins.io.
func getPluginSHA256(ctx context.Context, plugin, version string) (string, error) {
	url := fmt.Sprintf(pluginDownloadURL, plugin)
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return "", fmt.Errorf("NewRequest(GET %q): %w", url, err)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("Client.Do(GET %q): %w", url, err)
	}
	defer res.Body.Close()
	defer res.Body.Close()
	switch res.StatusCode {
	case 200:
	case 404:
		return "", fmt.Errorf("plugin not found")
	default:
		return "", fmt.Errorf("unexpected response %v", res.Status)
	}

	scanner := bufio.NewScanner(res.Body)
	for scanner.Scan() {
		line := scanner.Text()
		if !strings.HasPrefix(line, "<tr>") {
			continue
		}
		if !strings.Contains(line, fmt.Sprintf("%s/%s/%s.hpi", plugin, version, plugin)) {
			continue
		}
		matches := downloadSHA256.FindStringSubmatch(line)
		if len(matches) != 2 {
			return "", fmt.Errorf("could not find SHA-256 in line %q", line)
		}
		return matches[1], nil
	}
	return "", fmt.Errorf("plugin version not found")
}
