using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.Attention as Attention;
using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Toybox.Time as Time;

class CountDown {

    var app = null;

    // Timers
    var myTimer = null;
    var timerEnd = null;

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
        var sailingApp = app.get();
        if (sailingApp == null) {
            return;
        }
        secLeft = sailingApp.getDefaultTimerCount() * 60;

        updateTimer();

        myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 1000, true);

        timerRunning = true;
    }

    function finishCountdown() {
        var sailingApp = app.get();
        if (sailingApp != null) {
            sailingApp.addLap();
        }
        raceStartTime = Time.now();
        stopMainTimer();
        timerRunning = false;
        timerComplete = true;
        timerEnd = new Timer.Timer();
        timerEnd.start(method(:finalRing), 500, true );
    }

    function timerCallback() as Void {
        var sailingApp = app.get();
        if (sailingApp == null) {
            stopMainTimer();
            timerRunning = false;
            return;
        }
        var current_mode = sailingApp.getMode();
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
        } else {
            // Unknown countdown signal mode: keep timer progressing safely.
            if (secLeft > 1) {
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

    function stopMainTimer() {
        if (myTimer != null) {
            myTimer.stop();
            myTimer = null;
        }
    }

    function stopFinalRingTimer() {
        if (timerEnd != null) {
            timerEnd.stop();
            timerEnd = null;
        }
        finalRingTime = 5000;
        timerComplete = false;
    }

    //! Cancel an active countdown without starting a race
    function cancelTimer() {
        stopMainTimer();
        stopFinalRingTimer();
        timerRunning = false;
        Ui.requestUpdate();
    }

    //! Forget race-start elapsed time (used when entering Cruise)
    function clearRaceStart() {
        raceStartTime = null;
        Ui.requestUpdate();
    }

    //! Legacy alias used when toggling Start during a countdown
    function endTimer() {
        cancelTimer();
    }

    //! Stop all timers before the app is discarded
    function shutdown() {
        stopMainTimer();
        stopFinalRingTimer();
        timerRunning = false;
    }

    function ring(buzz_type, times, tone) {
        var sailingApp = app.get();
        if (sailingApp == null || sailingApp.getAlarms() == false) {
            return;
        }
        Sys.println("ring: " + times);
        var hasVibrate = (Attention has :vibrate);
        var hasTone = (Attention has :ToneProfile) && (Attention has :playTone);
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
                    if (hasTone) {
                        toneData[i] = new Attention.ToneProfile(2500, 200);
                    }
                } else {
                    vibeData[i] = new Attention.VibeProfile(0, 50);
                    if (hasTone) {
                    toneData[i] = new Attention.ToneProfile(0, 50);
                    }
                }
            }
            if (hasTone && tone == true) {
                Attention.playTone({:toneProfile=>toneData});
            }
            if (hasVibrate) {
                Attention.vibrate(vibeData);
            }
        } else if(buzz_type == BUZZ_LONG){
            if (hasTone && tone == true) {
                Attention.playTone({:toneProfile=>[new Attention.ToneProfile(2500, 500)]});
            }
            if (hasVibrate) {
                var vibe_data = [new Attention.VibeProfile(50, 3000)];
                Attention.vibrate(vibe_data);
            }
        }
    }

    function finalRing() as Void {
        var sailingApp = app.get();
        if (sailingApp == null || sailingApp.getAlarms() == false) {
            // Clear START and stop the timer when alarms are disabled (PR #20).
            stopFinalRingTimer();
            Ui.requestUpdate();
            return;
        }
        if (finalRingTime > 0) {
            finalRingTime -= 500;
            ring(BUZZ_LONG, 1, true);
        } else {
            stopFinalRingTimer();
        }
        Ui.requestUpdate();
    }
}
