using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;
using Toybox.Attention as Attn;
using Toybox.Time.Gregorian as Cal;

// inits
var m_timer;
var m_timerDefaultCount;
var m_timerCount;
var m_timerRunning = false;
var m_timerReachedZero = false;
var m_invertColors = false;
var m_repeat;


class SailingApp extends App.AppBase {

	// get default timer count from properties, if not set return default
    function getDefaultTimerCount() {
        var time = getProperty("time");
        if (time != null) {
            return time;
        } else {
            return 70; // 1 min default timer count
        }
    }
    
    // set default timer count in properties
    function setDefaultTimerCount(time) {
        setProperty("time", time);
    }
    
    // get repeat boolean from properties, if not set return default
    function getRepeat() {
        var repeat = getProperty("repeat");
        if (repeat != null) {
            return repeat;
        } else {
            return false; // repeat off by default
        }
    }
    
    // set repeat boolean in properties
    function setRepeat(repeat) {
        setProperty("repeat", repeat);
    }

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new SailingView() ];
    }

}