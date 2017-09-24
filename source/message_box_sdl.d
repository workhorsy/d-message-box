// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box_sdl;

import message_box : MessageBoxBase, IconType, is_sdl2_loadable;


class MessageBoxSDL : MessageBoxBase {
	this(string title, string message, IconType icon_type) {
		super(title, message, icon_type);
	}

	override void show() {
		version (Have_derelict_sdl2) {
			import std.string : toStringz;
			import derelict.sdl2.sdl : DerelictSDL2, SDL_ShowSimpleMessageBox,
				SDL_MESSAGEBOX_INFORMATION, SDL_MESSAGEBOX_ERROR, SDL_MESSAGEBOX_WARNING;

			uint flags = 0;
			final switch (_icon_type) {
				case IconType.None: flags = 0; break;
				case IconType.Information: flags = SDL_MESSAGEBOX_INFORMATION; break;
				case IconType.Error: flags = SDL_MESSAGEBOX_ERROR; break;
				case IconType.Warning: flags = SDL_MESSAGEBOX_WARNING; break;
			}

			// Try the SDL message box
			if (SDL_ShowSimpleMessageBox(flags, _title.toStringz, _message.toStringz, null) != 0) {
				if (_on_error_cb) _on_error_cb(new Exception("Failed to show SDL message box."));
			}
		} else {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to load SDL"));
		}
	}

	static bool isSupported() {
		return is_sdl2_loadable;
	}
}

