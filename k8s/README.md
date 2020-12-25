# k8s

**apps** contains generic application templates, without environment-specific configuration. Each application is a
*separate, self-contained module. It's incomplete when evaluated on its own, missing 

**contexts** maps these generic configs to concrete implementations and contain the environment-specific configuration.
*Contexts are defined hierarchically using Cue instances. All contexts belong to the same package.

## Usage

First, switch to the right scope:

    cd contexts/kube1.fsn1.he.global.monogon.dev

Deploy a specific context:

    cue -t context=monitoring-prod apply
    
View the config that would be applied:

    cue -t context=monitoring-prod dump
    
Diff against config on cluster:

    cue -t context=monitoring-prod diff

Evaluate all contexts in scope to concrete values 
(same computation as `dump`, but Cue syntax and error messages are more helpful):

    cue eval -c

Evaluate specific context in scope:

    cue eval -c -e 'contexts."monitoring-prod"'
