import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;

class SailingView extends WatchUi.View {

    var session = null;
    var countDown = null;

    // Graphical
    var screenHeight;
    var screenWidth;
    var minDim;
    var maxDim;
    var sec;
    var min;

    // Strings
    var accuracyStr = "0";
    var headingStr = "-";
    var speedStr = "-";
    var countDownStr = "";

    function initialize(countdown) {
        System.println("view : initialize");
        View.initialize();
        countDown = countdown.weak();
    }

    function onLayout(dc) {
        System.println("view : onLayout");
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        if(screenHeight < screenWidth){
            minDim = screenHeight;
            maxDim = screenWidth;
        }else{
            minDim = screenWidth;
            maxDim = screenHeight;
        }
    }

    function updateTimer() {
        var secLeft = countDown.get().secondsLeft();

        sec = secLeft % 60;
        min = secLeft / 60;

        //format
        if(min > 0) {
            countDownStr = min.format("%d") + ":" + sec.format("%02d");
        }else {
            countDownStr = sec.format("%d");
        }
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
        System.println("view : onShow");
    }

    //! Update the view
    function onUpdate(dc) {
        System.println("view : onUpdate");
        dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK );
        dc.clear();
        dc.setColor( Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT );

        if (countDown.get().isTimerRunning()) {
            updateTimer();
            var polygon = buildProgress();

            dc.fillPolygon(polygon);
            dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );

            var innerRadius = (minDim / 2) - ((minDim / 2) * 0.2);
            var outerRadius = innerRadius + 1;

            dc.fillCircle(screenWidth / 2, screenHeight / 2, innerRadius);
            dc.setColor( Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT );
            dc.drawCircle(screenWidth / 2, screenHeight / 2, outerRadius);
            dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
            dc.drawText( (screenWidth / 2), (screenHeight / 2) - (Graphics.getFontAscent(Graphics.FONT_NUMBER_THAI_HOT) / 2), Graphics.FONT_NUMBER_THAI_HOT, countDownStr, Graphics.TEXT_JUSTIFY_CENTER );

        } else if (countDown.get().isTimerComplete()) {
            dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_BLACK );
            dc.drawText( (screenWidth / 2), (screenHeight / 2) - (Graphics.getFontAscent(Graphics.FONT_LARGE) / 2), Graphics.FONT_LARGE, "START", Graphics.TEXT_JUSTIFY_CENTER );

        } else {

            if( accuracyStr.toNumber() < Position.QUALITY_USABLE ) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText((screenWidth / 2), (screenHeight / 2) - Graphics.getFontAscent(Graphics.FONT_MEDIUM) - Graphics.getFontDescent(Graphics.FONT_MEDIUM), Graphics.FONT_MEDIUM, "Waiting for", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText((screenWidth / 2), (screenHeight / 2), Graphics.FONT_MEDIUM, "GPS signal ("+accuracyStr+")", Graphics.TEXT_JUSTIFY_CENTER);

            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

                dc.drawText((screenWidth / 2), 0, Graphics.FONT_MEDIUM , "knt", Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText((screenWidth / 2), Graphics.getFontAscent(Graphics.FONT_MEDIUM), Graphics.FONT_NUMBER_THAI_HOT, speedStr, Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText((screenWidth / 2), Graphics.getFontAscent(Graphics.FONT_NUMBER_THAI_HOT) + Graphics.getFontAscent(Graphics.FONT_MEDIUM) + 40, Graphics.FONT_MEDIUM, headingStr, Graphics.TEXT_JUSTIFY_CENTER);

                var raceStartTime = countDown.get().startTime();
                var raceTimeStr;
                if(raceStartTime != null){
                    //print running timer
                    var now = Time.now();
                    var raceTime = now.subtract(raceStartTime);
                    raceTimeStr = secToStr(raceTime.value());
                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                } else {
                    raceTimeStr = "00:00:00";
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                }
                dc.drawText((screenWidth / 2), Graphics.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT) + Graphics.getFontDescent(Graphics.FONT_MEDIUM), Graphics.FONT_MEDIUM, raceTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
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

        var point = [ (center_x + maxDim * Math.cos(angle)), (center_x + maxDim * Math.sin(angle)) ];

        var polygon = [];

        if (countDown.get().isTimerComplete()) {
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
                    [0, border_y],
                    point
            ];
        }else if (cAngle < Math.PI*1.75)    {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    [border_x, 0],
                    [border_x, border_y],
                    [0, border_y],
                    [0, center_y],
                    point
            ];
        }else {
            polygon = [
                    [center_x, center_y],
                    [center_x, 0],
                    [border_x, 0],
                    [border_x, border_y],
                    [0, border_y],
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
        System.println("view : onHide");
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        System.println("view : onExitSleep");
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        System.println("view : onEnterSleep");
    }

    function updatePositionData(info) {
        var heading = info.heading;
        headingStr = headingToStr(heading);
        var headingDeg = ((180 * heading ) /  Math.PI);
        if (headingDeg < 0) {
            headingDeg += 360;
        }
        headingStr += " - " + headingDeg.format("%d");
        accuracyStr = info.accuracy.format("%d");
        speedStr = (info.speed * 1.943844492).format("%0.2f");
        System.println("speed: " +speedStr+ " (" +info.speed+ ") heading: " +headingStr+ " (" +heading+ ")  accuracy: " +accuracyStr);
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
}


    function secToStr(raceTime){
        var raceSec = (raceTime % 60).format("%02d");
        var raceMin = ((raceTime / 60) % 60).format("%02d");
        var raceHours = ((raceTime / 3600) % 60).format("%02d");

        return ""+raceHours+":"+raceMin+":"+raceSec;
    }
