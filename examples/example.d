
import std.stdio : stdout, stderr;
import message_box : showMessageBox, IconType;


// FIXME
// Make it work without sdl imports
// What about OSX?
// Make it not direction external program output to console.

int main() {
	import derelict.sdl2.sdl : DerelictSDL2;
	import derelict.util.loader : SharedLibVersion;
	try {
		DerelictSDL2.load(SharedLibVersion(2, 0, 2));
	} catch (Throwable) {

	}

	if (! showMessageBox("Go Boom", "Example text goes here ...", IconType.Error)) {
		stderr.writefln("Failed to show message box.");
	}

	return 0;
}
