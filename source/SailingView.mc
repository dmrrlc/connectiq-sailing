using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Timer as Timer;
using Toybox.Time as Time;
using Toybox.Attention as Attention;
using Toybox.Math as Math;
using Toybox.Position as Position;
using Toybox.ActivityRecording as Record;
using Toybox.Activity as Act;
using Toybox.Sensor as Sensor;

var session = null;
var timerRunning = false;

class SailingView extends Ui.View {

	var timer;
	var uiTimer;
	var gpsSetupTimer;
	var sec;
	var min;
	var screenHeight;
	var screenWidth;
	var recStatus = "-";
	var speed = "-";
	var heading = 0.0;
	var headingStr = "-";
	var accuracy = 0;
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
        
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        
        gpsSetupTimer = new Timer.Timer();
        gpsSetupTimer.start(method(:startActivityRecording), 1000, true);
            
        uiTimer = new Timer.Timer();
        uiTimer.start(method(:refreshUi), 1000, true);
    }
    
    function startActivityRecording() {
    	Sys.println("start ActivityRecording");
    	if (Position.getInfo().accuracy > 2.0){
	    	gpsSetupTimer.stop();
	        if( Toybox has :ActivityRecording ) {
	            if( ( session == null ) || ( session.isRecording() == false ) ) {
	                session = Record.createSession({:name=>"Sailing", :sport=>Record.SPORT_GENERIC});
	                session.start();
	                recStatus = "REC";
	                Ui.requestUpdate();
	                
	            }
	            else if( ( session != null ) && session.isRecording() ) {
	                session.stop();
	                session.save();
	                session = null;
	                recStatus = "-";
	                Ui.requestUpdate();
	            }
	        }  
        }
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
    	if( ( session != null ) && session.isRecording() ) {
    		session.addLap();
    	}
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
    	//comment this line for muting during tests
		//Attention.playTone(Attention.TONE_ALARM);
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
	        dc.drawText( (screenWidth / 2), (screenHeight / 2) - 60, Gfx.FONT_NUMBER_THAI_HOT, string, Gfx.TEXT_JUSTIFY_CENTER );
        } else if (timerComplete) {	
        	dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK );
			dc.drawText( (screenWidth / 2), (screenHeight / 2) - 20, Gfx.FONT_LARGE, string, Gfx.TEXT_JUSTIFY_CENTER );
       	} else {
       		if( Toybox has :ActivityRecording ) {
            // Draw the instructions
	            if( ( session == null ) || ( session.isRecording() == false ) ) {
	                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                dc.drawText((screenWidth / 2), (screenHeight / 2) - 30, Gfx.FONT_MEDIUM, "Waiting for", Gfx.TEXT_JUSTIFY_CENTER);
	                dc.drawText((screenWidth / 2), (screenHeight / 2), Gfx.FONT_MEDIUM, "GPS signal ("+accuracy+")", Gfx.TEXT_JUSTIFY_CENTER);
	            }
	            else if( ( session != null ) && session.isRecording() ) {
	                dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	                dc.drawText((screenWidth / 2), (screenHeight / 2) - 60, Gfx.FONT_MEDIUM, recStatus+"("+accuracy+")", Gfx.TEXT_JUSTIFY_CENTER);
	                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                
	                if(raceStartTime != null){
	                	Sys.println("raceStartTime : "+ raceStartTime.value());
	                	var now = Time.now();
	                	var raceTime = now.subtract(raceStartTime);
	                	//var raceTimeStr = Time.Gregorian.info(raceTime, Time.FORMAT_LONG);
	                	dc.drawText((screenWidth / 2), (screenHeight / 2) - 30, Gfx.FONT_MEDIUM, raceTime.value(), Gfx.TEXT_JUSTIFY_CENTER);
	                }else {
	                	dc.drawText((screenWidth / 2), (screenHeight / 2) - 30, Gfx.FONT_MEDIUM, "00:00:00", Gfx.TEXT_JUSTIFY_CENTER);
	                }
	                
	                dc.drawText((screenWidth / 2), (screenHeight / 2), Gfx.FONT_MEDIUM, speed, Gfx.TEXT_JUSTIFY_CENTER);
	                dc.drawText((screenWidth / 2), (screenHeight / 2) + 30, Gfx.FONT_MEDIUM, headingStr +"("+heading+")", Gfx.TEXT_JUSTIFY_CENTER);
	            }
        	}
	        // tell the user this sample doesn't work
	        else {
	            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	            dc.drawText((screenWidth / 2), (screenHeight / 2) - 20, Gfx.FONT_MEDIUM, "This product doesn't", Gfx.TEXT_JUSTIFY_LEFT);
	            dc.drawText((screenWidth / 2), (screenHeight / 2), Gfx.FONT_MEDIUM, "have FIT Support", Gfx.TEXT_JUSTIFY_LEFT);
	        }
        }
    }
    
    function buildProgress() {
    
	    var center_x = screenWidth / 2;
	    var center_y = screenHeight / 2;
	    var border_x = screenWidth;
	    var border_y = screenHeight;
	    
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
    	heading = info.heading;
    	headingStr = headingToStr(heading);
    	accuracy = info.accuracy;
     	speed = (info.speed * 1.943844492) + " knt";
    	Sys.println("speed "+speed+" heading : "+info.heading+ " ("+heading+")  accuracy: "+accuracy);
    	Ui.requestUpdate();
    }
    
    function headingToStr(heading){
    
        var sixteenthPI = Math.PI / 16.0;
        
    	if (heading < sixteenthPI){
    		return "N+";
    	}else if (heading < (3 * sixteenthPI)){ 
    	   return "NNE";
    	}else if (heading < (5 * sixteenthPI)){ 
    	   return "NE";
    	}else if (heading < (7 * sixteenthPI)){ 
    	   return "ENE";
    	}else if (heading < (9 * sixteenthPI)){ 
    	   return "E";
    	}else if (heading < (11 * sixteenthPI)){ 
    	   return "ESE";
    	}else if (heading < (13 * sixteenthPI)){ 
    	   return "SE";
    	}else if (heading < (15 * sixteenthPI)){ 
    	   return "SSE";
    	}else if (heading < (17 * sixteenthPI)){ 
    	   return "S";
    	}else if (heading < (19 * sixteenthPI)){ 
    	   return "SSW";
    	}else if (heading < (21 * sixteenthPI)){ 
    	   return "SW";
    	}else if (heading < (23 * sixteenthPI)){ 
    	   return "WSW";
    	}else if (heading < (25 * sixteenthPI)){ 
    	   return "W";
    	}else if (heading < (27 * sixteenthPI)){ 
    	   return "WNW";
    	}else if (heading < (29 * sixteenthPI)){ 
    	   return "NW";
    	}else if (heading < (31 * sixteenthPI)){ 
    	   return "NNW";
    	}else {
    		return "N-";
    	}
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
			App.getApp().refreshUi();
		} 
    }
}
