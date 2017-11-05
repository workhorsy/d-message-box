
import std.stdio : stdout, stderr;


import compressed_file : CompressedFile;

CompressedFile EntryToCompressedFile(string name) {
	import std.file : FileException, isSymlink, read;
	import std.path : baseName;

	version (Windows) { } else {
		import std.file : readLink;
	}
	import std.zlib : compress;
	import std.base64 : Base64;

	bool is_symlink = isSymlink(name);
	string b64ed;

	// If the file is normal, compress and base64 it
	if (! is_symlink) {
		ubyte[] file_data = cast(ubyte[]) read(name);
		ubyte[] compressed = compress(file_data, 9);
		b64ed = Base64.encode(compressed);
	// If the file is a symlink, return the name of the file it points to
	} else {
		version (Windows) {} else {
			b64ed = readLink(name);
		}
	}

	// Put the data into a Compressed File
	name = baseName(name);
	return CompressedFile(name, b64ed, is_symlink);
}

int run() {
	import std.file : getcwd, chdir, isFile, isDir, dirEntries, SpanMode;
	import std.string : format, replace, startsWith;
	import std.algorithm : map, filter;
	import std.array : array;
	import std.stdio : File;

	// Get a list of all the files to store
	string[] dirs_to_scan = [
		"lib",
	];

	// FIXME: Rather than storing all files in RAM, write them to disk one-by-one.
	// Copy all the data files to an array
	CompressedFile[] compressed_files;
	string cwd = getcwd();
	chdir("..");
	foreach (scan_entry ; dirs_to_scan) {
		if (isFile(scan_entry)) {
			stdout.writefln("Adding: %s", scan_entry);
			compressed_files ~= EntryToCompressedFile(scan_entry);
		} else if (isDir(scan_entry)) {
			string[] entries = dirEntries(scan_entry, SpanMode.depth)
				.map!(n => n.name) // Get the file names only
				.filter!(n => ! startsWith(n, ".")) // Filter out entries that start with .
				.filter!(n => isFile(n)) // Filter out non files
				.array();

			foreach (entry ; entries) {
				entry = replace(entry, `\`, "/");
				stdout.writefln("Adding: %s", entry);
				compressed_files ~= EntryToCompressedFile(entry);
			}
		}
	}
	chdir(cwd);

	// Write the array to a Go file as source code
	auto out_file = File("data.d", "wb");

	out_file.write("\r\nmodule data;\r\n");

	out_file.write("\r\nimport compressed_file : CompressedFile;\r\n");

	out_file.write("\r\n\r\n");
	//out_file.write(("const func GetArchivedData() ([]CompressedFile) {\r\n"));

	out_file.write("immutable CompressedFile[] compressed_files = [\r\n");
	foreach (entry ; compressed_files) {
		out_file.write("    {\r\n");
		out_file.write("        \"%s\",\r\n".format(entry.name));
		out_file.write("        \"%s\",\r\n".format(entry.data));
		out_file.write("        %s\r\n".format(entry.is_symlink));
		out_file.write("    },\r\n");
	}
	out_file.write("];\r\n");

	out_file.write("\r\n");

	out_file.write("\r\n");

	//out_file.write("}\r\n\r\n");

	// Close the file
	out_file.close();

	return 0;
}

int main() {
	import std.file : getcwd, chdir;
	chdir(getcwd());

	//stdout.writefln("!!! %s", getcwd());
	return run();
}