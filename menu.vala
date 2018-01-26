/* 
 * Copyright (C) 2018 Xianguang Zhou <xianguang.zhou@outlook.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace DriveRemover {
    class DriveMenuItem : Gtk.ImageMenuItem {
        public GLib.Drive drive { get; private set; }
        private GLib.MountOperation operation;
    
        public DriveMenuItem(GLib.Drive drive) {
            this.set_image(new Gtk.Image.from_stock(Gtk.Stock.REMOVE, Gtk.IconSize.MENU));
            this.drive = drive;
            this.set_label("Remove \"%s\"".printf(drive.get_name()));
            this.activate.connect(this.stop_drive);
            this.operation = new GLib.MountOperation();
        }
    
        private async void stop_drive() {
            var flags = GLib.MountUnmountFlags.NONE;
            do {
                try {
                    yield this.drive.stop(flags, this.operation);
                    break;
                } catch (GLib.Error error) {
                    string message = "Removing drive \"%s\" failed, do you want to remove the drive by force?\nReason: %s".printf(this.drive.get_name(), error.message);
                    var dialog = new Gtk.MessageDialog(null, 0, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO, message);
                    dialog.set_title("Question");
                    dialog.set_position(Gtk.WindowPosition.CENTER);
                    dialog.set_icon_name("drive-removable-media");
                    int response = dialog.run();
                    dialog.destroy();
                    if (response == Gtk.ResponseType.YES) {
                        flags = GLib.MountUnmountFlags.FORCE;
                    } else {
                        break;
                    }
                }
            } while (true);
        }
    }

    class DriveMenu : Gtk.Menu {
        public void add_drive_item(GLib.Drive drive) {
            var menu_item = new DriveMenuItem(drive);
            this.append(menu_item);
            menu_item.show_all();
        }

        public void remove_drive_item(GLib.Drive drive) {
            foreach (var widget in this.get_children()) {
                DriveMenuItem menu_item = (DriveMenuItem)widget;
                if (menu_item.drive == drive) {
                    this.remove(widget);
                    widget.destroy();
                    break;
                }
            }
        }
    }        
}
