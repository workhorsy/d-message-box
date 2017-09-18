



int main() {
	import derelict.sdl2.sdl : DerelictSDL2;
	import derelict.util.loader : SharedLibVersion, SharedLibLoadException;
	import message_box : showMessageBox, IconType, message_box_use_log;
	import std.stdio : stdout, stderr;

	// Load SDL
	try {
		DerelictSDL2.load(SharedLibVersion(2, 0, 2));
	} catch (SharedLibLoadException) {

	}

	message_box_use_log = true;

	// Show the message box
	if (! showMessageBox("Birthday", "Today is Bob's Birthday!", IconType.Information)) {
		stderr.writefln("Failed to show message box.");
	}

	return 0;
}
