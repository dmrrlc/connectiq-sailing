using Toybox.Application as App;
using Toybox.Application.Properties;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;
using Toybox.Attention as Attn;
using Toybox.Time.Gregorian as Cal;
using Toybox.ActivityRecording as Record;
using Toybox.Position as Position;
using Toybox.System as Sys;


class SailingApp extends App.AppBase {

    var session;
    var sailingView;

    var gpsSetupTimer;
    var countDown = null;


    // get default timer count from properties, if not set return default
    function getDefaultTimerCount() {
        if (! (App has :Properties)) {
            return 5;
        }
        var time = Properties.getValue("time");
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

    function initialize() {
        Sys.println("app : initialize");
        AppBase.initialize();
    }

    function onStart(state) {
        Sys.println("app : onStart");
        gpsSetupTimer = new Timer.Timer();
        gpsSetupTimer.start(method(:startActivityRecording), 1000, true);
        countDown = new CountDown(self);

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        Sys.println("app: onStop");
        sailingView = null;
        gpsSetupTimer.stop();
        gpsSetupTimer = null;
        countDown = null;

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
        countDown.startTimer();
    }

    function startStopTimer() {
        Sys.println("app : startStop timer");
        if (countDown.isTimerRunning() == false) {
            countDown.startTimer();
        } else {
            countDown.endTimer();
        }
    }

    function fixTimeUp() {
        Sys.println("app : fixTimeUp");
        countDown.fixTimeUp();
    }

    function fixTimeDown() {
        Sys.println("app : fixTimeDown");
        countDown.fixTimeDown();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        Sys.println("app : getInitialView");
        sailingView = new SailingView(countDown);
        return [ sailingView, new SailingDelegate() ];
    }

    function onPosition(info) {
        sailingView.onPosition(info);
        if (countDown.isTimerRunning() == false) {
            Ui.requestUpdate();
        }
    }

    function startActivityRecording() {
        if (Position.getInfo().accuracy >= Position.QUALITY_USABLE){
            gpsSetupTimer.stop();
            if( Toybox has :ActivityRecording ) {
                if( ( session == null ) || ( session.isRecording() == false ) ) {
                    Sys.println("start ActivityRecording");
                    var mySettings = Sys.getDeviceSettings();
                    var version = mySettings.monkeyVersion;

                    if(version[0] >= 3) {
                        session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_SAILING});
                     }else{
                        session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_GENERIC});
                    }
                    session.start();
                }
            }
        }
    }

    function addLap() {
        if( ( session != null ) && session.isRecording() ) {
            session.addLap();
        }
    }

     //! Stop the recording if necessary
    function stopRecording(save) {
        if( Toybox has :ActivityRecording ) {
            if( session != null && session.isRecording() ) {
                session.stop();
                if (save) {
                    session.save();
                } else {
                    session.discard();
                }
                session = null;
            }
        }
    }
}
