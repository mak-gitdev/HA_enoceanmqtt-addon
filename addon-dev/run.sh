#!/usr/bin/with-contenv bashio

bashio::config.require 'device_file'
bashio::config.require 'mqtt_discovery_prefix'
bashio::config.require 'mqtt_prefix'
bashio::config.require 'mqtt_client_id'
bashio::config.require 'mqtt_keepalive'

bashio::log.green "Preparing to start..."

# Set files to be used
export CONFIG_FILE="/data/enoceanmqtt.conf"
export DB_FILE="/data/enoceanmqtt_db.json"
export DEVICE_FILE="$(bashio::config 'device_file')"
export LOG_FILE="$(bashio::config 'log_file')"
export MAPPING_FILE="$(bashio::config 'mapping_file')"
bashio::log.blue "Retrieved devices file: $DEVICE_FILE"

# Retrieve MQTT connection parameters
MQTT_HOST=
MQTT_PORT=
MQTT_USER=
MQTT_PSWD=
if bashio::config.is_empty 'mqtt_broker'; then
  if bashio::var.has_value "$(bashio::services 'mqtt')"; then
    export MQTT_HOST="$(bashio::services 'mqtt' 'host')"
    export MQTT_PORT="$(bashio::services 'mqtt' 'port')"
    export MQTT_USER="$(bashio::services 'mqtt' 'username')"
    export MQTT_PSWD="$(bashio::services 'mqtt' 'password')"
  fi
else
  if ! bashio::config.is_empty 'mqtt_broker.host'; then
    export MQTT_HOST="$(bashio::config 'mqtt_broker.host')"
  fi
  if ! bashio::config.is_empty 'mqtt_broker.port'; then
    export MQTT_PORT="$(bashio::config 'mqtt_broker.port')"
  fi
  if ! bashio::config.is_empty 'mqtt_broker.user'; then
    export MQTT_USER="$(bashio::config 'mqtt_broker.user')"
  fi
  if ! bashio::config.is_empty 'mqtt_broker.pwd'; then
    export MQTT_PSWD="$(bashio::config 'mqtt_broker.pwd')"
  fi
fi

# Check MQTT parameters
if [ -z "${MQTT_HOST}" ] || \
   [ -z "${MQTT_PORT}" ] || \
   [ -z "${MQTT_USER}" ] || \
   [ -z "${MQTT_PSWD}" ]; then
  bashio::log.blue "mqtt_host = $MQTT_HOST"
  bashio::log.blue "mqtt_port = $MQTT_PORT"
  bashio::log.blue "mqtt_user = $MQTT_USER"
  bashio::log.blue "mqtt_pwd  = $MQTT_PSWD"
  bashio::exit.nok "MQTT broker connection not fully configured"
fi

# Debug parameter
if bashio::var.true "$(bashio::config 'debug')"; then
  export DEBUG_FLAG="--debug"
else
  export DEBUG_FLAG=""
fi

# Device name in entity name
HA_VERSION="$(bashio::core.version)"
Year=$(echo ${HA_VERSION//[!0-9.]/} | cut -d '.' -f 1)
Month=$(echo ${HA_VERSION//[!0-9.]/} | cut -d '.' -f 2)

if [ ${Year} -ge 2023 ]; then
  if [ ${Year} -eq 2023 ]; then
    if [ ${Month} -lt 8 ]; then
      bashio::log.green "Overwrite use_dev_name_in_entity to TRUE"
      USE_DEV_NAME_IN_ENTITY="True"
    else
      USE_DEV_NAME_IN_ENTITY="$(bashio::config 'use_dev_name_in_entity')"
      bashio::log.green "use_dev_name_in_entity is USER-DEFINED (${USE_DEV_NAME_IN_ENTITY})"
    fi
  else
    if [ ${Year} -eq 2024 ] && [ ${Month} -lt 2 ]; then
      USE_DEV_NAME_IN_ENTITY="$(bashio::config 'use_dev_name_in_entity')"
      bashio::log.green "use_dev_name_in_entity is USER-DEFINED (${USE_DEV_NAME_IN_ENTITY})"
    else
      bashio::log.green "Overwrite use_dev_name_in_entity to FALSE"
      USE_DEV_NAME_IN_ENTITY="False"
    fi
  fi
else
  bashio::log.green "Overwrite use_dev_name_in_entity to TRUE"
  USE_DEV_NAME_IN_ENTITY="True"
fi

# Create enoceanmqtt configuration file
MQTT_PREFIX=$(bashio::config 'mqtt_prefix')
MQTT_DISCOVERY_PREFIX=$(bashio::config 'mqtt_discovery_prefix')
MQTT_PREFIX="${MQTT_PREFIX%/}/"
MQTT_DISCOVERY_PREFIX="${MQTT_DISCOVERY_PREFIX%/}/"

echo "[CONFIG]"                                                           > $CONFIG_FILE
echo "enocean_port          = $(bashio::config 'enocean_port')"          >> $CONFIG_FILE
echo "log_packets           = $(bashio::config 'log_packets')"           >> $CONFIG_FILE
echo "overlay               = HA"                                        >> $CONFIG_FILE
echo "db_file               = $DB_FILE"                                  >> $CONFIG_FILE
echo "mapping_file          = $MAPPING_FILE"                             >> $CONFIG_FILE
echo "ha_dev_name_in_entity = $USE_DEV_NAME_IN_ENTITY"                   >> $CONFIG_FILE
echo "mqtt_discovery_prefix = $MQTT_DISCOVERY_PREFIX"                    >> $CONFIG_FILE
echo "mqtt_host             = $MQTT_HOST"                                >> $CONFIG_FILE
echo "mqtt_port             = $MQTT_PORT"                                >> $CONFIG_FILE
echo "mqtt_client_id        = $(bashio::config 'mqtt_client_id')"        >> $CONFIG_FILE
echo "mqtt_keepalive        = $(bashio::config 'mqtt_keepalive')"        >> $CONFIG_FILE
echo "mqtt_prefix           = $MQTT_PREFIX"                              >> $CONFIG_FILE
echo "mqtt_user             = $MQTT_USER"                                >> $CONFIG_FILE
echo "mqtt_pwd              = $MQTT_PSWD"                                >> $CONFIG_FILE
echo "mqtt_debug            = $(bashio::config 'debug')"                 >> $CONFIG_FILE
echo ""                                                                  >> $CONFIG_FILE
cat $DEVICE_FILE                                                         >> $CONFIG_FILE

# Delete previous session log
rm -f $LOG_FILE

if ! bashio::config.is_empty 'eep_file'; then
   EEP_FILE="$(bashio::config 'eep_file')"
   EEP_FILE_LOCATION=$(find / -name "EEP.xml" -print -quit 2>/dev/null)

   if [ -e $EEP_FILE ]; then
      bashio::log.green "Installing custom EEP.xml ..."
      cp -f $EEP_FILE $EEP_FILE_LOCATION
   else
      bashio::exit.nok "Custom EEP file not found at location $EEP_FILE"
   fi
fi

bashio::log.green "Starting EnOceanMQTT..."
. /app/venv/bin/activate
enoceanmqtt $DEBUG_FLAG --logfile $LOG_FILE $CONFIG_FILE
