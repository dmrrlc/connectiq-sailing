using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

class SailingMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        Sys.println("menu item selected");
        if (item == :start_timer) {
            Sys.println("start time pressed");
            if (App.getApp().isRecording()) {
                App.getApp().startTimer();
            } else {
                Sys.println("start timer ignored while not recording");
            }
        } else if (item == :set_timer) {
            Sys.println("set timer pressed");
            if (Ui has :Picker) {
                Ui.pushView(new TimePicker(), new TimePickerDelegate(), Ui.SLIDE_UP);
            }
        } else if (item == :set_alarms) {
            Sys.println("set alarms pressed");
            App.getApp().setAlarms(! App.getApp().getAlarms());
        } else if (item == :set_sailing_mode) {
            Sys.println("set sailing mode pressed");
            Ui.pushView(new Rez.Menus.SailingModeMenu(), new SailingModeMenuDelegate(), Ui.SLIDE_LEFT);
        } else if (item == :set_mode) {
            Sys.println("set mode pressed");
            Ui.pushView(new Rez.Menus.ModeMenu(), new ModeMenuDelegate(), Ui.SLIDE_LEFT);
        }
    }

    function initialize() {
        MenuInputDelegate.initialize();
    }
}
