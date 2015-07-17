using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Timer as Timer;
using Toybox.Attention as Attention;

class SailingView extends Ui.View {

	var timer;
	var progressBar;
	var progressPct = 0;
	var timerRunning = false;
	var timerComplete = false;
	var secTot;
	var secLeft;
	var string = "";

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        secTot = App.getApp().getDefaultTimerCount();
        secLeft = secTot;
        
        updateTimer();
        
        progressBar = new Ui.ProgressBar("Test", progressPct);
        
        timer = new Timer.Timer();
        timer.start( method(:callback), 1000, true );
        
        timerRunning = true;
    }
    
    function callback()
    {
    	if(secLeft > 1){
    	    if((secLeft+1) % 30 == 0){
    		    ring30s();
    	    }
    		updateTimer();
    	}else {
    		timerEnd();
		}
        
        Ui.requestUpdate();
    }
    
    function timerEnd() {
    	string = "START";
		timer.stop();
		timerRunning = false;
    }
    
    function ring30s(){
		Attention.playTone(Attention.TONE_ALARM);
    }
    
    function updateTimer() {
    	secLeft -= 1;
    	
    	var sec = secLeft;
    	var min = 0;
    	
    	//compute min/sec
    	while (sec > 59) {
            min += 1;
            sec -= 60;
        }
        
        //format
        if(min > 0) {
	        if (sec > 9) {
	            string = "" + min + ":" + sec;
	        } else {
	            string = "" + min + ":0" + sec + "";
	        }
	    }else {
		        string = "" + sec + "";
	    }
	    //progressBar.setProgress( ( (secTot - secLeft) / secTot) * 100 );
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        
		if(timerRunning){
	        // display time
	        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) - 60, Gfx.FONT_NUMBER_THAI_HOT, string, Gfx.TEXT_JUSTIFY_CENTER );
        }else{	
			dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) - 20, Gfx.FONT_LARGE, string, Gfx.TEXT_JUSTIFY_CENTER );
       }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
