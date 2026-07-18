# Sailing app for connectIQ Garmin fenix 3

Available on [GARMIN app store](https://apps.garmin.com/en-US/apps/db7493a2-fb16-4d34-a36b-1aa6af6b87b5)

Sailing is a watch app to display speed in knots and heading direction, as well as record the tracking.
It supports a simple Cruise mode for non-racing sailing, and an optional Race mode with a configurable countdown.

## Features
- Cruise / Race sailing mode (Race is the default)
- configurable race start countdown sequence (by default 5 minutes)
- pre-start GPS tracking
- race GPS tracking (new lap)
- current speed (in knots)
- current direction (heading in degrees)
- time since start (Race mode, after countdown)
- enable/disable alarms (still necessary to have the "In App" watch parameters set for bips and vibration during the countdown)

![Main View](https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/db7493a2-fb16-4d34-a36b-1aa6af6b87b5/screenshots/257fd487-7913-4018-b8f9-c900952358b9)

![Timer View](https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/db7493a2-fb16-4d34-a36b-1aa6af6b87b5/screenshots/88e938da-6c93-46c1-824f-9fa40839c84b)

## How to use it
- open the menu and choose **Sailing mode** → **Cruise** or **Race**
- in **Cruise** mode the Start button does not start a countdown; the app shows speed and bearing while GPS tracking records automatically
- in **Race** mode, press the select (start/stop) button to start or cancel the race start countdown (also available via the menu)
- the activity tracking waits for GPS signal and starts automatically until you exit the app
- a new track lap is created every time the race countdown reaches 0
- if you missed the initial signal, you can adjust to the lower/upper minute by pressing the "next page" or "previous page" button (Race mode only)
