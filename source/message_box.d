// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box


module message_box;

enum IconType {
	None,
	Information,
	Error,
	Warning,
}

private string[] glob(string pattern) {
	version (Windows) {
		import std.file : dirEntries, SpanMode;
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

private bool showMessageBoxSDL(string title, string message, IconType icon) {
	import std.string : toStringz;
	import derelict.sdl2.sdl : DerelictSDL2, SDL_ShowSimpleMessageBox,
		SDL_MESSAGEBOX_INFORMATION, SDL_MESSAGEBOX_ERROR, SDL_MESSAGEBOX_WARNING;

	uint flags = 0;
	final switch (icon) {
		case IconType.None: flags = 0; break;
		case IconType.Information: flags = SDL_MESSAGEBOX_INFORMATION; break;
		case IconType.Error: flags = SDL_MESSAGEBOX_ERROR; break;
		case IconType.Warning: flags = SDL_MESSAGEBOX_WARNING; break;
	}

	// Try the SDL message box first
	if (DerelictSDL2.isLoaded()) {
		if (SDL_ShowSimpleMessageBox(flags, title.toStringz, message.toStringz, null) == 0) {
		}
		return true;
	}

	return false;
}

private bool showMessageBoxWindows(string title, string message, IconType icon) {
	version (Windows) {
		import core.runtime;
		import core.sys.windows.windows;
		import std.utf : toUTFz;

		int flags = 0;
		final switch (icon) {
			case IconType.None: flags = 0; break;
			case IconType.Information: flags = MB_ICONINFORMATION; break;
			case IconType.Error: flags = MB_ICONERROR; break;
			case IconType.Warning: flags = MB_ICONWARNING; break;
		}

		MessageBox(NULL, message.toUTFz!(const(wchar)*), title.toUTFz!(const(wchar)*), MB_OK | flags);
		return true;
	} else {
		return false;
	}
}

private bool showMessageBoxZenity(string title, string message, IconType icon) {
	import std.process : spawnProcess, wait;

	string flags = "";
	final switch (icon) {
		case IconType.None: flags = "--info"; break;
		case IconType.Information: flags = "--info"; break;
		case IconType.Error: flags = "--error"; break;
		case IconType.Warning: flags = "--warning"; break;
	}

	// Show the message using Zenity
	string[] paths = programPaths(["zenity"]);
	if (paths.length > 0) {
		string[] args = [paths[0], flags, "--title=" ~ title, "--text=" ~ message];
		auto pid = spawnProcess(args);
		int status = wait(pid);
		return true;
	}

	return false;
}

private bool showMessageBoxKdialog(string title, string message, IconType icon) {
	import std.process : spawnProcess, wait;

	string flags = "";
	final switch (icon) {
		case IconType.None: flags = "--msgbox"; break;
		case IconType.Information: flags = "--msgbox"; break;
		case IconType.Error: flags = "--error"; break;
		case IconType.Warning: flags = "--sorry"; break;
	}

	// Show the message using kdialog
	string[] paths = programPaths(["kdialog"]);
	if (paths.length > 0) {
		string[] args = [paths[0], flags, message, "--title", title];
		auto pid = spawnProcess(args);
		int status = wait(pid);
		return true;
	}

	return false;
}

private bool showMessageBoxGxmessage(string title, string message, IconType icon) {
	import std.process : spawnProcess, wait;

	string flags = "";
	final switch (icon) {
		case IconType.None: flags = ""; break;
		case IconType.Information: flags = "Info: "; break;
		case IconType.Error: flags = "Error: "; break;
		case IconType.Warning: flags = "Warning: "; break;
	}

	// Show the message using gxmessage
	string[] paths = programPaths(["gxmessage"]);
	if (paths.length > 0) {
		string[] args = [paths[0], "--ontop", "--center", "--title", title, flags ~ message];
		auto pid = spawnProcess(args);
		int status = wait(pid);
		return true;
	}

	return false;
}

void showMessageBox(string title, string message, IconType icon) {
	import std.stdio : stderr;

	bool did_show = false;

	if (! did_show) {
		did_show = showMessageBoxSDL(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxWindows(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxZenity(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxKdialog(title, message, icon);
	}

	if (! did_show) {
		did_show = showMessageBoxGxmessage(title, message, icon);
	}

	// Fall back to printing to stderr
	if (! did_show) {
		stderr.writefln("%s", message);
	}
}
