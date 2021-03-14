#!/usr/bin/env bash
set -euo pipefail

export JAVA_OPTS='--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED'

# Initialize storage
if [[ ! -d /var/gerrit/git/All-Projects.git ]]; then
  echo "Initializing Gerrit site ..."
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war init --batch --skip-plugins -d /var/gerrit
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
fi

echo "${GERRIT_CONFIG}" > /var/gerrit/etc/gerrit.config
echo "${GERRIT_THEME_PLUGIN}" > /var/gerrit/tmp/custom-theme.js

echo "Running Gerrit ..."
exec /var/gerrit/bin/gerrit.sh run
