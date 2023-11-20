# Home Assistant Addon for HA_enoceanmqtt

This is the [Home Assistant](https://www.home-assistant.io/) addon for [HA_enoceanmqtt](https://github.com/mak-gitdev/HA_enoceanmqtt).  
HA_enoceanmqtt allows to easily have access to EnOcean devices in Home Assistant through MQTT.  

<img src="https://raw.githubusercontent.com/mak-gitdev/HA_enoceanmqtt-addon/master/.github/images/install_addon.svg" alt="Install Addon" width="75%"/>
<br/>

## Migration from the old addon repository
The addon repository has been moved from the [HA_enoceanmqtt](https://github.com/mak-gitdev/HA_enoceanmqtt) repository to this new one.  
This has been done as the addon and HA_enoceanmqtt may evolve at different pace and keeping separate repositories seems easier to me to handle that.    
The migration is possible without losing your current setup:  
1. Go to **Settings → Add-ons**, go to your current addon page and browse to the configuration tab.
1. Click **⋮ → Edit as YAML**, and copy your configuration then paste it in a temporary file of your choice.
1. If the addon is running, stop it first then uninstall it.
1. Once the addon is uninstalled, go to the **Add-on store**, click **⋮ → Repositories** and remove the old repository.
1. Follow the instructions in the installation chapter below to install the new addon repository.
1. Finally, in the configuration tab, click **⋮ → Edit as YAML** and paste your previously saved configuration.

**Note**: Your device configuration file is not affected by the addon uninstallation.


## Installation
1. If you don't have a MQTT broker yet, in Home Assistant go to **Settings → Add-ons → Add-on store** and install the **Mosquitto broker** addon.
1. Go back to the **Add-on store**, click **⋮ → Repositories**, fill in</br>  **`https://github.com/mak-gitdev/HA_enoceanmqtt-addon`** and click **Add → Close**.
1. Click on the addon and press **Install** and wait until the addon is installed.


## Configuration
1. Click on **Configuration**
    - If you already have a previous valid configuration, click **⋮ → Edit as YAML** and paste your previously saved configuration. Otherwise, follow the instructions below.
    - Adapt the [`addon/enoceanmqtt.devices.sample`](https://github.com/mak-gitdev/HA_enoceanmqtt-addon/blob/master/addon-dev/enoceanmqtt.devices.sample) and put it to your Home Assistant **/config** directory. You can use the Home Assistant **File Editor**.  
     **Tip**: Your device name can contain `/` e.g. `[lights/livingroom]`. This allows you to group your devices by type when exploring MQTT messages.
    - Indicate the location of this device file under the **device_file** entry.
    - Leave empty the **mapping_file** entry to use the default mapping file. If you want to use a custom mapping file, indicate the location of your mapping file. This can be useful for people wanting to add support for new devices or customize the existing ones. Refer to this [wiki page](https://github.com/mak-gitdev/HA_enoceanmqtt/wiki/Examples#using-custom-mappingyaml-andor-eepxml-files) for more details.
    - Leave empty the **eep_file** entry to use the default EEP.xml file. If you want to use a custom EEP.xml file, indicate the location of your EEP.xml file. This can be useful for people wanting to add support for new devices not yet supported by the Python EnOcean library. Refer to this [wiki page](https://github.com/mak-gitdev/HA_enoceanmqtt/wiki/Examples#using-custom-mappingyaml-andor-eepxml-files) for more details.
    - Indicate your preferred location for the log file under the **log_file** entry. It shall be in your Home Assistant **/config** directory.
    - Select the serial interface of your EnOcean transceiver in the list of detected serial ports. When using yaml configuration, the format is for example:
        ```yaml
        enocean_port: /dev/ttyUSB0
        ```
    - If you are **not** using the Mosquitto broker addon, fill in your MQTT details. Otherwise, leave empty the MQTT broker configuration. The format is for example:
        ```yaml
        host: localhost
        port: '1883'
        user: my_user
        pwd: my_password
        ```
    - Indicate the `mqtt_discovery_prefix` under the **mqtt_discovery_prefix** entry. This is the MQTT prefix used for [MQTT Discovery](home-assistant.io/integrations/mqtt/#mqtt-discovery) mechanism from the MQTT integration. It defaults to `homeassistant` and can be configured in the Home Assistant MQTT integration as follow:
        ```yaml
        mqtt:
          discovery_prefix: <prefix>
        ```
     If you have other HA integrations using MQTT discovery (e.g. zigbee2mqtt, etc.), **mqtt_discovery_prefix** should be set to `homeassistant` as it seems to be the one used in general.
    - Indicate the `mqtt_prefix` under the **mqtt_prefix** entry. This is the prefix which will be used to interact with your EnOcean devices.  
      EnOceanMQTT will interact with EnOcean devices through the device root topic `<mqtt_prefix>/<device_name>`.
    - Turn on the **debug** switch if you want a very verbose log file.
    - Other settings can be kept to their default values.
    - Click **Save**
    - **Tip:** it is possible to refer to variables in the Home Assistant `secrets.yaml` file by using e.g. `pwd: '!secret mqtt_pwd'`
1. Start the addon by going to **Info** and click **Start**
1. Wait till HA_enoceanmqtt starts and press **Log** to verify HA_enoceanmqtt started correctly.

## Usage
See [Usage](https://github.com/mak-gitdev/HA_enoceanmqtt/wiki/Usage) for more information.


## Issues
Issues should be reported on the HA\_enoceanmqtt [issue tracker](https://github.com/mak-gitdev/HA_enoceanmqtt/issues).


## Versions
The addon version follow the versions of HA_enoceanmqtt.  
The format is: \<HA_enoceanmqtt version\>-\<addon iteration\> where HA_enoceanmqtt version format is: \<major\>.\<minor\>.\<dev iteration\>  
Example:  
0.2-1   = first addon iteration for version 0.2 of HA_enoceanmqtt (stable version)  
0.2.2-1 = first addon iteration for version 0.2.2 of HA_enoceanmqtt (dev version, second iteration from stable version 0.2)  

**Note**: `x.y.0` and `-0` are omitted.


