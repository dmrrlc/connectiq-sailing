using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class ExitMenuDelegate extends Ui.MenuInputDelegate {

  function initialize(){
      MenuInputDelegate.initialize();
  }

   function onMenuItem(item) {
       if (item == :save_btn) {
            App.getApp().saveAndClose();
        } else if (item == :discard_btn) {
            App.getApp().discardAndClose();
        } else if (item == :resume_btn) {
           // Do nothing -> return
            App.getApp().refreshUi();
        }
        Ui.requestUpdate();
    }
}
