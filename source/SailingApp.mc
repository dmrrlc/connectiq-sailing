import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.ActivityRecording;
import Toybox.Position;
import Toybox.System;


class SailingApp extends Application.AppBase {

    var session;
    var sailingView;

    var gpsSetupTimer;
    var countDown = null;


    // get default timer count from properties, if not set return default
    function getDefaultTimerCount() {
        if (! (Application has :Properties)) {
            return 5;
        }
        var time = Properties.getValue("time");
        return time;
    }

    // set default timer count in properties
    function setDefaultTimerCount(time) {
        if (! (Application has :Properties)) {
            return;
        }
        System.println("SailingApp: setTime " + time);
        Properties.setValue("time", time);
    }

    function initialize() {
        System.println("SailingApp: initialize");
        AppBase.initialize();
    }

    function onStart(state) {
        System.println("SailingApp: onStart");
        gpsSetupTimer = new Timer.Timer();
        gpsSetupTimer.start(method(:startActivityRecording), 1000, true);
        countDown = new CountDown(self);

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPositionCallback));
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        System.println("app: onStop");
        sailingView = null;
        gpsSetupTimer.stop();
        gpsSetupTimer = null;
        countDown = null;

        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPositionCallback));
    }

    function saveAndClose() {
        System.println("stop pressed");
        stopRecording(true);
        System.exit();
    }

    function discardAndClose() {
        System.println("stop pressed");
        stopRecording(false);
	 System.exit();
    }

    function startTimer() {
        System.println("SailingApp: start timer");
        countDown.startTimer();
    }

    function startStopTimer() {
        System.println("SailingApp: startStop timer");
        if (countDown.isTimerRunning() == false) {
            countDown.startTimer();
        } else {
            countDown.endTimer();
        }
    }

    function fixTimeUp() {
        System.println("SailingApp: fixTimeUp");
        countDown.fixTimeUp();
    }

    function fixTimeDown() {
        System.println("SailingApp: fixTimeDown");
        countDown.fixTimeDown();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        System.println("SailingApp: getInitialView");
        sailingView = new SailingView(countDown);
        return [ sailingView, new SailingDelegate() ];
    }

    function onPositionCallback(info as Position.Info) as Void {
	System.println("SailingApp: onPositionCallback");
        sailingView.updatePositionData(info);
        if (countDown.isTimerRunning() == false) {
            WatchUi.requestUpdate();
        }
    }

	function startActivityRecording() as Void {
		System.println("SailingApp: startActivityRecording");
		if (Position.getInfo().accuracy >= Position.QUALITY_USABLE) {
			gpsSetupTimer.stop();
			if( Toybox has :ActivityRecording ) {
				if( ( session == null ) || ( session.isRecording() == false ) ) {
					System.println("start ActivityRecording");
					var mySettings = System.getDeviceSettings();
					var version = mySettings.monkeyVersion;

					var activityOptions = {:name=>"Sailing", :sport=>Activity.SPORT_SAILING};

					switch (version[0]) {
						case 4:
							if (version[1] > 0) {
								activityOptions[:subSport] = Activity.SUB_SPORT_SAIL_RACE;
							}
						case 3:
							activityOptions[:subSport] = Activity.SUB_SPORT_GENERIC;
							break;
						default:
							activityOptions[:sport]    = Activity.SPORT_GENERIC;
							activityOptions[:subSport] = Activity.SUB_SPORT_GENERIC;
							break;
					}

					session = ActivityRecording.createSession(activityOptions);
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
