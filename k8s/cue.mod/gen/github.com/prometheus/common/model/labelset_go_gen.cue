// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/prometheus/common/model

package model

// A LabelSet is a collection of LabelName and LabelValue pairs.  The LabelSet
// may be fully-qualified down to the point where it may resolve to a single
// Metric in the data store or not.  All operations that occur within the realm
// of a LabelSet can emit a vector of Metric entities to which the LabelSet may
// match.
#LabelSet: _
