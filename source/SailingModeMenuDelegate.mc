using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

class SailingModeMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        Sys.println("sailing mode item selected: " + item);
        if (item == :sailing_mode_cruise) {
            App.getApp().setSailingMode(SAILING_MODE_CRUISE);
        } else if (item == :sailing_mode_race) {
            App.getApp().setSailingMode(SAILING_MODE_RACE);
        }
    }
}
