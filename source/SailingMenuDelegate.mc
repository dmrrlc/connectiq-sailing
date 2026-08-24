using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class SailingMenuDelegate extends Ui.MenuInputDelegate {

    function showTimerRequirementsWarning() {
        // Pop MainMenu first — nested views commonly OOM on low-memory devices
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.pushView(
            new MessageAlertView([
                "Need Race mode",
                "and activity",
                "started"
            ]),
            new MessageAlertDelegate(),
            Ui.SLIDE_IMMEDIATE
        );
    }

    function onMenuItem(item) {
        if (item == :start_timer) {
            var app = App.getApp();
            if (app.isCruiseMode() || (app.isRecording() == false)) {
                showTimerRequirementsWarning();
            } else {
                app.startTimer();
            }
        } else if (item == :set_timer) {
            if (!App.getApp().isCruiseMode() && (Ui has :Picker)) {
                // Dismiss MainMenu before pushing picker to avoid nested-view memory pressure
                Ui.popView(Ui.SLIDE_IMMEDIATE);
                Ui.pushView(new TimePicker(), new TimePickerDelegate(), Ui.SLIDE_UP);
            }
        } else if (item == :set_alarms) {
            App.getApp().setAlarms(! App.getApp().getAlarms());
        } else if (item == :set_sailing_mode) {
            // Pop MainMenu first — nested menus commonly OOM on low-memory devices
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            Ui.pushView(new Rez.Menus.SailingModeMenu(), new SailingModeMenuDelegate(), Ui.SLIDE_LEFT);
        } else if (item == :set_mode) {
            if (!App.getApp().isCruiseMode()) {
                Ui.popView(Ui.SLIDE_IMMEDIATE);
                Ui.pushView(new Rez.Menus.ModeMenu(), new ModeMenuDelegate(), Ui.SLIDE_LEFT);
            }
        }
    }

    function initialize() {
        MenuInputDelegate.initialize();
    }
}
