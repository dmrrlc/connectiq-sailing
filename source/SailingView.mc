using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Timer as Timer;
using Toybox.Attention as Attention;
using Toybox.Math as Math;

class SailingView extends Ui.View {

	var timer;
	var sec;
	var min;
	var progressBar;
	var progressPct = 50;
	var timerRunning = false;
	var timerComplete = false;
	var timerEnd;
	var secTot;
	var secLeft;
	var string = "";
	var finalRingTime = 5000;

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        secTot = App.getApp().getDefaultTimerCount();
        secLeft = secTot;
        
        updateTimer();
        
        //Ui.ProgressBar.initialize("Test", progressPct);
        
        timer = new Timer.Timer();
        timer.start( method(:callback), 1000, true );
        
        timerRunning = true;
    }
    
    function callback()
    {
    	if(secLeft > 1){
    		if(secLeft < 11){
    		    ring();
    	    }
    	    if((secLeft+1) % 30 == 0){
    		    ring();
    		    if((secLeft+1) % 60 == 0){
    		    	ring();
    	    	}
    	    }
    		updateTimer();
    	}else {
    		endTimer();
		}
        
        Ui.requestUpdate();
    }
    
    function endTimer() {
    	finalRing();
    	string = "START";
		timer.stop();
		timerRunning = false;
		timerEnd = new Timer.Timer();
        timerEnd.start( method(:finalRing), 500, true );
    }
    
    function ring(){
		Attention.playTone(Attention.TONE_ALARM);
    }
    
    function finalRing(){
    	if(finalRingTime > 0){
    		finalRingTime -= 500;
			Attention.playTone(Attention.TONE_ALARM);
    	}else {
    		timerEnd.stop();
		}
    }
    
    function updateTimer() {
    	secLeft -= 1;
    	
    	sec = secLeft;
    	min = 0;
    	
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
        
        var center_x = 109;
        var center_y = 109;
        var TWO_PI = Math.PI * 2;
        
        var progress = ((60 - sec) / 60.0);
        var angle = progress * TWO_PI;
        
        angle  -= Math.PI / 2.0;
        Sys.println(sec + " : " + progress + " : " +angle);
        
        dc.drawLine(center_x, center_y,
            (center_x + center_y * Math.cos(angle)),
           (center_x + center_y * Math.sin(angle)));

       
        
        dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT );
        
        dc.fillCircle(109, 109, 88);
        
        dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
        dc.drawCircle(109, 109, 89);
       
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK );
        
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
