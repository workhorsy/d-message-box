// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


/++
A simple message box for the D programming language

It should work without requiring any 3rd party GUI toolkits. But will work with what
it can find on your OS at runtime.

It tries to use the following:

* DlangUI (win32 on Windows or SDL2 on Linux)

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
import std.stdio : stdout, stderr;
import message_box : MessageBox, IconType, RUN_MAIN;

mixin RUN_MAIN;

extern (C) int UIAppMain(string[] args) {
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
----
+/

module message_box;

bool is_sdl2_loadable = false;
bool message_box_use_log = false;

/++
This should be called once at the start of a program. It generates the proper
main function for your environment (win32/posix/dmail) and boot straps the
main loopd for the GUI. This will call your UIAppMain function when ready.
+/
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
The type of icon to show in the message box. Some message boxes will not show
the icon.

----
enum IconType {
	None,
	Information,
	Error,
	Warning,
}
----
+/

enum IconType {
	None,
	Information,
	Error,
	Warning,
}

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

/++
The MessageBox class
+/
class MessageBox {
	import message_box_dlangui : MessageBoxDlangUI;
	import message_box_sdl : MessageBoxSDL;
	import message_box_win32 : MessageBoxWin32;
	import message_box_zenity : MessageBoxZenity;
	import message_box_kdialog : MessageBoxKdialog;
	import message_box_gxmessage : MessageBoxGxmessage;

	/++
	Sets up the message box with the desired title, message, and icon. Does not
	show it until the show method is called.
	Params:
	 title = The string to show in the message box title
	 message = The string to show in the message box body
	 icon = The type of icon to show in the message box
	Throws:
	 If it fails to find any programs of libraries to make a message box with.
	+/
	this(string title, string message, IconType icon_type) {
		if (MessageBoxDlangUI.isSupported()) {
			_dialog = new MessageBoxDlangUI(title, message, icon_type);
		} else if (MessageBoxSDL.isSupported()) {
			_dialog = new MessageBoxSDL(title, message, icon_type);
		} else if (MessageBoxWin32.isSupported()) {
			_dialog = new MessageBoxWin32(title, message, icon_type);
		} else if (MessageBoxZenity.isSupported()) {
			_dialog = new MessageBoxZenity(title, message, icon_type);
		} else if (MessageBoxKdialog.isSupported()) {
			_dialog = new MessageBoxKdialog(title, message, icon_type);
		} else if (MessageBoxGxmessage.isSupported()) {
			_dialog = new MessageBoxGxmessage(title, message, icon_type);
		} else {
			throw new Exception("Failed to find a way to make a message box.");
		}
	}

	/++
	This method is called if there is an error when showing the message box.
	Params:
	 cb = The call back to fire when there is an error.
	+/
	void onError(void delegate(Throwable err) cb) {
		_dialog._on_error_cb = cb;
	}

	/++
	Shows the message box. Will block until it is closed.
	+/
	void show() {
		_dialog.show();
	}

	MessageBoxBase _dialog;
}
