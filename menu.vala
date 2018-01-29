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
            this.set_label("Remove \"%s\"".printf(drive.get_name()));
            
            this.drive = drive;
            this.operation = new GLib.MountOperation();

            this.activate.connect(this.on_activate);            
        }

        private async void on_activate() {
            var flags = GLib.MountUnmountFlags.NONE;
            do {
                try {
                    yield this.drive.eject_with_operation(flags, this.operation);
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
                        return;
                    }
                }
            } while (true);

            on_remove();
        }

        public void on_remove() {
            this.get_parent().remove(this);
            this.destroy();

            var notification = new Notify.Notification("drive removed", drive.get_name(), "drive-removable-media");
            try {
                notification.show();
            } catch (GLib.Error error) {
                stderr.printf("%s\n", error.message);
            }
        }
    }

    class DriveMenu : Gtk.Menu {
        public bool add_drive_item_without_notify(GLib.Drive drive) {
            if (drive.can_eject() && drive.has_media()) {
                var menu_item = new DriveMenuItem(drive);
                this.append(menu_item);
                menu_item.show_all();
                return true;
            }
            return false;
        }

        public void add_drive_item(GLib.Drive drive) {
            if (add_drive_item_without_notify(drive)) {
                var notification = new Notify.Notification("drive added", drive.get_name(), "drive-removable-media");
                try {
                    notification.show();
                } catch (GLib.Error error) {
                    stderr.printf("%s\n", error.message);
                }
            }
        }

        public void remove_drive_item(GLib.Drive drive) {
            if (drive.can_eject() && drive.has_media()) {
                foreach (var widget in this.get_children()) {
                    DriveMenuItem menu_item = (DriveMenuItem)widget;
                    if (menu_item.drive == drive) {
                        menu_item.on_remove();
                        break;
                    }
                }
            }
        }
    }

    class EmptyMenu : Gtk.Menu {
        public EmptyMenu() {
            var menu_item = new Gtk.MenuItem.with_label("None Removable Drive");
            menu_item.set_sensitive(false);
            this.append(menu_item);
        }
    }

    class HelpMenu : Gtk.Menu {
        public HelpMenu() {
            var quit_menu_item = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.QUIT, null);
            quit_menu_item.activate.connect(Gtk.main_quit);
            this.append(quit_menu_item);

            var about_menu_item = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.ABOUT, null);
            about_menu_item.activate.connect(this.show_about_dialog);
            this.append(about_menu_item);
        }

        private void show_about_dialog() {
            var dialog = new Gtk.AboutDialog();
            dialog.set_logo_icon_name("drive-removable-media");
            dialog.set_program_name("Drive Remover");
            dialog.set_version("0.0.1");
            dialog.set_copyright("Copyright © 2016-2018 Xianguang Zhou");
            dialog.set_authors({"Xianguang Zhou <xianguang.zhou@outlook.com>"});
            dialog.set_icon_name("drive-removable-media");
            dialog.set_position(Gtk.WindowPosition.CENTER);
            dialog.run();
            dialog.destroy();
        }
    }
}
