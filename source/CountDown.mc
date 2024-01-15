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

    function timerCallback() as Void {
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
            timerEnd.start(method(:finalRing), 500, true );
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
        Ui.requestUpdate();
    }

    function fixTimeDown() {
        if (timerRunning == false) {
            return;
        }
        secLeft = (secLeft / 60) * 60;
        Sys.println("fixTimeDown: " + secLeft / 60);
        Ui.requestUpdate();
    }

    function endTimer() {
        myTimer.stop();
        timerRunning = false;
        Ui.requestUpdate();
    }

    function ring() {
        if (app.get().getAlarms() == false) {
            return;
        }
        Sys.println("ring: " + secLeft);
        if (Attention has :ToneProfile) {
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
        if (app.get().getAlarms() == false) {
            return;
        }
        if (finalRingTime > 0) {
            finalRingTime -= 500;
            ring();
        } else {
            finalRingTime = 5000;
            timerComplete = false;
            timerEnd.stop();
        }
        Ui.requestUpdate();
    }
}
