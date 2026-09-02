using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Timer;
using Toybox.Math as Math;
using Toybox.Position as Position;
using Toybox.Application as App;

class SailingView extends Ui.View {

    var countDown = null;
    var uiTimer = null;

    // Graphical
    var screenHeight;
    var screenWidth;
    var minDim;
    var centerX;
    var centerY;
    var ringThickness;
    var ringRadius;
    var sec;
    var min;

    // Strings
    var accuracyStr = "0";
    var headingStr = "-";
    var headingOnlyStr = "-";
    var speedStr = "-";
    var unitsOffset = 0;
    var countDownStr = "";

    // Data
    var speedFloat = 0.0;
    var accuracy = Position.QUALITY_NOT_AVAILABLE;
    var page = 0;

    // Constants
    const SPEED_UNIT = "kts";
    const ICON_START = 0;
    const ICON_PAUSE = 1;
    const ICON_STOP = 2;
    const PAGE_SPEED = 0;
    const PAGE_LAP = 1;
    const PAGE_TOTAL = 2;
    const PAGE_COUNT = 3;
    const METERS_PER_NM = 1852.0;
    const METERS_PER_KM = 1000.0;

    // Device settings
    var deviceSettings;

    function initialize(countdown) {
        View.initialize();
        countDown = countdown.weak();
        deviceSettings = Sys.getDeviceSettings();
    }

    function onLayout(dc) {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        if(screenHeight < screenWidth){
            minDim = screenHeight;
        }else{
            minDim = screenWidth;
        }
        centerX = screenWidth / 2;
        centerY = screenHeight / 2;
        // ~20% band matching the previous fillPolygon ring thickness
        ringThickness = (minDim / 2) * 0.2;
        if (ringThickness < 4) {
            ringThickness = 4;
        }
        ringRadius = (minDim / 2) - (ringThickness / 2);
    }

    function updateTimer() {
        var countdownObj = countDown.get();
        if (countdownObj == null) {
            countDownStr = "";
            return;
        }
        var secLeft = countdownObj.secondsLeft();

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
        startUiTimer();
    }

    function startUiTimer() {
        if (uiTimer != null) {
            return;
        }
        uiTimer = new Timer.Timer();
        uiTimer.start(method(:onUiTimer), 1000, true);
    }

    function stopUiTimer() {
        if (uiTimer != null) {
            uiTimer.stop();
            uiTimer = null;
        }
    }

    function onUiTimer() as Void {
        Ui.requestUpdate();
    }

    function nextPage() {
        page = (page + 1) % PAGE_COUNT;
        Ui.requestUpdate();
    }

    function prevPage() {
        page = (page + PAGE_COUNT - 1) % PAGE_COUNT;
        Ui.requestUpdate();
    }

    function formatNm(meters) {
        if (meters == null) {
            return "-";
        }
        return (meters / METERS_PER_NM).format("%0.2f") + " nm";
    }

    function formatKm(meters) {
        if (meters == null) {
            return "-";
        }
        return (meters / METERS_PER_KM).format("%0.2f") + " km";
    }

    function formatElapsed(seconds) {
        if (seconds == null) {
            return "-";
        }
        return secToStr(seconds);
    }

    function gpsQualityLabel() {
        if (accuracy == Position.QUALITY_GOOD) {
            return "Good";
        } else if (accuracy == Position.QUALITY_USABLE) {
            return "Usable";
        } else if (accuracy == Position.QUALITY_POOR) {
            return "Poor";
        } else if (accuracy == Position.QUALITY_LAST_KNOWN) {
            return "Last known";
        }
        return "No GPS";
    }

    //! Map discrete Position accuracy values to a 0.0-1.0 progress fraction
    function gpsQualityProgress() {
        if (accuracy == Position.QUALITY_GOOD) {
            return 1.0;
        } else if (accuracy == Position.QUALITY_USABLE) {
            return 0.75;
        } else if (accuracy == Position.QUALITY_POOR) {
            return 0.5;
        } else if (accuracy == Position.QUALITY_LAST_KNOWN) {
            return 0.25;
        }
        return 0.0;
    }

