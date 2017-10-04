// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


import std.stdio : stdout, stderr;

bool is_sdl2_loadable = false;


static this() {
	import std.stdio : stdout;

	// Figure out if the SDL2 libraries can be loaded
	version (Have_derelict_sdl2) {
		import derelict.sdl2.sdl : DerelictSDL2, SharedLibVersion, SharedLibLoadException;
		try {
			DerelictSDL2.load(SharedLibVersion(2, 0, 2));
			is_sdl2_loadable = true;
			stdout.writefln("SDL was found ...");
		} catch (SharedLibLoadException) {
			stdout.writefln("SDL was NOT found ...");
		}
	}
}

enum IconType {
	None,
	Information,
	Error,
	Warning,
}


class MessageBoxDlangUI {
	import dlangui;

	this(string title, string message, IconType icon_type) {
		_title = title;
		_message = message;
		_icon_type = icon_type;
	}

	void show() {
		import std.conv : to;
		import core.thread : Thread;

		// create window
		auto flags = WindowFlag.Modal;
		auto window = Platform.instance.createWindow(_title.to!dstring, null, flags, 300, 150);

		// Create the layout
		auto vlayout = new VerticalLayout();
		vlayout.margins = 20;
		vlayout.padding = 10;

		// FIXME: Figure out how to add information, error, and warning icons
		// Add an icon
		const Action action = ACTION_ABORT;
		string drawableId = action.iconId;
		auto icon = new ImageWidget("icon", drawableId);

		// Add the text
		auto text = new MultilineTextWidget(null, _message.to!dstring);

		// Add the button
		auto button = new Button();
		button.text = "Okay";
		button.click = delegate(Widget w) {
			window.close();
			return true;
		};

		// Add the controls to the window
		vlayout.addChild(icon);
		vlayout.addChild(text);
		vlayout.addChild(button);
		window.mainWidget = vlayout;

		// show window
		window.show();

		Platform.instance.enterMessageLoop();
	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else version (Have_derelict_sdl2) {
			return is_sdl2_loadable;
		} else {
			return false;
		}
	}

	void onError(void delegate(Throwable err) cb) {
		_on_error_cb = cb;
	}

	void fireOnError(Throwable err) {
		auto old_cb = _on_error_cb;
		_on_error_cb = null;

		if (old_cb) old_cb(err);
	}

	string _title;
	string _message;
	IconType _icon_type;
	void delegate(Throwable err) _on_error_cb;
}


// On Windows use the normal dlangui main
version (Windows) {
	import dlangui;
	mixin APP_ENTRY_POINT;
// On Linux use a custom main that checks if SDL is installed
} else {
	int main(string[] args) {
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

extern (C) int UIAppMain(string[] args) {
	// Create the message box
	auto dialog = new MessageBoxDlangUI("Party Time", "The roof is on fire!", IconType.Warning);

	// Set the error handler
	dialog.onError((Throwable err) {
		stderr.writefln("Failed to show message box: %s", err);
	});

	// Show the message box
	dialog.show();

	return 0;
}
