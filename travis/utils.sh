# Note that each of these functions runs in a subshell (defined with
# `()`, rather than `{}`).
#
# Incredibly, this snippet
#
#  set -o pipefail
#  local v=$(/bin/false | echo nope)
#  [[ $? != 0 ]] && echo failed
#
# behaves differently from this one
#
#  set -o pipefail
#  v=$(/bin/false | echo nope)
#  [[ $? != 0 ]] && echo failed
#
# Thanks, bash.

install_cli() (
  set -o pipefail
  APPLAND_CLI_DOWNLOAD_URL="$(curl -fsSL https://api.github.com/repos/applandinc/appland-cli/releases/latest \
    | jq -e -r '.assets[] | select(.name | contains("Linux")).browser_download_url')"
  if [[ $? != 0 ]]; then
    echo 'Failed to find Linux release of appland CLI'
    return 1
  fi

  curl -fsSL "${APPLAND_CLI_DOWNLOAD_URL}" \
    | tar xz --directory /usr/local/bin appland
  if [[ $? != 0 ]]; then
    echo "Failed to download appland cli from $APPLAND_CLI_DOWNLOAD_URL"
    return 1
  fi
  touch ~/.appland
)

install_appmap_java() (
  set -o pipefail
  APPMAP_JAVA_VERSION=java8
  JAVAP_VERSION=$(javap -version | cut -d. -f1,2)
  [[ "$JAVAP_VERSION" == 11.0 ]] && APPMAP_JAVA_VERSION=java11

  APPMAP_JAR_DOWNLOAD_URL="$(curl -fsSL https://api.github.com/repos/applandinc/appmap-java/releases/latest \
    | jq -e --arg java_version $APPMAP_JAVA_VERSION  -r '.assets[] | select(.name | contains($java_version)).browser_download_url')"
  if [[ $? != 0 ]]; then
    echo "Failed to find appmap jar for $APPMAP_JAVA_VERSION"
    return 1
  fi

  curl -o appmap.jar -fsSL "${APPMAP_JAR_DOWNLOAD_URL}" 
  if [[ $? != 0 ]]; then
    echo "Failed to download $APPMAP_JAR_DOWNLOAD_URL"
    return 1
  fi
)  

install_upload_script() (
  set -o pipefail
  
  curl -fsSL https://api.github.com/repos/land-of-apps/land-of-apps/contents/bin/upload-appmaps1 \
    | jq -r .content | base64 --decode > upload-appmaps
  if [[ $? != 0 ]]; then
    echo 'Failed to download upload-appmaps script'
    return 1
  fi
)
