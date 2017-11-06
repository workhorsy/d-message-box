// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box_dlangui;

import message_box : MessageBoxBase, IconType, use_log, is_sdl2_loadable;


class MessageBoxDlangUI : MessageBoxBase {
	this(string exe_dir, string title, string message, IconType icon_type) {
		super(title, message, icon_type);
		_exe_dir = exe_dir;
	}

	override void show() {
		import std.process : pipeProcess, wait, Redirect;
		import std.string : format;
		import std.file : exists;
		import std.path : buildPath;
		import message_box_helpers : programPaths, logProgramOutput;

		// Find the message box program
		string path = buildPath(_exe_dir, "message_box_dlangui.exe");
		if (! exists(path)) {
			this.fireOnError(new Exception("Failed to find message_box_dlangui.exe."));
			return;
		}

		// Get the icon type arg
		string icon_type = "";
		final switch (_icon_type) {
			case IconType.None: icon_type = "None"; break;
			case IconType.Information: icon_type = "Information"; break;
			case IconType.Error: icon_type = "Error"; break;
			case IconType.Warning: icon_type = "Warning"; break;
		}

		// Create all the command line args
		string[] args = [
			path,
			`--title=%s`.format(_title),
			`--message=%s`.format(_message),
			`--icon_type=%s`.format(icon_type)
		];

		// Run the message box program
		auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		int status = wait(pipes.pid);
		if (use_log) {
			logProgramOutput(pipes);
		}
		if (status != 0) {
			this.fireOnError(new Exception("Failed to show the dlangui message box."));
		}
	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else {
			return is_sdl2_loadable;
		}
	}

	string _exe_dir;
}
