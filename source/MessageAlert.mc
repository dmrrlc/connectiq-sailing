using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

//! Simple multi-line alert dismissed with Select or Back.
class MessageAlertView extends Ui.View {

    var lines;

    function initialize(messageLines) {
        View.initialize();
        lines = messageLines;
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Gfx.FONT_SMALL;
        var lineHeight = Gfx.getFontHeight(font);
        var totalHeight = lines.size() * lineHeight;
        var y = (height - totalHeight) / 2;

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < lines.size(); i++) {
            dc.drawText(width / 2, y + (i * lineHeight), font, lines[i], Gfx.TEXT_JUSTIFY_CENTER);
        }
    }
}

class MessageAlertDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onSelect() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
