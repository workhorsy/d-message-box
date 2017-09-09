
import std.stdio : stdout;
import message_box : showMessageBox, IconType;


// FIXME: Add xmessage, and gxmessage
// Make it work without sdl imports
// What about OSX?

int main() {
	import derelict.sdl2.sdl : DerelictSDL2;
	import derelict.util.loader : SharedLibVersion;
	try {
		DerelictSDL2.load(SharedLibVersion(2, 0, 2));
	} catch (Throwable) {

	}

	showMessageBox("Go Boom", "Example text goes here ...", IconType.Error);
	stdout.writefln("Dialog ...");

	return 0;
}
