# k8s

**apps** contains generic application templates, without environment-specific configuration. Each application is a
*separate, self-contained module. It's incomplete when evaluated on its own, missing 

**contexts** maps these generic configs to concrete implementations and contain the environment-specific configuration.
*Contexts are defined hierarchically using Cue instances. All contexts belong to the same package.

The top-level tooling generates or applies a full-cluster k8s config for a given context.
