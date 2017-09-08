// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box;



private string[] glob(string pattern) {
	version (Windows) {
		import std.file : dirEntries;
		string[] retval;
		foreach (entry; dirEntries("", pattern, SpanMode.breadth)) {
			retval ~= entry;
		}
		return retval;
	} else {
		import glob : glob;
		return glob(pattern);
	}
}

private bool isExecutable(string path) {
	version (Windows) {
		return true;
	} else {
		import std.file : getAttributes;
		import core.sys.posix.sys.stat : S_IXUSR;
		return (getAttributes(path) & S_IXUSR) > 0;
	}
}

private string[] programPaths(string[] program_names) {
	import std.process : environment;
	import std.path : pathSeparator, buildPath;
	import std.file : isDir;
	import std.string : split;

	string[] paths;
	string[] exts;
	if (environment.get("PATHEXT")) {
		exts = environment["PATHEXT"].split(pathSeparator);
	}

	// Each path
	foreach (p ; environment["PATH"].split(pathSeparator)) {
		//stdout.writefln("p: %s", p);
		// Each program name
		foreach (program_name ; program_names) {
			string full_name = buildPath(p, program_name);
			//stdout.writefln("full_name: %s", full_name);
			string[] full_names = glob(full_name);
			//stdout.writefln("full_names: %s", full_names);

			// Each program name that exists in a path
			foreach (name ; full_names) {
				// Save the path if it is executable
				if (name && isExecutable(name) && ! isDir(name)) {
					paths ~= name;
				}
				// Save the path if we found one with a common extension like .exe
				foreach (e; exts) {
					string full_name_ext = name ~ e;

					if (isExecutable(full_name_ext) && ! isDir(full_name_ext)) {
						paths ~= full_name_ext;
					}
				}
			}
		}
	}

	return paths;
}

private bool showMessageBoxSDL(string message) {
	import std.string : toStringz;
	import derelict.sdl2.sdl : DerelictSDL2, SDL_ShowSimpleMessageBox, SDL_MESSAGEBOX_ERROR;

	// Try the SDL message box first
	if (DerelictSDL2.isLoaded()) {
		if (SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error".toStringz, message.toStringz, null) == 0) {
		}
		return true;
	}

	return false;
}

private bool showMessageBoxWindows(string message) {
	version (Windows) {
		import std.process : spawnProcess, wait;
		auto pid = spawnProcess(["./msg_box.exe", message]);
		int status = wait(pid);
		return true;
	}

	return false;
}

private bool showMessageBoxZenity(string message) {
	import std.process : spawnProcess, wait;

	// Show the message using Zenity
	string[] paths = programPaths(["zenity"]);
	if (paths.length > 0) {
		auto pid = spawnProcess([paths[0], "--error", "--text=\"" ~ message ~ "\""]);
		int status = wait(pid);
		return true;
	}

	return false;
}

void showMessageBox(string message) {
	import std.stdio : stderr;

	bool did_show = false;

	if (! did_show) {
		did_show = showMessageBoxSDL(message);
	}

	if (! did_show) {
		did_show = showMessageBoxWindows(message);
	}

	if (! did_show) {
		did_show = showMessageBoxZenity(message);
	}

	// Fall back to printing to stderr
	if (! did_show) {
		stderr.writefln("%s", message);
	}
}
