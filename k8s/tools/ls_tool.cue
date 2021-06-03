// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package tools

import "strings"

command: ls: {
	task: print: {
		kind: "print"
		let Lines = [
			for x in objects {
				"\(x.kind)\t\(x.metadata.name)"
			}]
		text: strings.Join(Lines, "\n")
	}
}
