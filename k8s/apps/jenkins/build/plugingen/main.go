// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"sort"
	"strings"
)

// resolvedPlugin is a plugin picked by plugingen, with a given name and at a
// given version.
type resolvedPlugin struct {
	name    string
	version string
	sha256  string
}

// repositoryName generates a Bazel repository name for the plugin. This will
// be used to genereate Bazel external repositories, and refer to them in build
// macros.
func (r *resolvedPlugin) repositoryName() string {
	return fmt.Sprintf("jenkins_%s_plugin_release", strings.ReplaceAll(r.name, "-", "_"))
}

// fileName generates the file name at which the plugin will be downloaded.
func (r *resolvedPlugin) fileName() string {
	return fmt.Sprintf("%s.jpi", r.name)
}

// url generates a download URL for the plugin.
func (r *resolvedPlugin) url() string {
	return fmt.Sprintf("https://updates.jenkins.io/download/plugins/%s/%s/%s.hpi", r.name, r.version, r.name)
}

// dependencyTree is a map from a plugin name into a list of plugins names that
// requested it.
type dependencyTree map[string][]string

// add a (plugin, requiredBy) pair to the tree.
func (d dependencyTree) add(plugin, requiredBy string) {
	d[plugin] = append(d[plugin], requiredBy)
}

// findShortest returns the shortest path from a given plugin to a plugin that
// (transitively) requires it.
func (d dependencyTree) findShortest(from, to string) []string {
	for _, dep := range d[from] {
		if dep == to {
			return []string{to}
		}
		path := d.findShortest(dep, to)
		if path == nil {
			continue
		}
		return append([]string{dep}, path...)
	}
	return nil
}

var (
	flagPlugins         string
	flagWorkspaceMacros string
	flagBuildMacros     string

	// defaultPlugins is a top-level list of plugins requested to be present
	// within the Jenkins controller image. All specified plugins will install
	// at their newest available version.
	//
	// If you want to install more plugins into Monogon's Jenkins instances,
	// you've come to the right place - modify this list and:
	//
	//   $ bazel run//:jenkins_plugingen
	//
	// If you're using this tool outside of Monogon, you can also override the
	// -plugingen_plugins when running plugingen, any value set there takes
	// precedence over this list.
	defaultPlugins = []string{
		// Provides the ability to configure Jenkins via YAML files on startup.
		"configuration-as-code",
		// Provides Google Workspace (ex. GSuite) login.
		"google-login",
		// Provides fine-grained RBAC for internal permissions.
		"role-strategy",
		// Provides integration with Gerrit.
		"gerrit-code-review",
		// Provides a level of security against rogue builds (eg. modified
		// Jenkinsfile, or rogue semi-privileged user that can modify jobs but
		// does not have full controller access) by allowing them limited
		// privileges when interacting with the controller, preventing
		// privilege escalation.
		"authorize-project",
		// Provides 'Jenkins Pipeline' functionality, ie. build configuration
		// through Jenkins files in repositories.
		"workflow-aggregator",
		// Provides the ability to configure Jenkins jobs from init scripts.
		// Even if you use Jenkinsfiles, you still need to first configure a
		// job that will actually use these Jenkinsfiles.
		"job-dsl",
		// Provides a modern frontend for the pipeline plugin.
		"blueocean",
	}
)

