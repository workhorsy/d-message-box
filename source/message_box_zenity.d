// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box_zenity;

import message_box : MessageBoxBase, IconType, message_box_use_log;


class MessageBoxZenity : MessageBoxBase {
	this(string title, string message, IconType icon_type) {
		super(title, message, icon_type);
	}

	override void show() {
		import std.process : pipeProcess, wait, Redirect;
		import helpers : programPaths, logProgramOutput;

		string flags = "";
		final switch (_icon_type) {
			case IconType.None: flags = "--info"; break;
			case IconType.Information: flags = "--info"; break;
			case IconType.Error: flags = "--error"; break;
			case IconType.Warning: flags = "--warning"; break;
		}

		// Show the message using Zenity
		string[] paths = programPaths(["zenity"]);
		if (paths.length == 0) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to find Zenity."));
		}

		string[] args = [paths[0], flags, "--title=" ~ _title, "--text=" ~ _message];
		auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		int status = wait(pipes.pid);
		if (message_box_use_log) {
			logProgramOutput(pipes);
		}
		if (status != 0) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to show Zenity message box."));
		}
	}

	static bool isSupported() {
		import helpers : programPaths;
		return programPaths(["zenity"]).length > 0;
	}
}

