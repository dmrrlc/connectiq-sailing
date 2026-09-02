using Toybox.Application as App;
using Toybox.Application.Properties;
using Toybox.Application.Storage;
using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Position as Position;
using Toybox.System as Sys;

enum {
    MODE_TYPE_STANDARD,
    MODE_TYPE_DYNAMIC
}

enum {
    SAILING_MODE_RACE,
    SAILING_MODE_CRUISE
}

class SailingApp extends App.AppBase {

    var session = null;
    var sailingView;
    var countDown = null;

    // Lap markers relative to Activity.getActivityInfo() totals
    var lapStartTime = null;      // ms elapsedTime at lap start
    var lapStartDistance = null;  // meters elapsedDistance at lap start


    // get default timer count from properties, if not set return default
    function getDefaultTimerCount() {
        if (! (App has :Properties)) {
            return 5;
        }
        var time = Properties.getValue("time");
        if (time < 0) {
            return 5;
        }
        return time;
    }

    // set default timer count in properties
    function setDefaultTimerCount(time) {
        if (! (App has :Properties)) {
            return;
        }
        Properties.setValue("time", time);
    }

    function getAlarms() {
        if (! (App has :Properties)) {
            return true;
        }
        return Properties.getValue("alarms");
    }

    function setAlarms(alarms) {
        if (! (App has :Properties)) {
            return;
        }
        Properties.setValue("alarms", alarms);
    }

    function getMode() {
        if (! (App has :Properties)) {
            return MODE_TYPE_STANDARD;
        }
        return Properties.getValue("mode");
    }

    function setMode(mode) {
        if (! (App has :Properties)) {
            return;
        }
        Properties.setValue("mode", mode);
    }

    function getSailingMode() {
        if (! (App has :Properties)) {
            return SAILING_MODE_RACE;
        }
        return Properties.getValue("sailingMode");
    }

    function setSailingMode(sailingMode) {
        if (! (App has :Properties)) {
            return;
        }
        Properties.setValue("sailingMode", sailingMode);
        if (sailingMode == SAILING_MODE_CRUISE && countDown != null) {
            countDown.cancelTimer();
            countDown.clearRaceStart();
        }
        WatchUi.requestUpdate();
    }

    function isCruiseMode() {
        return getSailingMode() == SAILING_MODE_CRUISE;
    }

    function hasActivitySession() {
        return session != null;
    }

    function isRecording() {
        return (session != null) && session.isRecording();
    }

    function isPaused() {
        return (session != null) && (session.isRecording() == false);
    }

    function getActivityInfo() {
        if (!(Toybox has :Activity)) {
            return null;
        }
        return Activity.getActivityInfo();
    }

    //! Normalize elapsed milliseconds to whole seconds (avoids Float in format strings)
    function secondsFromMs(ms) {
        if (ms == null) {
            return null;
        }
        return (ms / 1000).toNumber();
    }

    //! Total elapsed time in seconds, or null if unavailable
    function getTotalTime() {
        var info = getActivityInfo();
        if (info == null || info.elapsedTime == null) {
            return null;
        }
        return secondsFromMs(info.elapsedTime);
    }

    //! Total distance in meters, or null if unavailable
    function getTotalDistance() {
        var info = getActivityInfo();
        if (info == null || info.elapsedDistance == null) {
            return null;
        }
        return info.elapsedDistance;
    }

    //! Current lap elapsed time in seconds, or null if unavailable
    function getLapTime() {
        var info = getActivityInfo();
        if (info == null || info.elapsedTime == null || lapStartTime == null) {
            return null;
        }
        var lapMs = info.elapsedTime - lapStartTime;
        if (lapMs < 0) {
            lapMs = 0;
        }
        return secondsFromMs(lapMs);
    }

