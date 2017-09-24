// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


/++
A simple message box for the D programming language

It should work without requiring any 3rd party GUI toolkits. But will work with what
it can find on your OS at runtime.

It tries to use the following:

* SDL_ShowSimpleMessageBox (Derelict SDL2)

* MessageBoxW (Windows)

* Zenity (Gtk/Gnome)

* Kdialog (KDE)

* gxmessage (X11)

Home page:
$(LINK https://github.com/workhorsy/d-message-box)

Version: 0.1.0

License:
Boost Software License - Version 1.0

Examples:
----
import message_box : showMessageBox, IconType;
import std.stdio : stdout, stderr;

// Show the message box
if (! showMessageBox("Party Time", "The roof is on fire!", IconType.Warning)) {
	stderr.writefln("Failed to show message box.");
}
----
+/

module message_box;

bool is_sdl2_loadable = false;
bool message_box_use_log = false;

mixin template RUN_MAIN() {
	// On Windows use the normal dlangui main
	version (Windows) {
		import dlangui;
		mixin APP_ENTRY_POINT;
	// On Linux use a custom main that checks if SDL is installed
	} else {
		int main(string[] args) {
			// Figure out if the SDL2 libraries can be loaded
			version (Have_derelict_sdl2) {
				import derelict.sdl2.sdl : DerelictSDL2, SharedLibVersion, SharedLibLoadException;
				import message_box : is_sdl2_loadable;
				try {
					DerelictSDL2.load(SharedLibVersion(2, 0, 2));
					is_sdl2_loadable = true;
					stdout.writefln("SDL was found ...");
				} catch (SharedLibLoadException) {
					stdout.writefln("SDL was NOT found ...");
				}
			}

			// If SDL2 can be loaded, start the SDL2 main
			if (is_sdl2_loadable) {
				import dlangui.platforms.sdl.sdlapp : sdlmain;
				return sdlmain(args);
			// If not, use the normal main provided by the user
			} else {
				return UIAppMain(args);
			}
		}
	}
}


/++
If true will print output of external program to console.
Params:
 is_logging = If true will print to output
+/
public void setMessageBoxUseLog(bool is_logging) {
	message_box_use_log = is_logging;
}

/++
Returns if external program logging is on or off.
+/
public bool getMessageBoxUseLog() {
	return message_box_use_log;
}

/++
The type of icon to use in the message box.
----
enum IconType {
	None,
	Information,
	Error,
	Warning,
}
----
+/

abstract class MessageBoxBase {
	this(string title, string message, IconType icon_type) {
		_title = title;
		_message = message;
		_icon_type = icon_type;
	}

	void onError(void delegate(Throwable err) cb) {
		_on_error_cb = cb;
	}

	void show();

	string _title;
	string _message;
	IconType _icon_type;
	void delegate(Throwable err) _on_error_cb;
}

class MessageBoxSDL : MessageBoxBase {
	this(string title, string message, IconType icon_type) {
		super(title, message, icon_type);
	}

	override void show() {

	}

	static bool isSupported() {
/*
version (Have_derelict_sdl2) {
	import std.string : toStringz;
	import derelict.sdl2.sdl : DerelictSDL2, SDL_ShowSimpleMessageBox,
		SDL_MESSAGEBOX_INFORMATION, SDL_MESSAGEBOX_ERROR, SDL_MESSAGEBOX_WARNING;

	uint flags = 0;
	final switch (icon) {
		case IconType.None: flags = 0; break;
		case IconType.Information: flags = SDL_MESSAGEBOX_INFORMATION; break;
		case IconType.Error: flags = SDL_MESSAGEBOX_ERROR; break;
		case IconType.Warning: flags = SDL_MESSAGEBOX_WARNING; break;
	}

	// Try the SDL message box
	if (DerelictSDL2.isLoaded()) {
		if (SDL_ShowSimpleMessageBox(flags, title.toStringz, message.toStringz, null) == 0) {
			return true;
		}
	}
}
*/
		return true;
	}
}

enum IconType {
	None,
	Information,
	Error,
	Warning,
}

class MessageBox {
	this(string title, string message, IconType icon_type) {
		if (MessageBoxSDL.isSupported()) {
			_dialog = new MessageBoxSDL(title, message, icon_type);
		} else {
			throw new Exception("Failed to find a way to make a message box.");
		}
	}

	void onError(void delegate(Throwable err) cb) {
		_dialog._on_error_cb = cb;
	}

	void show() {
		_dialog.show();
	}

	MessageBoxBase _dialog;
}

private bool showMessageBoxSDL(string title, string message, IconType icon) {
	version (Have_derelict_sdl2) {
		import std.string : toStringz;
		import derelict.sdl2.sdl : DerelictSDL2, SDL_ShowSimpleMessageBox,
			SDL_MESSAGEBOX_INFORMATION, SDL_MESSAGEBOX_ERROR, SDL_MESSAGEBOX_WARNING;

		uint flags = 0;
		final switch (icon) {
			case IconType.None: flags = 0; break;
			case IconType.Information: flags = SDL_MESSAGEBOX_INFORMATION; break;
			case IconType.Error: flags = SDL_MESSAGEBOX_ERROR; break;
			case IconType.Warning: flags = SDL_MESSAGEBOX_WARNING; break;
		}

		// Try the SDL message box
		if (DerelictSDL2.isLoaded()) {
			if (SDL_ShowSimpleMessageBox(flags, title.toStringz, message.toStringz, null) == 0) {
				return true;
			}
		}
	}

	return false;
}

private bool showMessageBoxWindows(string title, string message, IconType icon) {
	version (Windows) {
		import core.runtime;
		import core.sys.windows.windows;
		import std.utf : toUTFz;

		int flags = 0;
		final switch (icon) {
			case IconType.None: flags = 0; break;
			case IconType.Information: flags = MB_ICONINFORMATION; break;
			case IconType.Error: flags = MB_ICONERROR; break;
			case IconType.Warning: flags = MB_ICONWARNING; break;
		}

		int status = MessageBox(NULL, message.toUTFz!(const(wchar)*), title.toUTFz!(const(wchar)*), MB_OK | flags);
		if (status == 0) {
			return false;
		}

		return false;
	} else {
		return false;
	}
}

private bool showMessageBoxZenity(string title, string message, IconType icon) {
	import std.process : pipeProcess, wait, Redirect;
	import helpers : programPaths, logProgramOutput;

	string flags = "";
	final switch (icon) {
		case IconType.None: flags = "--info"; break;
		case IconType.Information: flags = "--info"; break;
		case IconType.Error: flags = "--error"; break;
		case IconType.Warning: flags = "--warning"; break;
	}

	// Show the message using Zenity
	string[] paths = programPaths(["zenity"]);
	if (paths.length > 0) {
		string[] args = [paths[0], flags, "--title=" ~ title, "--text=" ~ message];
		auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		int status = wait(pipes.pid);
		if (message_box_use_log) {
			logProgramOutput(pipes);
		}
		if (status == 0) {
			return true;
		}
	}

	return false;
}

private bool showMessageBoxKdialog(string title, string message, IconType icon) {
	import std.process : pipeProcess, wait, Redirect;
	import helpers : programPaths, logProgramOutput;

	string flags = "";
	final switch (icon) {
		case IconType.None: flags = "--msgbox"; break;
		case IconType.Information: flags = "--msgbox"; break;
		case IconType.Error: flags = "--error"; break;
		case IconType.Warning: flags = "--sorry"; break;
	}

	// Show the message using kdialog
	string[] paths = programPaths(["kdialog"]);
	if (paths.length > 0) {
		string[] args = [paths[0], flags, message, "--title", title];
		auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		int status = wait(pipes.pid);
		if (message_box_use_log) {
			logProgramOutput(pipes);
		}
		if (status == 0) {
			return true;
		}
	}

	return false;
}

private bool showMessageBoxGxmessage(string title, string message, IconType icon) {
	import std.process : pipeProcess, wait, Redirect;
	import helpers : programPaths, logProgramOutput;

	string flags = "";
	final switch (icon) {
		case IconType.None: flags = ""; break;
		case IconType.Information: flags = "Info: "; break;
		case IconType.Error: flags = "Error: "; break;
		case IconType.Warning: flags = "Warning: "; break;
	}

	// Show the message using gxmessage
	string[] paths = programPaths(["gxmessage"]);
	if (paths.length > 0) {
		string[] args = [paths[0], "--ontop", "--center", "--title", title, flags ~ message];
		auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		int status = wait(pipes.pid);
		if (message_box_use_log) {
			logProgramOutput(pipes);
		}
		if (status == 0) {
			return true;
		}
	}

	return false;
}

/++
Shows the message box with the desired title, message, and icon.
Params:
 title = The string to show in the message box title
 message = The string to show in the message box body
 icon = The type of icon to show in the message box
+/

bool showMessageBox(string title, string message, IconType icon) {
	import std.stdio : stderr;

	bool did_show = false;

	if (! did_show) {
		did_show = showMessageBoxSDL(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxWindows(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxZenity(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxKdialog(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxGxmessage(title, message, icon);
	}

	return did_show;
}
