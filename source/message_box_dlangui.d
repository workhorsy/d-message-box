// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box_dlangui;

import message_box : MessageBoxBase, IconType, is_sdl2_loadable;


class MessageBoxDlangUI : MessageBoxBase {
	import dlangui;

	this(string title, string message, IconType icon_type) {
		super(title, message, icon_type);
	}

	override void show() {
		import std.conv : to;
		import core.thread : Thread;

		// create window
		auto flags = WindowFlag.Modal;
		auto window = Platform.instance.createWindow(_title.to!dstring, null, flags, 300, 150);

		auto vlayout = new VerticalLayout();
		vlayout.margins = 20;
		vlayout.padding = 10;

		// Add the text
		auto text = new TextWidget(null, _message.to!dstring);

		// Add the button
		auto button = new Button();
		button.text = "Okay";
		button.click = delegate(Widget w) {
			window.close();
			return true;
		};

		// Add the controls to the window
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
}

