using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

class PauseMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        Sys.println("pause menu item selected");
        if (item == :resume_btn) {
            App.getApp().resumeRecording();
        } else if (item == :lap_btn) {
            App.getApp().resumeRecording();
            App.getApp().addLap();
        } else if (item == :save_btn) {
            App.getApp().saveAndClose();
        } else if (item == :discard_btn) {
            App.getApp().discardAndClose();
        }
    }
}
