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

class SailingView extends Ui.View {

    var session = null;
    var timerRunning = false;

    var timer;
    var uiTimer;
    var gpsSetupTimer;
    var displayStart = false;
    var sec;
    var min;
    var screenHeight;
    var screenWidth;
    var recStatus = "-";
    var speed = 0.0;
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

    function initialize() {
        View.initialize();
    }

    //! Stop the recording if necessary
    function stopRecording(save) {
        //Ui.pushView( new Rez.Menus.MainMenu(), new ExitMenuDelegate(), Ui.SLIDE_UP );
        if( Toybox has :ActivityRecording ) {
            if( session != null && session.isRecording() ) {
                session.stop();
                if (save){
                session.save();
                }else {
                session.discard();
                }
                session = null;
                Ui.requestUpdate();
            }
        }
    }

    function fixTimeUp() {
        secLeft = ((secLeft / 60) + 1) * 60;
        Sys.println("fixTimeUp" + secLeft / 60 + 1);
    }

    function isTimerRunning() {
        return (secLeft != null and secLeft < 300);
    }

    function fixTimeDown() {
        secLeft = (secLeft / 60) * 60;
        Sys.println("fixTimeUpDown" + secLeft / 60);
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
        if (Position.getInfo().accuracy > 2.0){
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
                    recStatus = "REC";
                }
                Ui.requestUpdate();
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
            refreshUi();
        }
        raceStartTime = Time.now();
        finalRing();
        string = "START";
        displayStart = true;
        timer.stop();
        timerRunning = false;
        timerComplete = true;
        timerEnd = new Timer.Timer();
        timerEnd.start( method(:finalRing), 500, true );
    }

    function ring(){
        //comment this line for muting during tests
        Attention.playTone(Attention.TONE_ALARM);
        var vibeData;
        if (Attention has :vibrate) {
            vibeData =
            [
                new Attention.VibeProfile(50, 500) // On for two seconds
            ];
            Attention.vibrate(vibeData);
        }
    }

    function finalRing(){
        if(finalRingTime > 0){
            finalRingTime -= 500;

            var vibeData;
            Attention.playTone(Attention.TONE_ALARM);
            if (Attention has :vibrate) {
            vibeData =
            [
                new Attention.VibeProfile(50, 500) // On for two seconds
            ];
            Attention.vibrate(vibeData);
        }
        }else {
            timerComplete = false;
            timerEnd.stop();
        }
        displayStart = false;
        Ui.requestUpdate();
    }

    function updateTimer() {
        secLeft -= 1;

        sec = secLeft % 60;
        min = secLeft / 60;

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

            var minDim = 0;

            if(screenHeight < screenWidth){
                minDim = screenHeight;
            }else{
                minDim = screenWidth;
            }

            var innerRadius = (minDim / 2) - ((minDim / 2) * 0.2);
            var outerRadius = innerRadius + 1;

            dc.fillCircle(screenWidth / 2, screenHeight / 2, innerRadius);
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
            dc.drawCircle(screenWidth / 2, screenHeight / 2, outerRadius);
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (screenWidth / 2), (screenHeight / 2) - (Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT) / 2), Gfx.FONT_NUMBER_THAI_HOT, string, Gfx.TEXT_JUSTIFY_CENTER );
        } else if (timerComplete) {
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK );
            dc.drawText( (screenWidth / 2), (screenHeight / 2) - (Gfx.getFontAscent(Gfx.FONT_LARGE) / 2), Gfx.FONT_LARGE, string, Gfx.TEXT_JUSTIFY_CENTER );
           } else {
               if( Toybox has :ActivityRecording ) {
            // Draw the instructions
                if( ( session == null ) || ( session.isRecording() == false ) ) {
                    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                    dc.drawText((screenWidth / 2), (screenHeight / 2) - Gfx.getFontAscent(Gfx.FONT_MEDIUM) - Gfx.getFontDescent(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, "Waiting for", Gfx.TEXT_JUSTIFY_CENTER);
                    dc.drawText((screenWidth / 2), (screenHeight / 2), Gfx.FONT_MEDIUM, "GPS signal ("+accuracy+")", Gfx.TEXT_JUSTIFY_CENTER);
                }
                else if( ( session != null ) && session.isRecording() ) {

                    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

                    dc.drawText((screenWidth / 2), 0, Gfx.FONT_MEDIUM , "knt", Gfx.TEXT_JUSTIFY_CENTER);
                    dc.drawText((screenWidth / 2), Gfx.getFontAscent(Gfx.FONT_MEDIUM), Gfx.FONT_NUMBER_THAI_HOT, speed.format("%0.2f"), Gfx.TEXT_JUSTIFY_CENTER);
                    dc.drawText((screenWidth / 2), Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT) + Gfx.getFontAscent(Gfx.FONT_MEDIUM) + 40, Gfx.FONT_MEDIUM, headingStr, Gfx.TEXT_JUSTIFY_CENTER);

                    var raceTimeStr;

                    if(raceStartTime != null){ //print running timer
                        var now = Time.now();
                        var raceTime = now.subtract(raceStartTime);
                        raceTimeStr = secToStr(raceTime.value());
                        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
                    }else{
                        raceTimeStr = "00:00:00";
                        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                    }
                           dc.drawText((screenWidth / 2), Gfx.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT) + Gfx.getFontDescent(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, raceTimeStr, Gfx.TEXT_JUSTIFY_CENTER);
                        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
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
        } else if (cAngle  < (Math.PI / 4.0))    {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    point
            ];
        } else if (cAngle < (Math.PI / 2))    {
            polygon = [
                    [center_x, 109],
                    [center_x, 0],
                    [border_x, 0],
                    point
            ];
        } else if (cAngle < (Math.PI * 0.75))    {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    [border_x, 0],
                    [border_x, center_y],
                    point
            ];
        }else if (cAngle < Math.PI )    {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    [border_x, 0],
                    [border_x, border_y],
                    point
            ];
        } else if (cAngle < Math.PI*1.25)    {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    [border_x, 0],
                    [border_x, border_y],
                    [center_x, border_y],
                    point
            ];
        }else if (cAngle < Math.PI*1.5)    {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    [border_x, 0],
                    [border_x, border_y],
                    [center_x, border_y],
                    [0, border_y],
                    point
            ];
        }else if (cAngle < Math.PI*1.75)    {
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
        var headingDeg = ((180 * heading ) /  Math.PI);
        if (headingDeg < 0) {
            headingDeg += 360;
        }
        headingStr += " - " + headingDeg.format("%d");
        accuracy = info.accuracy;
         speed = (info.speed * 1.943844492);
        Sys.println("speed: " +speed+ " (" +info.speed+ ") heading: " +headingStr+ " (" +heading+ ")  accuracy: " +accuracy);
        Ui.requestUpdate();
    }

    function headingToStr(heading){
        var sixteenthPI = Math.PI / 16.0;
        if (heading >= 0 and heading < sixteenthPI){
            return "N";
        }else if (heading > 0 and heading < (3 * sixteenthPI)){
           return "NNE";
        }else if (heading > 0 and heading < (5 * sixteenthPI)){
           return "NE";
        }else if (heading > 0 and heading < (7 * sixteenthPI)){
           return "ENE";
        }else if (heading > 0 and heading < (9 * sixteenthPI)){
           return "E";
        }else if (heading > 0 and heading < (11 * sixteenthPI)){
           return "ESE";
        }else if (heading > 0 and heading < (13 * sixteenthPI)){
           return "SE";
        }else if (heading > 0 and heading < (15 * sixteenthPI)){
           return "SSE";
        }else if (heading > 0){
           return "S";
        }else if (heading < 0 and heading < (-15 * sixteenthPI)){
           return "S";
        }else if (heading < 0 and heading < (-13 * sixteenthPI)){
           return "SSW";
        }else if (heading < 0 and heading < (-11 * sixteenthPI)){
           return "SW";
        }else if (heading < 0 and heading < (-9 * sixteenthPI)){
           return "WSW";
        }else if (heading < 0 and heading < (-7 * sixteenthPI)){
           return "W";
        }else if (heading < 0 and heading < (-5 * sixteenthPI)){
           return "WNW";
        }else if (heading < 0 and heading < (-3 * sixteenthPI)){
           return "NW";
        }else if (heading < 0 and heading < -sixteenthPI){
           return "NNW";
        }else {
            return "N";
        }
    }

    /*function openTheMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), Ui.SLIDE_UP);
    }*/
}


    function secToStr(raceTime){
        var raceSec = (raceTime % 60).format("%02d");
        var raceMin = ((raceTime / 60) % 60).format("%02d");
        var raceHours = ((raceTime / 3600) % 60).format("%02d");

        return ""+raceHours+":"+raceMin+":"+raceSec;
    }
