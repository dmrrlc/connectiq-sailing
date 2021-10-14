using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Attention as Attention;
using Toybox.WatchUi as Ui;

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
        secLeft = app.get().getDefaultTimerCount();

        updateTimer();

        timer = new Timer.Timer();
        timer.start( method(:callback), 1000, true );

        timerRunning = true;
    }

    function callback() {
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
        timer.stop();
        timerRunning = false;
        Ui.requestUpdate();
    }

    function ring() {
        Sys.println("ring: " + secLeft);
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

    function finalRing() {
        if (finalRingTime > 0) {
            finalRingTime -= 500;
            ring();
        } else {
            finalRingTime = 5000;
            timerComplete = false;
            timerEnd.stop();
            Ui.requestUpdate();
        }
    }
}
