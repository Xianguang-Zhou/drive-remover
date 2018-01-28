#!/usr/bin/env python2
#-*- encoding: utf-8 -*-
# Copyright (C) 2016 Xianguang Zhou <xianguang.zhou@outlook.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import gio
import gtk
import pynotify as notify
from menu import DriveRemoveMenu
from menu import HelpMenu
from menu import NoneRemovableDriveMenu


class DriveRemover:
    def __init__(self):
        notify.init('Drive Remover')

        self.driveRemoveMenu = DriveRemoveMenu(self)
        self.helpMenu = HelpMenu(self)
        self.noneRemovableDriveMenu = NoneRemovableDriveMenu()

        self.volumeMonitor = gio.VolumeMonitor()
        self.volumeMonitor.connect('drive-connected', lambda volumeMonitor, drive: self.onDriveConnected(drive))
        self.volumeMonitor.connect('drive-disconnected', lambda volumeMonitor, drive: self.onDriveDisconnected(drive))

        for drive in self.volumeMonitor.get_connected_drives():
            if drive.can_stop():
                self.driveRemoveMenu.addDriveRemoveMenuItem(drive)

        self.statusIcon = gtk.StatusIcon()
        self.statusIcon.set_from_icon_name('drive-removable-media')
        self.statusIcon.set_tooltip_text('Drive Remover')
        self.statusIcon.connect('button-press-event', lambda widget, event: self.onStatusIconButtonPress(event))

    def onDriveConnected(self, drive):
        if drive.can_stop():
            self.driveRemoveMenu.addDriveRemoveMenuItem(drive)
            notification = notify.Notification('drive added', drive.get_name(), 'drive-removable-media')
            # notification.attach_to_status_icon(self.statusIcon)
            notification.show()

    def onDriveDisconnected(self, drive):
        if drive.can_stop():
            self.driveRemoveMenu.removeDriveRemoveMenuItem(drive)
            notification = notify.Notification('drive removed', drive.get_name(), 'drive-removable-media')
            # notification.attach_to_status_icon(self.statusIcon)
            notification.show()

    def run(self):
        self.statusIcon.set_visible(True)
        gtk.main()

    def onStatusIconButtonPress(self, event):
        if event.button == 1:
            if len(self.driveRemoveMenu.get_children()) > 0:
                self.driveRemoveMenu.show_all()
                self.driveRemoveMenu.popup(None, None, None, event.button, event.time)
            else:
                self.noneRemovableDriveMenu.show_all()
                self.noneRemovableDriveMenu.popup(None, None, None, event.button, event.time)
        elif event.button == 3:
            self.helpMenu.show_all()
            self.helpMenu.popup(None, None, None, event.button, event.time)

    def showAboutDialog(self):
        dialog = gtk.AboutDialog()
        dialog.set_logo_icon_name('drive-removable-media')
        dialog.set_program_name('Drive Remover')
        dialog.set_version('0.0.1')
        dialog.set_copyright('Copyright © 2016 Xianguang Zhou')
        dialog.set_authors(['Xianguang Zhou <xianguang.zhou@outlook.com>'])
        dialog.set_icon_name('drive-removable-media')
        dialog.set_position(gtk.WIN_POS_CENTER)
        dialog.run()
        dialog.destroy()

    def quit(self):
        gtk.main_quit()


def main():
    DriveRemover().run()


if __name__ == '__main__':
    main()
