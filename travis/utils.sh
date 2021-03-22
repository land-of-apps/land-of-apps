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
  [[ -v DEBUG ]] && set -x
  set -o pipefail
  APPLAND_CLI_DOWNLOAD_URL="$(curl $(auth_arg) -fsSL https://api.github.com/repos/applandinc/appland-cli/releases/latest \
    | jq -e -r '.assets[] | select(.name | contains("Linux")).browser_download_url')"
  if [[ $? != 0 ]]; then
    echo 'Failed to find Linux release of appland CLI'
    return 1
  fi

  curl -fsSL "${APPLAND_CLI_DOWNLOAD_URL}" \
    | sudo tar xz --directory /usr/local/bin appland
  if [[ $? != 0 ]]; then
    echo "Failed to download appland cli from $APPLAND_CLI_DOWNLOAD_URL"
    return 1
  fi
  touch ~/.appland
)

install_appmap_java() (
  [[ -v DEBUG ]] && set -x
  set -o pipefail

  APPMAP_JAR_DOWNLOAD_URL="$(curl -fsSL https://api.github.com/repos/applandinc/appmap-java/releases/latest \
    | jq -e -r '.assets[0] | select(.name).browser_download_url')"
  if [[ $? != 0 ]]; then
    echo "Failed to find download URL for appmap jar"
    return 1
  fi

  curl -o appmap.jar -fsSL "${APPMAP_JAR_DOWNLOAD_URL}"
  if [[ $? != 0 ]]; then
    echo "Failed to download $APPMAP_JAR_DOWNLOAD_URL"
    return 1
  fi
)

install_upload_script() (
  [[ -v DEBUG ]] && set -x
  set -o pipefail

  curl $(auth_arg) -fsSL https://api.github.com/repos/land-of-apps/land-of-apps/contents/bin/upload-appmaps \
    | jq -r .content | base64 --decode > upload-appmaps
  if [[ $? != 0 ]]; then
    echo 'Failed to download upload-appmaps script'
    return 1
  fi
)
