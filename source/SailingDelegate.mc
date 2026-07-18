using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;


class SailingDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function pushStopMenu() {
        Ui.pushView(new Rez.Menus.StopMenu(), new ExitMenuDelegate(), Ui.SLIDE_UP);
        Ui.requestUpdate();
    }

    function onKey(evt){
        Sys.println("key evt : " +evt);
        if (evt.getKey() == WatchUi.KEY_ESC){
            Sys.println("back pressed (from event)");
            if (App.getApp().isRecording()) {
                App.getApp().addLap();
                Ui.requestUpdate();
            } else {
                pushStopMenu();
            }
            return true;
        }
        return false;
    }

    function onSelect(){
            Sys.println("select pressed");
            var app = App.getApp();
            if (app.hasActivitySession() == false) {
                app.startRecording();
            } else if (app.isRecording()) {
                app.pauseRecording();
                Ui.pushView(new Rez.Menus.PauseMenu(), new PauseMenuDelegate(), Ui.SLIDE_UP);
            } else {
                app.resumeRecording();
            }
            Ui.requestUpdate();
            return true;
    }

    function onBack(){
            Sys.println("back pressed");
            if (App.getApp().isRecording()) {
                App.getApp().addLap();
                Ui.requestUpdate();
            } else {
                pushStopMenu();
            }
            return true;
    }

    function onMenu(){
            Sys.println("menu pressed");
            Ui.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
    }

    function onPreviousPage(){
            var app = App.getApp();
            if (app.countDown != null && app.countDown.isTimerRunning()) {
                app.fixTimeUp();
            } else if (app.hasActivitySession() && app.sailingView != null) {
                app.sailingView.prevPage();
            }
            return true;
    }

    function onNextPage(){
            var app = App.getApp();
            if (app.countDown != null && app.countDown.isTimerRunning()) {
                app.fixTimeDown();
            } else if (app.hasActivitySession() && app.sailingView != null) {
                app.sailingView.nextPage();
            }
            return true;
    }
}
