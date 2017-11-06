// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple message box for the D programming language
// https://github.com/workhorsy/d-message-box

module extract;


import std.stdio : stdout, stderr;
import compressed_file : CompressedFile;


void extractFiles(string target_dir, immutable CompressedFile[] compressed_files, void delegate(int percent) progress_cb) {
	import std.file : exists, mkdir, copy, mkdirRecurse, chdir, getcwd;
	import std.path : buildPath, dirName, baseName;
	import std.conv : to;
	import std.zlib : uncompress;
	import std.base64 : Base64;
	import std.stdio : File;

	progress_cb(0);

	// Make the project directory if it does not exist
	string root_path = getcwd();
	if (! exists(root_path)) {
		mkdir(root_path);
	}

	// Extract all the files
	double count = compressed_files.length.to!double;
	foreach (i, entry ; compressed_files) {
		// Move the dialog percent forward
		int percent = ((i.to!double / count) * 100.0f).to!int;
		progress_cb(percent);

		string full_name = buildPath(target_dir, entry.name);

		// Skip if the file already exists
		if (exists(full_name)) {
			stdout.writefln("skipping extraction of: %s", entry.name);
			continue;
		}

		// Extract the file
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

	progress_cb(100);
}
