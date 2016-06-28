#-*- encoding: utf-8 -*-
# Copyright (C) 2015 Xianguang Zhou <xianguang.zhou@outlook.com>
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


class DriveRemoveMenuItem(gtk.ImageMenuItem):
    def __init__(self, drive):
        gtk.ImageMenuItem.__init__(self, stock_id=gtk.STOCK_REMOVE)
        self.drive = drive
        self.set_label('Remove "%s"' % drive.get_name())
        self.connect('activate', lambda widget: self.stopDrive())
        self.operation = gio.MountOperation()

    def stopDrive(self):
        self.drive.stop(mount_operation=self.operation, callback=self.stopDriveCallback)

    def stopDriveCallback(self, drive, result):
        try:
            drive.stop_finish(result)
        except gio.Error as error:
            message = 'Removing drive "%s" failed,do you want to remove the drive by force?\nReason: %s' % \
                      (drive.get_name(), error.message)
            dialog = gtk.MessageDialog(type=gtk.MESSAGE_QUESTION, buttons=gtk.BUTTONS_YES_NO, message_format=message)
            dialog.set_title('Question')
            dialog.set_position(gtk.WIN_POS_CENTER)
            dialog.set_icon_name('drive-removable-media')
            response = dialog.run()
            dialog.destroy()
            if response == gtk.RESPONSE_YES:
                drive.stop(mount_operation=self.operation, callback=self.stopDriveCallback,
                           flags=gio.MOUNT_UNMOUNT_FORCE)


class DriveRemoveMenu(gtk.Menu):
    def __init__(self, driveRemover):
        gtk.Menu.__init__(self)
        self.driveRemover = driveRemover

    def addDriveRemoveMenuItem(self, drive):
        driveRemoveMenuItem = DriveRemoveMenuItem(drive)
        self.append(driveRemoveMenuItem)
        driveRemoveMenuItem.show_all()

    def removeDriveRemoveMenuItem(self, drive):
        for driveRemoveMenuItem in self.get_children():
            if driveRemoveMenuItem.drive == drive:
                self.remove(driveRemoveMenuItem)
                driveRemoveMenuItem.destroy()
                break


class NoneRemovableDriveMenu(gtk.Menu):
    def __init__(self):
        gtk.Menu.__init__(self)

        self.messageMenuItem = gtk.MenuItem()
        self.messageMenuItem.set_label('None Removable Drive')
        self.messageMenuItem.set_sensitive(False)
        self.append(self.messageMenuItem)


class HelpMenu(gtk.Menu):
    def __init__(self, driveRemover):
        gtk.Menu.__init__(self)
        self.driveRemover = driveRemover

        self.quitMenuItem = gtk.ImageMenuItem(stock_id=gtk.STOCK_QUIT)
        self.append(self.quitMenuItem)
        self.quitMenuItem.connect('activate', lambda widget: self.driveRemover.quit())

        self.aboutMenuItem = gtk.ImageMenuItem(stock_id=gtk.STOCK_ABOUT)
        self.append(self.aboutMenuItem)
        self.aboutMenuItem.connect('activate', lambda widget: self.driveRemover.showAboutDialog())
