using Toybox.Application as App;
using Toybox.Application.Properties;
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
        Sys.println("app : setTime " + time);
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
        Sys.println("app : setAlarms " + alarms);
        Properties.setValue("alarms", alarms);
    }

    function getMode() {
        if (! (App has :Properties)) {
            Sys.println("app : getMode no properties");
            return MODE_TYPE_STANDARD;
        }
        return Properties.getValue("mode");
    }

    function setMode(mode) {
        if (! (App has :Properties)) {
            Sys.println("app : setMode no properties");
            return;
        }
        Sys.println("app : setMode " + mode);
        Properties.setValue("mode", mode);
    }

    function getSailingMode() {
        if (! (App has :Properties)) {
            Sys.println("app : getSailingMode no properties");
            return SAILING_MODE_RACE;
        }
        return Properties.getValue("sailingMode");
    }

    function setSailingMode(sailingMode) {
        if (! (App has :Properties)) {
            Sys.println("app : setSailingMode no properties");
            return;
        }
        Sys.println("app : setSailingMode " + sailingMode);
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

    //! Total elapsed time in seconds, or null if unavailable
    function getTotalTime() {
        var info = getActivityInfo();
        if (info == null || info.elapsedTime == null) {
            return null;
        }
        return info.elapsedTime / 1000;
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
        return lapMs / 1000;
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
        Sys.println("app : initialize");
        AppBase.initialize();
    }

    function onStart(state) {
        Sys.println("app : onStart");
        countDown = new CountDown(self);

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        Sys.println("app: onStop");
        if (countDown != null) {
            countDown.shutdown();
            countDown = null;
        }
        sailingView = null;

        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function saveAndClose() {
        Sys.println("stop pressed");
        stopRecording(true);
        Sys.exit();
    }

    function discardAndClose() {
        Sys.println("stop pressed");
        stopRecording(false);
        Sys.exit();
    }

    function startTimer() {
        Sys.println("app : start timer");
        if (isCruiseMode()) {
            Sys.println("app : start timer ignored in cruise mode");
            return;
        }
        if (isRecording() == false) {
            Sys.println("app : start timer ignored while not recording");
            return;
        }
        if (countDown != null) {
            countDown.startTimer();
        }
    }

    function startStopTimer() {
        Sys.println("app : startStop timer");
        if (isCruiseMode()) {
            Sys.println("app : startStop timer ignored in cruise mode");
            return;
        }
        if (isRecording() == false) {
            Sys.println("app : startStop timer ignored while not recording");
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
        Sys.println("app : fixTimeUp");
        if (isCruiseMode() || countDown == null) {
            return;
        }
        countDown.fixTimeUp();
    }

    function fixTimeDown() {
        Sys.println("app : fixTimeDown");
        if (isCruiseMode() || countDown == null) {
            return;
        }
        countDown.fixTimeDown();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        Sys.println("app : getInitialView");
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
            Sys.println("app : ActivityRecording unavailable");
            return;
        }
        if (session != null) {
            return;
        }
        Sys.println("app : start ActivityRecording");
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
            Sys.println("app : pause ActivityRecording");
            session.stop();
            if (countDown != null) {
                countDown.cancelTimer();
            }
            WatchUi.requestUpdate();
        }
    }

    function resumeRecording() {
        if ((session != null) && (session.isRecording() == false)) {
            Sys.println("app : resume ActivityRecording");
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
