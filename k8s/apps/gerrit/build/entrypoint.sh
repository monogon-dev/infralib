#!/usr/bin/env bash
set -euo pipefail

export JAVA_OPTS='--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED'

# Initialize storage
if [[ ! -d /var/gerrit/git/All-Projects.git || ! -z "${GERRIT_REINIT:-}" ]]; then
  echo "Initializing Gerrit site ..."
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war init --batch -d /var/gerrit
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
fi

ln -s /var/gerrit/custom-plugins/* /var/gerrit/plugins/

echo "${GERRIT_CONFIG}" > /var/gerrit/etc/gerrit.config
echo "${GERRIT_THEME_PLUGIN}" > /var/gerrit/plugins/custom-theme.js

echo "Running Gerrit ..."
exec /var/gerrit/bin/gerrit.sh run
