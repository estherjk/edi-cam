# edi-cam

edi-cam demonstrates live video streaming on Intel Edison using Node.js and WebSockets. Audio is not supported at the moment. See the demo in action [here](http://youtu.be/nVDL2-bFT3Y).

The Node.js server is responsible for:

* Listening for the incoming video stream via HTTP. [ffmpeg](https://www.ffmpeg.org/), a multimedia framework for converting and streaming audio / video, is used to encode the webcam's video to MPEG1.
* Broadcasting the video stream via WebSockets to all connected browsers.
* Serving `web/client/index.html`, which renders the video stream onto a canvas element. [jsmpeg](https://github.com/phoboslab/jsmpeg), a JavaScript MPEG1 decoder, is used to decode the video stream.

This project was inspired by [phoboslab](http://phoboslab.org/log/2013/09/html5-live-video-streaming-via-websockets).

## Setup

To get started with Edison if you have never set it up before, see this [post](https://communities.intel.com/docs/DOC-23148). The most relevant sections are "Connecting Edison" and "Connect Edison to WiFi". Although the instructions are for the Arduino breakout board, setup is similar for the Mini breakout board: Snap Edison onto the left side of the board, then connect **two** micro USB cables to the board and to your computer.

The setup assumes that Edison and your computer are on the same Wi-Fi network. This is also the case for additional computers that are used to view the video stream.

With Edison and your computer on the same Wi-Fi network, it is also possible to connect to Edison wirelessly via SSH. This is particularly helpful when running the demo. To do so, open a new terminal window and type the following:

    $ ssh root@myedison.local
    root@myedison.local's password:
    root@myedison:~#

Replace `myedison` with the name of your Edison. When prompted for your password, use the password you created when configuring Edison.

### Setting up hardware

Use a [UVC-compatible webcam](http://www.ideasonboard.org/uvc/). In my setup, I am using the [Creative Live! Cam Sync HD 720P](http://www.amazon.com/Creative-Live-Sync-720P-Webcam/dp/B0092QJRPC).

External power (7-15 VDC) must be supplied to use Edison as a USB host. Refer to the appropriate item below (based on the board you have) to power and connect a USB device:

* If you have the Arduino breakout board, see this [document](http://www.intel.com/support/edison/sb/CS-035275.htm). Power must be supplied on J1 (the power jack). Plug the webcam into the USB port next to the power jack. Make sure the switch SW1 is switched towards the USB port.
* If you have the Mini breakout board, see this [document](http://www.intel.com/support/edison/sb/CS-035252.htm). Power must be supplied on J21 / J22, e.g. a 9V battery can be connected to J21 with a 2-pin connector. Connect a micro USB to USB OTG adapter to the webcam and plug into the micro USB port closest to J21 (lower right).

### Installing packages

#### Configuring the package manager

Edison's operating system is based off Yocto Linux, which uses `opkg` as its package manager. [AlexT's unofficial opkg repository](http://alextgalileo.altervista.org/edison-package-repo-configuration-instructions.html) is highly recommended for adding packages to Edison. It includes many useful packages, such as git and the UVC driver.

To configure the repository, add the following lines to `/etc/opkg/base-feeds.conf`:

    src/gz all http://repo.opkg.net/edison/repo/all
    src/gz edison http://repo.opkg.net/edison/repo/edison
    src/gz core2-32 http://repo.opkg.net/edison/repo/core2-32

The configuration used in this demo is also provided for reference. If `/etc/opkg/base-feeds.conf` is empty, simply copy this file into `/etc/opkg/`.

Update `opkg`:

    opkg update

If the update is successful, the output should look like this:

    Downloading http://repo.opkg.net/edison/repo/all/Packages.gz.
    Inflating http://repo.opkg.net/edison/repo/all/Packages.gz.
    Updated list of available packages in /var/lib/opkg/all.
    Downloading http://repo.opkg.net/edison/repo/edison/Packages.gz.
    Inflating http://repo.opkg.net/edison/repo/edison/Packages.gz.
    Updated list of available packages in /var/lib/opkg/edison.
    Downloading http://repo.opkg.net/edison/repo/core2-32/Packages.gz.
    Inflating http://repo.opkg.net/edison/repo/core2-32/Packages.gz.
    Updated list of available packages in /var/lib/opkg/core2-32.

#### Cloning this repository onto Edison

To install git:

    opkg install git

Then clone this repository using `git clone <git repo URL>`.

#### Installing the UVC driver

Older versions of the Edison Yocto image do not contain the UVC driver. To **check whether or not the UVC driver is installed**, type the following:

    find /lib/modules/* -name 'uvc'

If the UVC driver is installed, the output should look something like this:

    /lib/modules/3.10.17-poky-edison+/kernel/drivers/media/usb/uvc

If **nothing** is returned, the UVC driver needs to be installed:

    opkg install kernel-module-uvcvideo

To make sure the UVC driver is loaded and the webcam is detected properly, plug in your webcam, then type `lsmod | grep uvc`:

    root@myedison:~# lsmod | grep uvc
    uvcvideo               71516  0
    videobuf2_vmalloc      13003  1 uvcvideo
    videobuf2_core         37707  1 uvcvideo

Also, verify that the video device node has been created by typing `ls -l /dev/video0`:

    root@myedison:~# ls -l /dev/video0
    crw-rw----    1 root     video      81,   0 Nov 10 15:57 /dev/video0

#### Installing ffmpeg

To install `ffmpeg`:

* Navigate to `bin`.
* Type `./install_ffmpeg.sh` to run the shell script.

If the download doesn't work, the release link may have changed. Check [here](http://johnvansickle.com/ffmpeg/), copy the address of the latest release, and replace in the shell script.

#### Installing Node.js packages

* Navigate to `web/server`.
* Install the Node.js packages by typing `npm install`.

### Running the demo

#### Updating the WebSocket address

Modify `wsUrl` in `web/client/index.html`. The section of the code looks like this:

    // CHANGE THIS TO THE APPROPRIATE WS ADDRESS
    var wsUrl = 'ws://myedison.local:8084/';

Replace `myedison` with the name of your Edison.

#### Running the Node.js server

* Navigate to `web/server`.
* Run the server by typing `node server.js`.

The Node.js server should now be running. The console will look something like this:

    WebSocket server listening on port 8084
    HTTP server listening on port 8080
    Listening for video stream on port 8082
    Stream Connected: 127.0.0.1:52995 size: 320x240

#### Viewing the video stream

Open a browser window and navigate to `http://myedison.local:8080`, where `myedison` is the name of your Edison. You should now see the video stream from your webcam!
