using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class SailingMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        // Race-only actions are gated in case mode changed while the menu was open
        if (item == :start_timer) {
            if (!App.getApp().isCruiseMode() && App.getApp().isRecording()) {
                App.getApp().startTimer();
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
