This script will help to match the discoverd eth interfaces in Alpine Linux (maybe others aswell) to the correct physical port on the Barracuda appliance using a new name as configured in the mapper files.
The mapper files are found in the firmware of the Barracuda cloudgen firewall in the location: /opt/phion/appliances/modules/box/boxnet

To activate during boot process in Alpine, create the file **/etc/local.d/network-rename.start**, with content:

	#!/bin/sh
	<location>/barracuda_iface_mapper.sh --apply

After that make the file executable and load the local default service:

  ```
  chmod +x /etc/local.d/network-rename.start
  rc-update add local default
  ```
