

import std.stdio : stdout, stderr;
import message_box : MessageBox, IconType;


int main(string[] args) {
	import data : compressed_files;
	import extract : extractFiles;

	// FIXME: Move the extraction into message box lib
	extractFiles(compressed_files, delegate(int percent) {
		//dialog.setPercent(percent);
	});

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
