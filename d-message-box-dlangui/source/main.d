// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


import std.stdio : stdout, stderr;
import dlangui;


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



mixin APP_ENTRY_POINT;


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
