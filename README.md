# Mac-ESP8266-Explorer
A GUI for managing an ESP8266, with NodeMCU.

## Screenshots
![Screenshot 1](http://i.imgur.com/m0xXbFx.png)
![Screenshot 2](http://i.imgur.com/VovfQNA.png)

## Current features
- A user can open a connection with any baudrate to any serial device.
- A user can refresh serial devices
- A user can close a connection to a serial device.
- The program registers when a serial device has been removed.
- A user can send commands to a device with the terminal.
- A user can create a document to enter commands into.
- A user can send commands from a document.
 
## Works in progress.
- A user can rescale the application without breaking the layout.
- A user can edit multiple documents.
- A document is scrollable.
 
## TODO list
- The program sends commands to the device without a static wait, it simply sends all the commands as soon as possible.
- A user can close a document.
- A user can save a document to a local file.
- A user can load a document from a local file.
- A user can save a document to the device.
- The program executes the document just saved to the device.
- A user can download a document from the device.
- A user can send a single line from a document to the device.
- A user is properly informed when something works, and when something doesn't (Error messaging).
- The program automatically refreshes serial devices when a new one is mounted.
- The program responds correctly when the connection to a device is closed by removal of device.
- A user can flash firmware to a device from binaries or optianlly download some firmware from the NodeMCU repo.
- A user can configure the program.
- The program automatically selects the last used device on load.
- A user can install a library to the device easily.
- A user can see usage of the device.
- Create a tutorial of this program.

## References
This app is based on working with the ESP8266, along with [NodeMCU](https://github.com/nodemcu/nodemcu-firmware).

## Contributing
If you want to contribute to this repository, feel free to create a pull request, though be aware that open source is not a democracy, and therefore I reserve the right to reject anything which goes against my vision of this program. That said please do contribute!
