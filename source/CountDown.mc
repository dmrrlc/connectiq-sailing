import Toybox.System;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.WatchUi;

class CountDown {

    var app = null;

    // Timers
    var timer;
    var timerEnd;

    // Status
    var timerComplete = false;
    var timerRunning = false;

    // Properties
    var secLeft;
    var finalRingTime = 5000;
    var raceStartTime = null;

    function initialize(sailingapp) {
        System.println("countdown: initialize");
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

        timer = new Timer.Timer();
        timer.start( method(:coundDownCallback), 1000, true );

        timerRunning = true;
    }

    function coundDownCallback() as Void {
        if (secLeft > 1) {
            if (secLeft < 11) {
                ring();
            }
            if ((secLeft-1) % 30 == 0) {
                ring();
                if ((secLeft-1) % 60 == 0) {
                    ring();
                }
            }
            updateTimer();
        } else {
            app.get().addLap();
            raceStartTime = Time.now();
            endTimer();
            timerComplete = true;
            finalRing();
            timerEnd = new Timer.Timer();
            timerEnd.start( method(:finalRing), 500, true );
        }
    }

    function updateTimer() {
        secLeft -= 1;
        WatchUi.requestUpdate();
    }

    function fixTimeUp() {
        if (timerRunning == false) {
            return;
        }
        secLeft = ((secLeft / 60) + 1) * 60;
        System.println("fixTimeUp: " + (secLeft / 60 + 1));
        WatchUi.requestUpdate();
    }

    function fixTimeDown() {
        if (timerRunning == false) {
            return;
        }
        secLeft = (secLeft / 60) * 60;
        System.println("fixTimeDown: " + secLeft / 60);
        WatchUi.requestUpdate();
    }

    function endTimer() {
        timer.stop();
        timerRunning = false;
        WatchUi.requestUpdate();
    }

    function ring() {
        System.println("ring: " + secLeft);
        if (Attention has :ToneProfile) {
            //comment this line for muting during tests
            Attention.playTone(Attention.TONE_ALARM);
        }
        if (Attention has :vibrate) {
            var vibeData =
            [
                new Attention.VibeProfile(50, 500) // On for two seconds
            ];
            Attention.vibrate(vibeData);
        }
    }

    function finalRing() as Void {
        if (finalRingTime > 0) {
            finalRingTime -= 500;
            ring();
        } else {
            finalRingTime = 5000;
            timerComplete = false;
            timerEnd.stop();
            WatchUi.requestUpdate();
        }
    }
}
