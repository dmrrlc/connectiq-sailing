using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Timer as Timer;
using Toybox.Time as Time;
using Toybox.Attention as Attention;
using Toybox.Math as Math;
using Toybox.Position;
using Toybox.ActivityRecording as Record;
using Toybox.Activity as Act;
using Toybox.Sensor as Sensor;

var session = null;
var timerRunning = false;

class SailingView extends Ui.View {

	var timer;
	var uiTimer;
	var sec;
	var min;
	var speed = "-";
	var progressBar;
	var progressPct = 50;
	var timerComplete = false;
	var timerEnd;
	var secTot;
	var secLeft;
	var string = "";
	var finalRingTime = 5000;
	var raceStartTime = null;
	
	//! Stop the recording if necessary
    function stopRecording() {
        if( Toybox has :ActivityRecording ) {
            if( session != null && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                Ui.requestUpdate();
            }
        }
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc)); 
        
        Sys.println("start ActivityRecording");
        if( Toybox has :ActivityRecording ) {
            if( ( session == null ) || ( session.isRecording() == false ) ) {
                session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_GENERIC});
                session.start();
                Ui.requestUpdate();
                
            }
            else if( ( session != null ) && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                Ui.requestUpdate();
            }
        }      
        uiTimer = new Timer.Timer();
        uiTimer.start(method(:refreshUi), 1000, true);
    }
    
    function refreshUi(){
    	Ui.requestUpdate();
    }
    
    function startTimer() {
    	secTot = App.getApp().getDefaultTimerCount();
        secLeft = secTot;
        
    	updateTimer();
        
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
    	    if((secLeft-1) % 30 == 0){
    		    ring();
    		    if((secLeft-1) % 60 == 0){
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
    	raceStartTime = Time.now();
    	finalRing();
    	string = "START";
		timer.stop();
		timerRunning = false;
		timerComplete = true;
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
    		timerComplete = false;
    		timerEnd.stop();
		}
        Ui.requestUpdate();
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
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        
		if ( timerRunning ){
			var polygon = buildProgress();
			
	        dc.fillPolygon(polygon);    
	        dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT );
	        dc.fillCircle(109, 109, 88);
	        dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
	        dc.drawCircle(109, 109, 89);
	        
	        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK );
	        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) - 60, Gfx.FONT_NUMBER_THAI_HOT, string, Gfx.TEXT_JUSTIFY_CENTER );
        } else if (timerComplete) {	
        	dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK );
			dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) - 20, Gfx.FONT_LARGE, string, Gfx.TEXT_JUSTIFY_CENTER );
       	} else {
       		if( Toybox has :ActivityRecording ) {
            // Draw the instructions
	            if( ( session == null ) || ( session.isRecording() == false ) ) {
	                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2) - 30, Gfx.FONT_MEDIUM, "Press Menu to", Gfx.TEXT_JUSTIFY_CENTER);
	                dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2), Gfx.FONT_MEDIUM, "Start Recording", Gfx.TEXT_JUSTIFY_CENTER);
	            }
	            else if( ( session != null ) && session.isRecording() ) {
	                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2) - 60, Gfx.FONT_MEDIUM, "REC", Gfx.TEXT_JUSTIFY_CENTER);
	                
	                dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2) - 10, Gfx.FONT_MEDIUM, speed, Gfx.TEXT_JUSTIFY_CENTER);
	                if(raceStartTime != null){
	                	Sys.println("raceStartTime : "+ raceStartTime.value());
	                	var now = Time.now();
	                	var raceTime = now.subtract(raceStartTime);
	                	dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2) + 10, Gfx.FONT_MEDIUM, ""+raceTime.value(), Gfx.TEXT_JUSTIFY_CENTER);
	                }
	            }
        	}
	        // tell the user this sample doesn't work
	        else {
	            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	            dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2) - 20, Gfx.FONT_MEDIUM, "This product doesn't", Gfx.TEXT_JUSTIFY_LEFT);
	            dc.drawText((dc.getWidth() / 2), (dc.getHeight() / 2), Gfx.FONT_MEDIUM, "have FIT Support", Gfx.TEXT_JUSTIFY_LEFT);
	        }
        }
    }
    
    function buildProgress() {
    
	    var center_x = 109;
	    var center_y = 109;
	    var border_x = 2 * 109;
	    var border_y = 2 * 109;
	    
	    var TWO_PI = Math.PI * 2;
	    
	    var progress = ( sec / 60.0);
	    var angle = progress * TWO_PI;
	    
	    var cAngle = angle;
	    
	    angle  -= Math.PI / 2.0;
	
		var point = [ (center_x + 200 * Math.cos(angle)), (center_x + 200 * Math.sin(angle)) ];
		
	    var polygon = [];
		
		if (timerComplete){
			polygon = [
		        	[0, 0],
		        	[border_x, 0],
		        	[border_x, border_y],
		        	[0, border_y]
	        ];
        } else if (cAngle  < (Math.PI / 4.0))	{
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	point
	        ];
        } else if (cAngle < (Math.PI / 2))	{
			polygon = [
		        	[center_x, 109],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	point
	        ];
        } else if (cAngle < (Math.PI * 0.75))	{
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	[border_x, center_y],
		        	point
	        ];
        }else if (cAngle < Math.PI )	{
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	[border_x, border_y], 
		        	point
	        ];
        } else if (cAngle < Math.PI*1.25)	{
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	[border_x, border_y],
		        	[center_x, border_y],
		        	point
	        ];
        }else if (cAngle < Math.PI*1.5)	{
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	[border_x, border_y],
		        	[center_x, border_y],
		        	[0, border_y],
		        	point
	        ];
        }else if (cAngle < Math.PI*1.75)	{
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	[border_x, center_y],
		        	[border_x, border_y],
		        	[center_x, border_y],
		        	[0, border_y],
		        	[0, center_y],
		        	point
	        ];
        }else {
			polygon = [
		        	[center_x, center_y],
		        	[center_x, 0], 
		        	[border_x, 0], 
		        	[border_x, center_y],
		        	[border_x, border_y],
		        	[center_x, border_y],
		        	[0, border_y],
		        	[0, center_y],
		        	[0, 0],
		        	point
	        ];
        }
        return polygon;
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    function onPosition(info) {
     	speed = (info.speed * 1.943844492) + " knt";
    	Sys.println("speed "+speed);
    	Ui.requestUpdate();
    }
    
    function openTheMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new MyMenuDelegate(), Ui.SLIDE_UP);
    }
}


class BaseInputDelegate extends Ui.BehaviorDelegate
{
    function onKey(evt){
    	Sys.println("key evt : " +evt);
    }

    function onMenu() {
    	Sys.println("menu pressed");
    	Ui.pushView(new Rez.Menus.MainMenu(), new MyMenuDelegate(), Ui.SLIDE_UP);
    }
}

class MyMenuDelegate extends Ui.MenuInputDelegate {
   function onMenuItem(item) {
       if (item == :start_timer) {
			App.getApp().startTimer();
		} else if (item == :item_rt) {
           // Do nothing -> return
		} 
    }
}
