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

    // Reused buzz profiles/arrays — avoid allocating every ring()
    var hasVibrate = false;
    var hasTone = false;
    var vibeLongArr = null;
    var toneLongArr = null;
    var vibe1 = null;
    var vibe2 = null;
    var vibe3 = null;
    var vibe4 = null;
    var tone1 = null;
    var tone2 = null;
    var tone3 = null;
    var tone4 = null;

    enum {
        BUZZ_SHORT,
        BUZZ_LONG
    }

    function initialize(sailingapp) {
        app = sailingapp.weak();
        hasVibrate = (Attention has :vibrate);
        hasTone = (Attention has :ToneProfile) && (Attention has :playTone);
        if (hasVibrate) {
            var vibeOn = new Attention.VibeProfile(80, 200);
            var vibeOff = new Attention.VibeProfile(0, 50);
            vibeLongArr = [new Attention.VibeProfile(50, 3000)];
            vibe1 = [vibeOn, vibeOff];
            vibe2 = [vibeOn, vibeOff, vibeOn, vibeOff];
            vibe3 = [vibeOn, vibeOff, vibeOn, vibeOff, vibeOn, vibeOff];
            vibe4 = [vibeOn, vibeOff, vibeOn, vibeOff, vibeOn, vibeOff, vibeOn, vibeOff];
        }
        if (hasTone) {
            var toneOn = new Attention.ToneProfile(2500, 200);
            var toneOff = new Attention.ToneProfile(0, 50);
            toneLongArr = [new Attention.ToneProfile(2500, 500)];
            tone1 = [toneOn, toneOff];
            tone2 = [toneOn, toneOff, toneOn, toneOff];
            tone3 = [toneOn, toneOff, toneOn, toneOff, toneOn, toneOff];
            tone4 = [toneOn, toneOff, toneOn, toneOff, toneOn, toneOff, toneOn, toneOff];
        }
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
                    // Cap to one ring call (max 4) — avoid double-alloc in one tick
                    if (tens_seconds > 4) {
                        ring(BUZZ_SHORT, 4, true);
                    } else {
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
        ring(BUZZ_SHORT, 1, false);
        Ui.requestUpdate();
    }

    function fixTimeDown() {
        if (timerRunning == false) {
            return;
        }
        secLeft = (secLeft / 60) * 60;
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
        if (buzz_type == BUZZ_SHORT) {
            if (times > 4) {
                times = 4;
            }
            if (times < 1) {
                return;
            }
            if (hasVibrate) {
                if (times == 1) {
                    Attention.vibrate(vibe1);
                } else if (times == 2) {
                    Attention.vibrate(vibe2);
                } else if (times == 3) {
                    Attention.vibrate(vibe3);
                } else {
                    Attention.vibrate(vibe4);
                }
            }
            if (hasTone && tone == true) {
                if (times == 1) {
                    Attention.playTone({:toneProfile=>tone1});
                } else if (times == 2) {
                    Attention.playTone({:toneProfile=>tone2});
                } else if (times == 3) {
                    Attention.playTone({:toneProfile=>tone3});
                } else {
                    Attention.playTone({:toneProfile=>tone4});
                }
            }
        } else if (buzz_type == BUZZ_LONG) {
            if (hasTone && tone == true && toneLongArr != null) {
                Attention.playTone({:toneProfile=>toneLongArr});
            }
            if (hasVibrate && vibeLongArr != null) {
                Attention.vibrate(vibeLongArr);
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
