



int main() {
	import message_box : showMessageBox, IconType;
	import std.stdio : stdout, stderr;

	// Show the message box
	if (! showMessageBox("Party Time", "The roof is on fire!", IconType.Warning)) {
		stderr.writefln("Failed to show message box.");
	}

	return 0;
}
