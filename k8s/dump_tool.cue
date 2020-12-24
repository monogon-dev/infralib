// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

import (
	"encoding/yaml"
	"encoding/json"
)

command: {
	dump: {
		task: print: {
			kind: "print"
			text: yaml.MarshalStream(objects)
		}
	}
	dumpjson: {
		task: print: {
			kind: "print"
			text: json.MarshalStream(objects)
		}
	}
}