    //! Draw Garmin-style start / pause / stop glyphs with graphics primitives
    function drawStateIcon(dc, x, y, size, symbol) {
        if (symbol == ICON_START) {
            dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
            var half = size / 2;
            var left = x - (size / 4);
            dc.fillPolygon([
                [left, y - half],
                [left, y + half],
                [x + half, y]
            ]);
        } else if (symbol == ICON_PAUSE) {
            dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
            var barWidth = size / 4;
            if (barWidth < 2) {
                barWidth = 2;
            }
            var gap = size / 6;
            if (gap < 2) {
                gap = 2;
            }
            var half = size / 2;
            var leftX = x - gap - barWidth;
            var rightX = x + gap;
            dc.fillRectangle(leftX, y - half, barWidth, size);
            dc.fillRectangle(rightX, y - half, barWidth, size);
        } else if (symbol == ICON_STOP) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            var half = size / 2;
            dc.fillRectangle(x - half, y - half, size, size);
        }
    }

    function drawGpsAcquisition(dc) {
        var progress = gpsQualityProgress();
        var label = gpsQualityLabel();
        var barWidth = (screenWidth * 0.7).toNumber();
        var barHeight = (screenHeight / 18).toNumber();
        if (barHeight < 8) {
            barHeight = 8;
        }
        var barX = (screenWidth - barWidth) / 2;
        var barY = (screenHeight / 2) - (barHeight / 2);
        var fillWidth = (barWidth * progress).toNumber();
        var iconSize = minDim / 10;
        if (iconSize < 12) {
            iconSize = 12;
        }

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((screenWidth / 2), (screenHeight / 4), Gfx.FONT_MEDIUM, "GPS", Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barWidth, barHeight);
        if (fillWidth > 0) {
            if (accuracy >= Position.QUALITY_USABLE) {
                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
            } else if (accuracy == Position.QUALITY_POOR) {
                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
            }
            dc.fillRectangle(barX, barY, fillWidth, barHeight);
        }
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(barX, barY, barWidth, barHeight);

        dc.drawText((screenWidth / 2), barY + barHeight + 8, Gfx.FONT_SMALL, label, Gfx.TEXT_JUSTIFY_CENTER);

        var promptY = (3 * screenHeight / 4);
        drawStateIcon(dc, screenWidth / 2, promptY - iconSize, iconSize, ICON_START);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((screenWidth / 2), promptY, Gfx.FONT_SMALL, "Press START", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawActionIcons(dc, paused) {
        if (! paused) {
            return;
        }
        var iconSize = minDim / 12;
        if (iconSize < 10) {
            iconSize = 10;
        }
        var y = screenHeight - iconSize - 6;
        var gap = iconSize + (iconSize / 2);
        drawStateIcon(dc, (screenWidth / 2) - (gap / 2), y, iconSize, ICON_PAUSE);
        drawStateIcon(dc, (screenWidth / 2) + (gap / 2), y, iconSize, ICON_STOP);
    }

    function drawPageDots(dc) {
        var radius = 3;
        var gap = 10;
        var totalWidth = (PAGE_COUNT * radius * 2) + ((PAGE_COUNT - 1) * gap);
        var startX = (screenWidth - totalWidth) / 2 + radius;
        var y = screenHeight - (minDim / 12) - 18;
        if (minDim < 240) {
            y = screenHeight - 22;
        } else if (y < (screenHeight / 2)) {
            y = screenHeight - 28;
        }
        for (var i = 0; i < PAGE_COUNT; i++) {
            var x = startX + (i * (radius * 2 + gap));
            if (i == page) {
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, radius);
            } else {
                dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, radius);
            }
        }
    }

    function sailingModeLabel() {
        if (App.getApp().isCruiseMode()) {
            return "CRUISE";
        }
        return "RACE";
    }

    function drawSpeedPage(dc, now, countdownObj) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        var nowInfo = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
        var nowString = Lang.format("$1$:$2$:$3$",
            [nowInfo.hour.format("%02d"), nowInfo.min.format("%02d"), nowInfo.sec.format("%02d")]);
        var modeLabel = sailingModeLabel();

        if (speedFloat > 10.0){
            unitsOffset = 5;
        } else {
            unitsOffset = 0;
        }
        var yOffset = screenHeight / 20;
        if (self has :getSubscreen) {
            var subscreen = getSubscreen();

            // If we are on the instinct (but not crossover), change the display
            if(deviceSettings.screenShape == System.SCREEN_SHAPE_SEMI_OCTAGON)
            {
                dc.drawText((screenWidth / 3), 40, Gfx.FONT_MEDIUM , nowString, Gfx.TEXT_JUSTIFY_CENTER);
                dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                dc.drawText((screenWidth / 3), 40 + Gfx.getFontHeight(Gfx.FONT_MEDIUM), Gfx.FONT_TINY, modeLabel, Gfx.TEXT_JUSTIFY_CENTER);
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                dc.drawText((screenWidth / 2), (screenHeight / 2), Gfx.FONT_NUMBER_THAI_HOT, speedStr, Gfx.TEXT_JUSTIFY_CENTER);
                dc.drawText((3 * (screenWidth / 4)) + unitsOffset, (screenHeight / 2), Gfx.FONT_MEDIUM, SPEED_UNIT, Gfx.TEXT_JUSTIFY_LEFT);
                dc.drawText((subscreen.x + (subscreen.width / 2) + 4), (subscreen.y + (subscreen.height/4)), Gfx.FONT_MEDIUM, headingOnlyStr, Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText((screenWidth / 2), yOffset, Gfx.FONT_TINY , nowString, Gfx.TEXT_JUSTIFY_CENTER);
                dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                dc.drawText((screenWidth / 2), yOffset + Gfx.getFontHeight(Gfx.FONT_TINY), Gfx.FONT_TINY, modeLabel, Gfx.TEXT_JUSTIFY_CENTER);
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                dc.drawText((screenWidth / 2), yOffset + Gfx.getFontAscent(Gfx.FONT_MEDIUM) + Gfx.getFontHeight(Gfx.FONT_TINY), Gfx.FONT_NUMBER_THAI_HOT, speedStr, Gfx.TEXT_JUSTIFY_CENTER);
                dc.drawText((screenWidth / 2), yOffset + Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT) + Gfx.getFontAscent(Gfx.FONT_MEDIUM) + Gfx.getFontHeight(Gfx.FONT_TINY) + 40, Gfx.FONT_MEDIUM, headingStr, Gfx.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.drawText((screenWidth / 2), yOffset, Gfx.FONT_TINY , nowString, Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText((screenWidth / 2), yOffset + Gfx.getFontHeight(Gfx.FONT_TINY), Gfx.FONT_TINY, modeLabel, Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText((screenWidth / 2), yOffset + Gfx.getFontAscent(Gfx.FONT_MEDIUM) + Gfx.getFontHeight(Gfx.FONT_TINY), Gfx.FONT_NUMBER_THAI_HOT, speedStr, Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText((screenWidth / 2), yOffset + Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT) + Gfx.getFontAscent(Gfx.FONT_MEDIUM) + Gfx.getFontHeight(Gfx.FONT_TINY) + 40, Gfx.FONT_MEDIUM, headingStr, Gfx.TEXT_JUSTIFY_CENTER);
        }

        var raceStartTime = null;
        if (countdownObj != null) {
            raceStartTime = countdownObj.startTime();
        }

        if(raceStartTime != null){
            //print running timer
            var raceTime = now.subtract(raceStartTime);
            var raceTimeStr = secToStr(raceTime.value());
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.drawText((screenWidth / 2), yOffset + Gfx.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT) + Gfx.getFontDescent(Gfx.FONT_MEDIUM) + Gfx.getFontHeight(Gfx.FONT_TINY), Gfx.FONT_MEDIUM, raceTimeStr, Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        }
    }

    function drawStatPage(dc, title, timeStr, nmStr, kmStr) {
        var y = screenHeight / 8;
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText((screenWidth / 2), y, Gfx.FONT_TINY, title, Gfx.TEXT_JUSTIFY_CENTER);

        y += Gfx.getFontHeight(Gfx.FONT_TINY) + 4;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((screenWidth / 2), y, Gfx.FONT_NUMBER_MEDIUM, timeStr, Gfx.TEXT_JUSTIFY_CENTER);

        y += Gfx.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) + 8;
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText((screenWidth / 2), y, Gfx.FONT_TINY, "Distance", Gfx.TEXT_JUSTIFY_CENTER);

        y += Gfx.getFontHeight(Gfx.FONT_TINY) + 2;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((screenWidth / 2), y, Gfx.FONT_MEDIUM, nmStr, Gfx.TEXT_JUSTIFY_CENTER);

        y += Gfx.getFontHeight(Gfx.FONT_MEDIUM) + 2;
        dc.drawText((screenWidth / 2), y, Gfx.FONT_MEDIUM, kmStr, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawLapPage(dc) {
        var app = App.getApp();
        var meters = app.getLapDistance();
        drawStatPage(dc, "LAP", formatElapsed(app.getLapTime()), formatNm(meters), formatKm(meters));
    }

    function drawTotalPage(dc) {
        var app = App.getApp();
        var meters = app.getTotalDistance();
        drawStatPage(dc, "TOTAL", formatElapsed(app.getTotalTime()), formatNm(meters), formatKm(meters));
    }

    function drawTelemetry(dc, now, countdownObj, paused) {
        if (page == PAGE_LAP) {
            drawLapPage(dc);
            drawPageDots(dc);
        } else if (page == PAGE_TOTAL) {
            drawTotalPage(dc);
            drawPageDots(dc);
        } else {
            drawSpeedPage(dc, now, countdownObj);
        }
        drawActionIcons(dc, paused);
    }

    //! Draw a light grey track, then a green progress arc for the current minute.
    //! Uses drawArc only — no polygon allocations (safe on low-memory devices).
    function drawCountdownRing(dc) {
        var progress = sec / 60.0;
        if (progress < 0) {
            progress = 0;
        } else if (progress > 1) {
            progress = 1;
        }

        dc.setPenWidth(ringThickness);

        // Dim full-circle track (split to avoid 360° drawArc quirk)
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, 90, -90);
        dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, -90, 90);

        if (progress <= 0) {
            return;
        }

        // Progress from 12 o'clock, clockwise (matches previous pie direction)
        var arcLength = progress * 360.0;
        var degreeStart = 90;
        var degreeEnd = 90 - arcLength;

        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        if (arcLength >= 360) {
            dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, 90, -90);
            dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, -90, 90);
        } else if (arcLength > 180) {
            // Split long arcs for more reliable rendering across devices
            dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, degreeStart, degreeStart - 180);
            dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, degreeStart - 180, degreeEnd);
        } else {
            dc.drawArc(centerX, centerY, ringRadius, Gfx.ARC_CLOCKWISE, degreeStart, degreeEnd);
        }
    }

    //! Update the view
    function onUpdate(dc) {
        var now = Time.now();
        var countdownObj = null;
        if (countDown != null) {
            countdownObj = countDown.get();
        }
        var app = App.getApp();
        var activityStarted = app.hasActivitySession();
        var paused = app.isPaused();

        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );

        if (countdownObj != null && countdownObj.isTimerRunning()) {
            updateTimer();
            drawCountdownRing(dc);
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( centerX, centerY - (Gfx.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT) / 2), Gfx.FONT_NUMBER_THAI_HOT, countDownStr, Gfx.TEXT_JUSTIFY_CENTER );

        } else if (countdownObj != null && countdownObj.isTimerComplete()) {
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK );
            dc.drawText( centerX, centerY - (Gfx.getFontHeight(Gfx.FONT_LARGE) / 2), Gfx.FONT_LARGE, "START", Gfx.TEXT_JUSTIFY_CENTER );

        } else if (activityStarted == false) {
            drawGpsAcquisition(dc);
        } else {
            drawTelemetry(dc, now, countdownObj, paused);
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        stopUiTimer();
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        startUiTimer();
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        stopUiTimer();
    }

    function onPosition(info) {
        if (info == null) {
            return;
        }

        if (info.accuracy != null) {
            accuracy = info.accuracy;
            accuracyStr = accuracy.format("%d");
        }

        if (info.heading != null) {
            var heading = info.heading;
            headingStr = headingToStr(heading);
            var headingDeg = ((180 * heading ) /  Math.PI);
            if (headingDeg < 0) {
                headingDeg += 360;
            }
            headingOnlyStr = headingDeg.format("%d") + "°";
            headingStr += " - " + headingDeg.format("%d");
        } else {
            headingStr = "-";
            headingOnlyStr = "-";
        }

        if (info.speed != null) {
            speedFloat = info.speed * 1.943844492;
            speedStr = speedFloat.format("%0.1f");
        } else {
            speedFloat = 0.0;
            speedStr = "-";
        }
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

    function secToStr(raceTime){
        var total = 0;
        if (raceTime != null) {
            total = raceTime.toNumber();
        }
        if (total < 0) {
            total = 0;
        }
        var raceSec = (total % 60).format("%02d");
        var raceMin = ((total / 60) % 60).format("%02d");
        var raceHours = ((total / 3600) % 60).format("%02d");

        return ""+raceHours+":"+raceMin+":"+raceSec;
    }
}
