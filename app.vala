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
    class App : GLib.Object {
        private DriveMenu drive_menu;
        private HelpMenu help_menu;
        private EmptyMenu empty_menu;

        private GLib.VolumeMonitor volume_monitor;

        private Gtk.StatusIcon status_icon;

        public App() {
            Notify.init("Drive Remover");

            this.drive_menu = new DriveMenu();
            this.help_menu = new HelpMenu();
            this.empty_menu = new EmptyMenu();

            this.volume_monitor = GLib.VolumeMonitor.get();
            this.volume_monitor.drive_connected.connect(this.on_drive_connected);

            foreach (Drive drive in this.volume_monitor.get_connected_drives()) {
                if (drive.can_eject() && drive.has_volumes()) {
                    this.drive_menu.add_drive_item(drive);
                }
            }

            this.status_icon = new Gtk.StatusIcon.from_icon_name("drive-removable-media");
            this.status_icon.set_tooltip_text("Drive Remover");
            this.status_icon.button_press_event.connect(this.on_status_icon_button_press);
        }

        private void on_drive_connected(GLib.Drive drive) {
            if (drive.can_eject() && drive.has_volumes()) {
                this.drive_menu.add_drive_item(drive);
                var notification = new Notify.Notification("drive added", drive.get_name(), "drive-removable-media");
                try {
                    notification.show();
                } catch (GLib.Error error) {
                    stderr.printf("%s\n", error.message);
                }
            }
        }

        private bool on_status_icon_button_press(Gdk.EventButton event) {
            if (event.button == 1) {
                if (this.drive_menu.get_children().length() > 0) {
                    this.drive_menu.show_all();
                    this.drive_menu.popup(null, null, this.status_icon.position_menu, event.button, event.time);
                } else {
                    this.empty_menu.show_all();
                    this.empty_menu.popup(null, null, this.status_icon.position_menu, event.button, event.time);
                }
            } else if (event.button == 3) {
                this.help_menu.show_all();
                this.help_menu.popup(null, null, this.status_icon.position_menu, event.button, event.time);
            } else {
                return false;
            }
            return true;
        }

        public void run() {
            this.status_icon.set_visible(true);
            Gtk.main();
        }
    }
}

int main(string[] args) {
    Gtk.init(ref args);
    new DriveRemover.App().run();
    return 0;
}
