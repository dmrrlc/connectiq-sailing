using Toybox.WatchUi as Ui;
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
        if (evt.getKey() == WatchUi.KEY_ESC){
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
            if (App.getApp().isRecording()) {
                App.getApp().addLap();
                Ui.requestUpdate();
            } else {
                pushStopMenu();
            }
            return true;
    }

    function onMenu(){
            Ui.pushView(buildMainMenu(), new SailingMenuDelegate(), Ui.SLIDE_UP);
            Ui.requestUpdate();
            return true;
    }

    //! Race-only items are omitted in Cruise so the menu matches mode behavior.
    function buildMainMenu() {
        var menu = new Ui.Menu();
        menu.setTitle("Menu");
        if (!App.getApp().isCruiseMode()) {
            menu.addItem("Start timer", :start_timer);
            menu.addItem("Set timer", :set_timer);
        }
        menu.addItem("Toggle alarms", :set_alarms);
        menu.addItem("Sailing mode", :set_sailing_mode);
        if (!App.getApp().isCruiseMode()) {
            menu.addItem("Countdown signals", :set_mode);
        }
        return menu;
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
