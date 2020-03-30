using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;
using Toybox.Attention as Attn;
using Toybox.Time.Gregorian as Cal;
using Toybox.ActivityRecording as Ar;
using Toybox.Position as Position;
using Toybox.System as Sys;


class SailingApp extends App.AppBase {

	var session;
	var sailingView;

	// get default timer count from properties, if not set return default
    function getDefaultTimerCount() {
        var time = getProperty("time");
        if (time != null) {
            return time;
        } else {
            return 300; // 5 min default timer count
        }
    }
    
    // set default timer count in properties
    function setDefaultTimerCount(time) {
        setProperty("time", time);
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    	//do nothing
    	Sys.println("onStop called");
    	//sailingView.stopRecording(true);
    }
    
    function saveAndClose() {
    	Sys.println("stop pressed");
    	sailingView.stopRecording(true);
    	Sys.exit();
    }
    
    function discardAndClose() {
    	Sys.println("stop pressed");
    	sailingView.stopRecording(false);
    	Sys.exit();
    }
    
    function startTimer() {
    	Sys.println("app : start timer");
    	sailingView.startTimer();
    }
    
    function fixTimeUp() {
    	Sys.println("app : fixTimeUp");
    	if (sailingView.isTimerRunning() == true){
    		sailingView.fixTimeUp();
    	}
    }
    
    function fixTimeDown() {
    	Sys.println("app : fixTimeDown");
    	if (sailingView.isTimerRunning() == true){
    		sailingView.fixTimeDown();
    	}
    }
    
    function refreshUi() {
    	sailingView.refreshUi();
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	sailingView = new SailingView();
        return [ sailingView, new SailingDelegate() ];
    }
    
    function initialize() {
		AppBase.initialize();
	}
}