    //! Current lap distance in meters, or null if unavailable
    function getLapDistance() {
        var info = getActivityInfo();
        if (info == null || info.elapsedDistance == null || lapStartDistance == null) {
            return null;
        }
        var lapMeters = info.elapsedDistance - lapStartDistance;
        if (lapMeters < 0) {
            lapMeters = 0.0;
        }
        return lapMeters;
    }

    function captureLapMarkers() {
        var info = getActivityInfo();
        if (info == null) {
            lapStartTime = 0;
            lapStartDistance = 0.0;
            return;
        }
        if (info.elapsedTime != null) {
            lapStartTime = info.elapsedTime;
        } else {
            lapStartTime = 0;
        }
        if (info.elapsedDistance != null) {
            lapStartDistance = info.elapsedDistance;
        } else {
            lapStartDistance = 0.0;
        }
    }

    function clearLapMarkers() {
        lapStartTime = null;
        lapStartDistance = null;
    }

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        countDown = new CountDown(self);

        // One-time: ensure Race is default after remediation release
        if (Storage.getValue("raceDefaultV1") == null) {
            setSailingMode(SAILING_MODE_RACE);
            Storage.setValue("raceDefaultV1", true);
        }

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        if (countDown != null) {
            countDown.shutdown();
            countDown = null;
        }
        sailingView = null;

        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function saveAndClose() {
        stopRecording(true);
        Sys.exit();
    }

    function discardAndClose() {
        stopRecording(false);
        Sys.exit();
    }

    function startTimer() {
        if (isCruiseMode()) {
            return;
        }
        if (isRecording() == false) {
            return;
        }
        if (countDown != null) {
            countDown.startTimer();
        }
    }

    function startStopTimer() {
        if (isCruiseMode()) {
            return;
        }
        if (isRecording() == false) {
            return;
        }
        if (countDown == null) {
            return;
        }
        if (countDown.isTimerRunning() == false) {
            countDown.startTimer();
        } else {
            countDown.cancelTimer();
        }
    }

    function fixTimeUp() {
        if (isCruiseMode() || countDown == null) {
            return;
        }
        countDown.fixTimeUp();
    }

    function fixTimeDown() {
        if (isCruiseMode() || countDown == null) {
            return;
        }
        countDown.fixTimeDown();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        sailingView = new SailingView(countDown);
        return [ sailingView, new SailingDelegate() ];
    }

    function onPosition(info as Position.Info) as Void{
        if (sailingView == null) {
            return;
        }
        sailingView.onPosition(info);
        if (countDown == null || countDown.isTimerRunning() == false) {
            WatchUi.requestUpdate();
        }
    }

    function startRecording() {
        if (! (Toybox has :ActivityRecording)) {
            return;
        }
        if (session != null) {
            return;
        }
        var mySettings = Sys.getDeviceSettings();
        var version = mySettings.monkeyVersion;

        if (version[0] >= 3) {
            session = ActivityRecording.createSession({:name=>"Sailing", :sport=>Activity.SPORT_SAILING});
        } else {
            session = ActivityRecording.createSession({:name=>"Sailing", :sport=>Activity.SPORT_GENERIC});
        }
        session.start();
        captureLapMarkers();
        WatchUi.requestUpdate();
    }

    function pauseRecording() {
        if ((session != null) && session.isRecording()) {
            session.stop();
            if (countDown != null) {
                countDown.cancelTimer();
            }
            WatchUi.requestUpdate();
        }
    }

    function resumeRecording() {
        if ((session != null) && (session.isRecording() == false)) {
            session.start();
            WatchUi.requestUpdate();
        }
    }

    function addLap() {
        if ((session != null) && session.isRecording()) {
            session.addLap();
            captureLapMarkers();
            WatchUi.requestUpdate();
        }
    }

     //! Stop the recording if necessary
    function stopRecording(save) {
        if (Toybox has :ActivityRecording) {
            if (session != null) {
                if (session.isRecording()) {
                    session.stop();
                }
                if (save) {
                    session.save();
                } else {
                    session.discard();
                }
                session = null;
            }
        }
        clearLapMarkers();
    }
}
