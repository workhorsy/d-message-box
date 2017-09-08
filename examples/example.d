
import std.stdio : stdout;
import message_box : showMessageBox;


int main() {
	import derelict.sdl2.sdl : DerelictSDL2;
	import derelict.util.loader : SharedLibVersion;
	DerelictSDL2.load(SharedLibVersion(2, 0, 2));

	showMessageBox("Example text goes here ...");
	stdout.writefln("Dialog ...");

	return 0;
}
