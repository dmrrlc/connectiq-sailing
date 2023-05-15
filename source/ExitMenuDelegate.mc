import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

class ExitMenuDelegate extends WatchUi.MenuInputDelegate {

  function initialize(){
      MenuInputDelegate.initialize();
  }

   function onMenuItem(item as Symbol) {
       if (item == :save_btn) {
            Application.getApp().saveAndClose();
        } else if (item == :discard_btn) {
            Application.getApp().discardAndClose();
        } else if (item == :resume_btn) {
        }
    }
}