func main() {
	flag.StringVar(&flagPlugins, "plugingen_plugins", strings.Join(defaultPlugins, ","), "Comma-separated list of Jenkins plugins")
	flag.StringVar(&flagWorkspaceMacros, "plugingen_workspace_macros", "", "Path to generated file that will contain workspace starlark macros")
	flag.StringVar(&flagBuildMacros, "plugingen_build_macros", "", "Path to generated file that will contain build starlark macros")
	flag.Parse()
	ctx := context.Background()

	if flagWorkspaceMacros == "" {
		log.Fatalf("-plugingen_workspace_macros must be set")
	}
	if flagBuildMacros == "" {
		log.Fatalf("-plugingen_build_macros must be set")
	}

	// queue for BFS of plugins and their dependencies.
	var q []string

	// Start with requested plugins in the queue.
	for _, p := range strings.Split(flagPlugins, ",") {
		q = append(q, strings.TrimSpace(p))
	}

	// Start with requested plugin marked as requested by 'toplevel'.
	requiredBy := make(dependencyTree)
	for _, el := range q {
		requiredBy.add(el, "toplevel")
	}

	// Map from plugin name to resolved plugin, populated by the BFS as plugin
	// metadata is retrieved. Initially the resolved plugins do not have their
	// SHA256 set, as that is not available from the plugin API service.
	resolved := make(map[string]*resolvedPlugin)

	// Perform BFS of plugins and their dependencies.
	for {
		if len(q) == 0 {
			break
		}
		// Pop from queue.
		el := q[0]
		q = q[1:]

		// Ignore if already resolved.
		if _, ok := resolved[el]; ok {
			continue
		}

		log.Printf("Processing %s...", el)
		info, err := getPluginInfo(ctx, el)
		if err != nil {
			log.Fatalf("getPluginInfo(%q): %v", el, err)
		}

		resolved[el] = &resolvedPlugin{
			name:    el,
			version: info.Version,
		}

		// Enqueue dependencies.
		for _, dep := range info.Dependencies {
			if dep.Implied || dep.Optional {
				continue
			}
			log.Printf("   %s depends on %s...", el, dep.Name)
			requiredBy.add(dep.Name, el)
			q = append(q, dep.Name)
		}
	}

	// Populate SHA256 from download portal.
	for _, data := range resolved {
		log.Printf("Getting SHA256 of %s...", data.name)
		sha256, err := getPluginSHA256(ctx, data.name, data.version)
		if err != nil {
			log.Fatalf("Plugin %s at %s: could not retrieve sha256: %v", data.name, data.version, err)
		}
		data.sha256 = sha256
	}

	// Sort plugins by name.
	var resolvedSorted []*resolvedPlugin
	for _, data := range resolved {
		resolvedSorted = append(resolvedSorted, data)
	}
	sort.Slice(resolvedSorted, func(i, j int) bool { return resolvedSorted[i].name < resolvedSorted[j].name })

	// Write WORKSPACE macros.
	fw, err := os.Create(flagWorkspaceMacros)
	if err != nil {
		log.Fatalf("Could not open workspace macros file: %v", err)
	}
	defer fw.Close()

	fmt.Fprintf(fw, "# Generated by //k8s/apps/jenkins/build/plugingen, do not edit manually.\n")
	fmt.Fprintf(fw, "load(%q, %q)\n", "@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
	fmt.Fprintf(fw, "def jenkins_plugin_repositories():\n")
	for _, data := range resolvedSorted {
		fmt.Fprintf(fw, "    # Jenkins plugin %s, required by: %v\n", data.name, strings.Join(requiredBy.findShortest(data.name, "toplevel"), " -> "))
		fmt.Fprintf(fw, "    http_file(\n")
		fmt.Fprintf(fw, "        name = %q,\n", data.repositoryName())
		fmt.Fprintf(fw, "        downloaded_file_path = %q,\n", data.fileName())
		fmt.Fprintf(fw, "        sha256 = %q,\n", data.sha256)
		fmt.Fprintf(fw, "        urls = [%q],\n", data.url())
		fmt.Fprintf(fw, "    )\n")
	}
	fmt.Fprintf(fw, "\n")

	// Write BUILD macros.
	fb, err := os.Create(flagBuildMacros)
	if err != nil {
		log.Fatalf("Could not open build macros file: %v", err)
	}
	defer fb.Close()

	fmt.Fprintf(fb, "# Generated by //k8s/apps/jenkins/build/plugingen, do not edit manually.\n")
	fmt.Fprintf(fb, "def jenkins_plugin_files_all():\n")
	fmt.Fprintf(fb, "     return [\n")
	for _, data := range resolvedSorted {
		ref := fmt.Sprintf("@%s//file:%s", data.repositoryName(), data.fileName())
		fmt.Fprintf(fb, "        %q,\n", ref)
	}
	fmt.Fprintf(fb, "     ]\n")
	fmt.Fprintf(fb, "\n")
}
