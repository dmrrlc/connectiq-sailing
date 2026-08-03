using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class SailingModeMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :sailing_mode_cruise) {
            App.getApp().setSailingMode(SAILING_MODE_CRUISE);
        } else if (item == :sailing_mode_race) {
            App.getApp().setSailingMode(SAILING_MODE_RACE);
        }
    }
}
