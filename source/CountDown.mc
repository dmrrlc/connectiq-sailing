using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.Attention as Attention;
using Toybox.WatchUi as Ui;
using Toybox.Lang;

class CountDown {

    var app = null;

    // Timers
    var myTimer;
    var timerEnd;

    // Status
    var timerComplete = false;
    var timerRunning = false;

    // Properties
    var secLeft;
    var finalRingTime = 5000;
    var raceStartTime = null;

    enum {
        BUZZ_SHORT,
        BUZZ_LONG
    }

    function initialize(sailingapp) {
        Sys.println("countdown: initialize");
        app = sailingapp.weak();
    }

    function isTimerComplete() {
        return timerComplete;
    }

    function isTimerRunning() {
        return timerRunning;
    }

    function secondsLeft() {
        return secLeft;
    }

    function startTime() {
        return raceStartTime;
    }

    function startTimer() {
        if (timerRunning == true) {
            return;
        }
        secLeft = app.get().getDefaultTimerCount() * 60;

        updateTimer();

        myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 1000, true);

        timerRunning = true;
    }

    function finishCountdown() {
        app.get().addLap();
        raceStartTime = Time.now();
        endTimer();
        timerComplete = true;
        finalRing();
        timerEnd = new Timer.Timer();
        timerEnd.start(method(:finalRing), 500, true );
    }

    function timerCallback() as Void {
        var current_mode = app.get().getMode();
        Sys.println("Current Mode: " + current_mode);
        if (current_mode == MODE_TYPE_STANDARD){
            if (secLeft > 1) {
                if (secLeft < 11) {
                    ring(BUZZ_SHORT, 1, true);
                }
                if ((secLeft-1) % 30 == 0) {
                    ring(BUZZ_SHORT, 1, true);
                    if ((secLeft-1) % 60 == 0) {
                        ring(BUZZ_SHORT, 1, true);
                    }
                }
                updateTimer();
            } else {
                finishCountdown();
            }
        } else if (current_mode == MODE_TYPE_DYNAMIC) {
            var minutes = ((secLeft - 1) / 60).toNumber();
            var tens_seconds = ((secLeft - 1) / 10).toNumber();
            if (secLeft > 1) {
                // Buzz the same number of minutes left
                if (((secLeft -1) % 60 == 0) && (secLeft > 60)) {
                    ring(BUZZ_SHORT, minutes, true);
                }
                // Buzz once on the 30 seconds
                else if (((secLeft - 1) % 30 == 0) && (secLeft > 60)) {
                    ring(BUZZ_SHORT, 1, true);
                }
                // Buzz the number of seconds
                else if (((secLeft - 1) % 10 == 0) && (secLeft <= 60) && (secLeft > 11)) {
                    if(tens_seconds > 4){
                        // Hack because arrays max size 8
                        ring(BUZZ_SHORT, 4, true);
                        ring(BUZZ_SHORT, 1, true);
                    }
                    else{
                        ring(BUZZ_SHORT, tens_seconds, true);
                    }
                }
                // from 15 to 10 seconds, single short buzz
                else if (((secLeft - 1) > 10) && ((secLeft - 1) < 16)) {
                    ring(BUZZ_SHORT, 1, true);
                }
                // from 10 to 6 seconds, double short buzz
                else if (((secLeft - 1) > 5) && ((secLeft - 1) < 11)) {
                    ring(BUZZ_SHORT, 2, true);
                }
                // from 5 to 1 seconds, triple short buzz
                else if (((secLeft - 1) > 0) && ((secLeft - 1) < 6)) {
                    ring(BUZZ_SHORT, 3, true);
                }
                updateTimer();
            } else {
                finishCountdown();
            }
        }

        WatchUi.requestUpdate();
    }

    function updateTimer() {
        secLeft -= 1;
        Ui.requestUpdate();
    }

    function fixTimeUp() {
        if (timerRunning == false) {
            return;
        }
        secLeft = ((secLeft / 60) + 1) * 60;
        Sys.println("fixTimeUp: " + (secLeft / 60 + 1));
        ring(BUZZ_SHORT, 1, false);
        Ui.requestUpdate();
    }

    function fixTimeDown() {
        if (timerRunning == false) {
            return;
        }
        secLeft = (secLeft / 60) * 60;
        Sys.println("fixTimeDown: " + secLeft / 60);
        ring(BUZZ_SHORT, 1, false);
        Ui.requestUpdate();
    }

    function endTimer() {
        myTimer.stop();
        timerRunning = false;
        Ui.requestUpdate();
    }

    function ring(buzz_type, times, tone) {
        if (app.get().getAlarms() == false) {
            return;
        }
        Sys.println("ring: " + times);
        if (buzz_type == BUZZ_SHORT) {
            if (times > 5){
                Sys.println("ring: called with too many iterations (max 4)");
                return;
            }
            var vibeData = new [times * 2];
            var toneData = new [times * 2];
            for (var i = 0; i < (times * 2); i++) {
                if (i % 2 == 0) {
                    vibeData[i] = new Attention.VibeProfile(80, 200);
                    toneData[i] = new Attention.ToneProfile(2500, 200);
                } else {
                    vibeData[i] = new Attention.VibeProfile(0, 50);
                    toneData[i] = new Attention.ToneProfile(0, 50);
                }
            }
            if (Attention has :ToneProfile && tone == true) {
                Attention.playTone({:toneProfile=>toneData});
            }
            if (Attention has :vibrate) {
                Attention.vibrate(vibeData);
            }
        } else if(buzz_type == BUZZ_LONG){
            if (Attention has :ToneProfile && tone == true) {
                Attention.playTone({:toneProfile=>[new Attention.ToneProfile(2500, 500)]});
            }
            if (Attention has :vibrate) {
                var vibe_data = [new Attention.VibeProfile(50, 3000)];
                Attention.vibrate(vibe_data);
            }
        }
    }

    function finalRing() as Void {
        if (app.get().getAlarms() == false) {
            return;
        }
        if (finalRingTime > 0) {
            finalRingTime -= 500;
            ring(BUZZ_LONG, 1, true);
        } else {
            finalRingTime = 5000;
            timerComplete = false;
            timerEnd.stop();
        }
        Ui.requestUpdate();
    }
}
