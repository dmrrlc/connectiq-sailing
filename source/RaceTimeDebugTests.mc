using Toybox.Lang;
using Toybox.Time;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Activity;
using Toybox.ActivityRecording;

(:test)
class RaceTimeDebug {
    function typeName(value) {
        if (value == null) {
            return "null";
        }
        if ((Lang has :Double) && (value instanceof Lang.Double)) {
            return "Double";
        }
        if ((Lang has :Long) && (value instanceof Lang.Long)) {
            return "Long";
        }
        if (value instanceof Lang.Float) {
            return "Float";
        }
        if (value instanceof Lang.Number) {
            return "Number";
        }
        return "other";
    }

    function secToStr(raceTime) {
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
        return "" + raceHours + ":" + raceMin + ":" + raceSec;
    }
}

(:test)
function testHypothesisA_durationValueFormat(logger) {
    var helper = new RaceTimeDebug();
    var now = Time.now();
    var start = now.subtract(new Time.Duration(125));
    var value = now.subtract(start).value();
    var typeName = helper.typeName(value);
    logger.debug("H-A duration.value type=" + typeName + " hasFormat=" + (value has :format) + " value=" + value);
    Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.duration\",\"message\":\"duration.value\",\"data\":{\"type\":\"" + typeName + "\",\"hasFormat\":" + (value has :format) + "}}");
    try {
        var formatted = helper.secToStr(value);
        logger.debug("H-A secToStr ok " + formatted);
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.duration\",\"message\":\"secToStr ok\",\"data\":{\"result\":\"" + formatted + "\"}}");
        return true;
    } catch (ex) {
        logger.error("H-A CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.duration\",\"message\":\"secToStr crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisB_elapsedMsDivision(logger) {
    var helper = new RaceTimeDebug();
    var elapsedMs = 125000;
    var seconds = elapsedMs / 1000;
    var typeName = helper.typeName(seconds);
    logger.debug("H-B elapsed/1000 type=" + typeName + " hasFormat=" + (seconds has :format) + " value=" + seconds);
    Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.elapsed\",\"message\":\"ms/1000\",\"data\":{\"type\":\"" + typeName + "\",\"hasFormat\":" + (seconds has :format) + ",\"value\":" + seconds + "}}");
    try {
        var formatted = helper.secToStr(seconds);
        logger.debug("H-B secToStr ok " + formatted);
        return true;
    } catch (ex) {
        logger.error("H-B CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.elapsed\",\"message\":\"secToStr crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisB_intDivisionTypes(logger) {
    var helper = new RaceTimeDebug();
    var half = 1 / 2;
    var secFromMs = 1500 / 1000;
    var minPart = 125 / 60;
    logger.debug("H-B3 1/2 type=" + helper.typeName(half) + " value=" + half);
    logger.debug("H-B3 1500/1000 type=" + helper.typeName(secFromMs) + " value=" + secFromMs);
    logger.debug("H-B3 125/60 type=" + helper.typeName(minPart) + " value=" + minPart);
    Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.div\",\"message\":\"division types\",\"data\":{\"halfType\":\"" + helper.typeName(half) + "\",\"msType\":\"" + helper.typeName(secFromMs) + "\",\"minType\":\"" + helper.typeName(minPart) + "\"}}");
    try {
        var formatted = helper.secToStr(125);
        logger.debug("H-B3 secToStr(125) ok " + formatted);
        return true;
    } catch (ex) {
        logger.error("H-B3 CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.div\",\"message\":\"secToStr crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisB_floatModulo(logger) {
    var helper = new RaceTimeDebug();
    var seconds = 125.0;
    logger.debug("H-B2 float type=" + helper.typeName(seconds));
    try {
        var formatted = helper.secToStr(seconds);
        logger.debug("H-B2 secToStr ok " + formatted);
        return true;
    } catch (ex) {
        logger.error("H-B2 CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.float\",\"message\":\"secToStr crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisA_longFormat(logger) {
    var helper = new RaceTimeDebug();
    if (!(Lang has :Long)) {
        logger.debug("H-A2 skip no Long");
        return true;
    }
    var value = 125l;
    var quot = value / 60;
    logger.debug("H-A2 long type=" + helper.typeName(value) + " quotType=" + helper.typeName(quot) + " hasFormat=" + (value has :format));
    Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.long\",\"message\":\"long seconds\",\"data\":{\"type\":\"" + helper.typeName(value) + "\",\"quotType\":\"" + helper.typeName(quot) + "\",\"hasFormat\":" + (value has :format) + "}}");
    try {
        var formatted = helper.secToStr(value);
        logger.debug("H-A2 secToStr ok " + formatted);
        return true;
    } catch (ex) {
        logger.error("H-A2 CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.long\",\"message\":\"secToStr crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisC_thaiHotFont(logger) {
    try {
        var height = Gfx.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT);
        var ascent = Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT);
        var descent = Gfx.getFontDescent(Gfx.FONT_MEDIUM);
        logger.debug("H-C thaiHot height=" + height + " ascent=" + ascent + " medDescent=" + descent);
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"C\",\"location\":\"RaceTimeDebugTests.font\",\"message\":\"thaiHot metrics\",\"data\":{\"height\":" + height + ",\"ascent\":" + ascent + "}}");
        return height > 0;
    } catch (ex) {
        logger.error("H-C CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"C\",\"location\":\"RaceTimeDebugTests.font\",\"message\":\"font crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisA_nowSubtractNow(logger) {
    var helper = new RaceTimeDebug();
    var start = null;
    start = Time.now();
    var raceTime = Time.now().subtract(start);
    var value = raceTime.value();
    logger.debug("H-A3 now-now type=" + helper.typeName(value) + " hasFormat=" + (value has :format) + " value=" + value);
    Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.nowsub\",\"message\":\"now.subtract(now).value\",\"data\":{\"type\":\"" + helper.typeName(value) + "\",\"hasFormat\":" + (value has :format) + "}}");
    try {
        var formatted = helper.secToStr(value);
        logger.debug("H-A3 secToStr ok " + formatted);
        return true;
    } catch (ex) {
        logger.error("H-A3 CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"A\",\"location\":\"RaceTimeDebugTests.nowsub\",\"message\":\"crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}

(:test)
function testHypothesisB_liveElapsedTime(logger) {
    var helper = new RaceTimeDebug();
    if (!(Toybox has :ActivityRecording)) {
        logger.debug("H-B4 skip no ActivityRecording");
        return true;
    }
    var session = ActivityRecording.createSession({:name=>"SailTest", :sport=>Activity.SPORT_GENERIC});
    session.start();
    try {
        var info = Activity.getActivityInfo();
        if (info == null || info.elapsedTime == null) {
            logger.debug("H-B4 no elapsedTime yet");
            Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.live\",\"message\":\"no elapsedTime\",\"data\":{}}");
            session.stop();
            session.discard();
            return true;
        }
        var elapsedType = helper.typeName(info.elapsedTime);
        var seconds = info.elapsedTime / 1000;
        var secondsType = helper.typeName(seconds);
        logger.debug("H-B4 elapsedType=" + elapsedType + " secondsType=" + secondsType + " elapsed=" + info.elapsedTime);
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.live\",\"message\":\"live elapsed\",\"data\":{\"elapsedType\":\"" + elapsedType + "\",\"secondsType\":\"" + secondsType + "\"}}");
        var formatted = helper.secToStr(seconds);
        logger.debug("H-B4 secToStr ok " + formatted);
        session.stop();
        session.discard();
        return true;
    } catch (ex) {
        logger.error("H-B4 CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"B\",\"location\":\"RaceTimeDebugTests.live\",\"message\":\"crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        session.stop();
        session.discard();
        return false;
    }
}

(:test)
function testHypothesisC_numberMediumFont(logger) {
    try {
        var height = Gfx.getFontHeight(Gfx.FONT_NUMBER_MEDIUM);
        logger.debug("H-C2 numberMedium height=" + height);
        return height > 0;
    } catch (ex) {
        logger.error("H-C2 CRASH " + ex.getErrorMessage());
        Sys.println("DBG {\"sessionId\":\"4a0bf5\",\"hypothesisId\":\"C\",\"location\":\"RaceTimeDebugTests.fontMedium\",\"message\":\"font crash\",\"data\":{\"error\":\"" + ex.getErrorMessage() + "\"}}");
        return false;
    }
}
