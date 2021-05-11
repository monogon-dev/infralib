Jenkins agentlauncher
=====================

This is a wrapper to automatically download a Jenkins agent JAR from a controller and launch it.

It's layered into the Monogon monorepo build container image and ran as the entrypoint of the resulting image.

It takes standard jnlpUrl/secret flags that the Jenkins agent uses, plus a jarURL to download the agent JAR.
