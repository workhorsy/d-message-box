

import std.stdio : stdout, stderr;
import message_box : MessageBox, IconType, RUN_MAIN;



extern (C) int UIAppMain(string[] args) {
	import core.thread;

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


mixin RUN_MAIN;


