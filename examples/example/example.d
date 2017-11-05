

import std.stdio : stdout, stderr;
import message_box : MessageBox, IconType;


int main(string[] args) {
	// FIXME: Extract this away so the compressed file is inside the library
	import data : compressed_files;
	MessageBox.init(compressed_files);

	// Create the message box
	auto dialog = new MessageBox("Party Time", "The roof is on fire!", IconType.Warning);

	// Set the error handler
	dialog.onError((Throwable err) {
		stderr.writefln("Failed to show message box: %s", err);
	});

	// Show the message box
	dialog.show();

	return 0;
}
