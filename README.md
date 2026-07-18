# Sailing app for connectIQ Garmin fenix 3

Available on [GARMIN app store](https://apps.garmin.com/en-US/apps/db7493a2-fb16-4d34-a36b-1aa6af6b87b5)

Sailing is a watch app to display speed in knots and heading direction, as well as record the tracking.
It supports a simple Cruise mode for non-racing sailing, and an optional Race mode with a configurable countdown.

## Features
- Cruise / Race sailing mode (Race is the default)
- GPS quality progress bar before starting an activity
- manual Start / Pause / Resume for activity recording
- data screens: speed & bearing, lap stats, and totals
- configurable race start countdown sequence (by default 5 minutes)
- race GPS tracking (new lap when countdown reaches 0)
- current speed (in knots)
- current direction (heading in degrees)
- lap time and lap distance (nm + km)
- total elapsed time and total distance (nm + km)
- enable/disable alarms (still necessary to have the "In App" watch parameters set for bips and vibration during the countdown)

![Main View](https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/db7493a2-fb16-4d34-a36b-1aa6af6b87b5/screenshots/257fd487-7913-4018-b8f9-c900952358b9)

![Timer View](https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/db7493a2-fb16-4d34-a36b-1aa6af6b87b5/screenshots/88e938da-6c93-46c1-824f-9fa40839c84b)

## How to use it
- on launch, the app shows GPS fix quality as a progress bar; press **Start** when you want to begin recording (any GPS quality is allowed)
- press **Start** again to pause (opens the pause menu) or resume recording
- while recording, press **Back** to mark a lap
- use **Next page** / **Previous page** to cycle between:
  1. Speed & bearing
  2. Lap time and lap distance (nm + km)
  3. Total elapsed time and total distance (nm + km)
- open the menu and choose **Sailing mode** → **Cruise** or **Race**
- in **Race** mode, start the countdown from the menu (**Start timer**) while recording is active
- while the race countdown is running, page buttons still adjust the countdown by a minute
- a new track lap is created every time the race countdown reaches 0
