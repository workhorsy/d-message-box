// Copyright (c) 2017-2018 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box_gxmessage;

import message_box : MessageBoxBase, IconType, use_log;


class MessageBoxGxmessage : MessageBoxBase {
	this(string title, string message, IconType icon_type) {
		super(title, message, icon_type);
	}

	override void show() {
		import std.process : pipeProcess, wait, Redirect;
		import message_box_helpers : programPaths, logProgramOutput;

		string flags = "";
		final switch (_icon_type) {
			case IconType.None: flags = ""; break;
			case IconType.Information: flags = "Info: "; break;
			case IconType.Error: flags = "Error: "; break;
			case IconType.Warning: flags = "Warning: "; break;
		}

		// Show the message using gxmessage
		string[] paths = programPaths(["gxmessage"]);
		if (paths.length == 0) {
			this.fireOnError(new Exception("Failed to find Gxmessage."));
			return;
		}

		string[] args = [paths[0], "--ontop", "--center", "--title", _title, flags ~ _message];
		auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		int status = wait(pipes.pid);
		if (use_log) {
			logProgramOutput(pipes);
		}
		if (status != 0) {
			this.fireOnError(new Exception("Failed to show Gxmessage message box."));
		}
	}

	static bool isSupported() {
		import message_box_helpers : programPaths;
		return programPaths(["gxmessage"]).length > 0;
	}
}
