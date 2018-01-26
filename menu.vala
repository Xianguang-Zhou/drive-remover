class DriveRemove.MenuItem : Gtk.ImageMenuItem {
    private GLib.Drive drive;
    private GLib.MountOperation operation;

    public MenuItem(GLib.Drive drive) {
        this.set_image(new Gtk.Image.from_stock(Gtk.Stock.REMOVE, Gtk.IconSize.MENU));
        this.drive = drive;
        this.set_label("Remove \"%s\"".printf(drive.get_name()));
        this.activate.connect(this.stopDrive);
        this.operation = new GLib.MountOperation();
    }

    private async void stopDrive() {
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
