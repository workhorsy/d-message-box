

module extract;


import std.stdio : stdout, stderr;
import compressed_file : CompressedFile;


void extractFiles(string target_dir, immutable CompressedFile[] compressed_files, void delegate(int percent) progress_cb) {
	import std.string : format;

	string root_path;
	version (Windows) {
		root_path = expandPath(".");
	} else {
		root_path = expandPath(".");
		//stdout.writefln("root_path: %s", root_path);
	}

	// Get the CPU arch
	string arch;
	version (X86) {
		arch = "x86";
	} else {
		arch = "x86_64";
	}

	// Extract the files
	extract(target_dir, compressed_files, arch, root_path, progress_cb);
}

private void extract(string target_dir, immutable CompressedFile[] compressed_files, string arch, string root_path, void delegate(int percent) progress_cb) {
	import std.file : exists, mkdir, copy, mkdirRecurse, dirEntries, chdir, getcwd, SpanMode, isFile;
	version (Windows) { } else {
		import std.file : symlink;
	}
	import std.path : buildPath, dirName, baseName;
	import std.conv : to;
	import std.zlib : uncompress;
	import std.base64 : Base64;
	import std.process : execute;
	import std.stdio : File;
	import std.string : format;
	import std.algorithm : map;
	import std.array : array;

	progress_cb(0);

	// Make the project directory if it does not exist
	if (! exists(root_path)) {
		mkdir(root_path);
	}

	// Extract all the files
	double count = compressed_files.length.to!double;
	foreach (i, entry ; compressed_files) {
//		debug.FreeOSMemory();

		// Move the dialog percent forward
		int percent = ((i.to!double / count) * 100.0f).to!int;
		progress_cb(percent);

		string full_name = buildPath(target_dir, entry.name);

		// Skip if the file already exists
		if (exists(full_name)) {
			stdout.writefln("skipping extraction of: %s", entry.name);
			continue;
		}

		// If the entry is a symlink do nothing
		if (entry.is_symlink) {
			version (Windows) { } else {
				//stdout.writefln("name: %s, %s, data: %s", entry.name, dirName(entry.name), entry.data);

				// Make the directory if it does not exist
				string dir_name = dirName(full_name);
				if (! exists(dir_name)) {
					mkdirRecurse(dir_name);
				}

				string cwd = getcwd();
				chdir(dir_name);
				symlink(entry.data, baseName(full_name));
				chdir(cwd);
			}
		} else {
			stdout.writefln("Extracting: %s", full_name);

			// Unbase64 and uncompress the data
			ubyte[] unb64ed = Base64.decode(entry.data);
			ubyte[] data = cast(ubyte[]) uncompress(unb64ed);

			// Make the directory if it does not exist
			string dir_name = dirName(full_name);
			if (! exists(dir_name)) {
				mkdirRecurse(dir_name);
			}

			// Write the data to a file
			auto out_file = File(full_name, "wb");
			out_file.write(cast(char[])data);
			out_file.close();
		}
	}

	string cwd = getcwd();
	stdout.writefln("cwd: %s", cwd);
	//stdout.flush();

	progress_cb(100);
}

private string expandPath(string path_name) {
	import std.path : expandTilde;
	import std.process : environment;
	import std.algorithm : count;
	import std.string : replace;

	string path = expandTilde(path_name);
	foreach (key, value ; environment.toAA()) {
		if (count(path, key) > 0) {
			path = replace(path, "%" ~ key ~ "%", value);
		}
	}
	return path;
}
