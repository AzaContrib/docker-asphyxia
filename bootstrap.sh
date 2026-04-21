#!/bin/sh

readonly ASPHYXIA_DIR="/app/asphyxia"
readonly CONFIG_FILE="${ASPHYXIA_DIR}/config.ini"
readonly DEFAULT_CONFIG_FILE="${ASPHYXIA_DIR}/config_default.ini"
readonly CUSTOM_DIR="/app/custom"
readonly CUSTOM_CONFIG="${CUSTOM_DIR}/config.ini"
readonly CUSTOM_SAVE_DIR="${CUSTOM_DIR}/savedata"
readonly PLUGINS_DIR="${ASPHYXIA_DIR}/plugins"
readonly CUSTOM_PLUGINS_DIR="${CUSTOM_DIR}/plugins"
readonly DEFAULT_PLUGINS_DIR="${ASPHYXIA_DIR}/plugins_default"

log() {
    echo "LOG: $*" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

setup_config() {
  log "Setting up configuration..."

  if [[ ! -L "${CONFIG_FILE}" && -f "${CONFIG_FILE}" ]]; then
      log "Default config.ini found; moving to config_default.ini"
      mv "${CONFIG_FILE}" "${DEFAULT_CONFIG_FILE}" || die "Failed to move default config"
  fi

  if test -f "${CUSTOM_CONFIG}"; then
  	log "Custom config.ini FOUND; Using custom config.ini"
  	ln -sf "${CUSTOM_CONFIG}" "${CONFIG_FILE}" || die "Failed to symlink custom config.ini"
  else
  	log "Custom config.ini NOT FOUND; Using default config.ini"
  	ln -sf "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}" || die "Failed to symlink default config.ini"
  fi
}


setup_plugins() {
  log "Setting up plugins..."
  rm -rf "${PLUGINS_DIR}"/* || die "Failed to clean plugins directory"
  if [ -d "${CUSTOM_PLUGINS_DIR}" ]; then
      if [ -n "${ASPHYXIA_PLUGIN_REPLACE}" ]; then
          log "ASPHYXIA_PLUGIN_REPLACE defined, not copying default plugins"
      else
          log "Adding default plugins"
          cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/ || die "Failed to add default plugins"
      fi
  	log "Custom plugins FOUND; Adding custom plugins"
  	cp -r "${CUSTOM_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/ || die "Failed to add custom plugins"
  else
      log "Custom plugins NOT FOUND; Adding default plugins"
      cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/ || die "Failed to copy default plugins"
  fi
}


main() {
  log "Starting Asphyxia bootstrap..."
  if [ ! -f "${ASPHYXIA_DIR}/asphyxia-core" ]; then
      log "Copying Asphyxia files to ${ASPHYXIA_DIR}..."
      mkdir -p "${ASPHYXIA_DIR}"
      cp -r /usr/local/share/asphyxia/* "${ASPHYXIA_DIR}/" || die "Failed to copy Asphyxia files"
  fi
  [ -d "${ASPHYXIA_DIR}" ] || die "Asphyxia directory not found: ${ASPHYXIA_DIR}"
  setup_config
  setup_plugins

  readonly ASPHYXIA_EXEC="${ASPHYXIA_DIR}/asphyxia-core"
  [ -x "${ASPHYXIA_EXEC}" ] || die "Asphyxia executable not found or not executable: ${ASPHYXIA_EXEC}"

  log "Running: ${ASPHYXIA_EXEC} --bind 0.0.0.0 $@"
  exec ${ASPHYXIA_EXEC} --bind 0.0.0.0 "$@"
}

main "$@"
