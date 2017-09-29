// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box_win32;

import message_box : MessageBoxBase, IconType;


class MessageBoxWin32 : MessageBoxBase {
	this(string title, string message, IconType icon_type) {
		super(title, message, icon_type);
	}

	override void show() {
		version (Windows) {
			import core.runtime;
			import core.sys.windows.windows;
			import std.utf : toUTFz;

			int flags = 0;
			final switch (_icon_type) {
				case IconType.None: flags = 0; break;
				case IconType.Information: flags = MB_ICONINFORMATION; break;
				case IconType.Error: flags = MB_ICONERROR; break;
				case IconType.Warning: flags = MB_ICONWARNING; break;
			}

			int status = MessageBox(NULL, _message.toUTFz!(const(wchar)*), _title.toUTFz!(const(wchar)*), MB_OK | flags);
			if (status != 0) {
				this.fireOnError(new Exception("Failed to show Win32 message box."));
			}
		} else {
			this.fireOnError(new Exception("Failed to load Win32."));
		}
	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else {
			return false;
		}
	}
}
