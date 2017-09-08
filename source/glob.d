/* Copyright (C) 1991-2016 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

string[] glob(string pattern)
{
    import std.string;
    string[] results;
    glob_t glob_result;
    glob(pattern.toStringz, 0, null, &glob_result);
    for (uint i = 0; i < glob_result.gl_pathc; i++)
    {
        results ~= glob_result.gl_pathv[i].fromStringz().idup;
    }

    globfree(&glob_result);
    return results;
}

import core.stdc.config;

extern (C):

enum _GLOB_H = 1;

/* We need `size_t' for the following definitions.  */
alias c_ulong __size_t;
alias c_ulong size_t;

/* The GNU CC stddef.h version defines __size_t as empty.  We need a real
   definition.  */

/* Bits set in the FLAGS argument to `glob'.  */
enum GLOB_ERR = 1 << 0; /* Return on read errors.  */
enum GLOB_MARK = 1 << 1; /* Append a slash to each name.  */
enum GLOB_NOSORT = 1 << 2; /* Don't sort the names.  */
enum GLOB_DOOFFS = 1 << 3; /* Insert PGLOB->gl_offs NULLs.  */
enum GLOB_NOCHECK = 1 << 4; /* If nothing matches, return the pattern.  */
enum GLOB_APPEND = 1 << 5; /* Append to results of a previous call.  */
enum GLOB_NOESCAPE = 1 << 6; /* Backslashes don't quote metacharacters.  */
enum GLOB_PERIOD = 1 << 7; /* Leading `.' can be matched by metachars.  */
enum GLOB_MAGCHAR = 1 << 8; /* Set in gl_flags if any metachars seen.  */
enum GLOB_ALTDIRFUNC = 1 << 9; /* Use gl_opendir et al functions.  */
enum GLOB_BRACE = 1 << 10; /* Expand "{a,b}" to "a" "b".  */
enum GLOB_NOMAGIC = 1 << 11; /* If no magic chars, return the pattern.  */
enum GLOB_TILDE = 1 << 12; /* Expand ~user and ~ to home directories. */
enum GLOB_ONLYDIR = 1 << 13; /* Match only directories.  */
enum GLOB_TILDE_CHECK = 1 << 14; /* Like GLOB_TILDE but return an error
                      if the user name is not available.  */
enum __GLOB_FLAGS = GLOB_ERR | GLOB_MARK | GLOB_NOSORT | GLOB_DOOFFS | GLOB_NOESCAPE | GLOB_NOCHECK | GLOB_APPEND | GLOB_PERIOD | GLOB_ALTDIRFUNC | GLOB_BRACE | GLOB_NOMAGIC | GLOB_TILDE | GLOB_ONLYDIR | GLOB_TILDE_CHECK;

/* Error returns from `glob'.  */
enum GLOB_NOSPACE = 1; /* Ran out of memory.  */
enum GLOB_ABORTED = 2; /* Read error.  */
enum GLOB_NOMATCH = 3; /* No matches found.  */
enum GLOB_NOSYS = 4; /* Not implemented.  */

/* Previous versions of this file defined GLOB_ABEND instead of
   GLOB_ABORTED.  Provide a compatibility definition here.  */

/* Structure describing a globbing run.  */

struct glob_t
{
    __size_t gl_pathc; /* Count of paths matched by the pattern.  */
    char** gl_pathv; /* List of matched pathnames.  */
    __size_t gl_offs; /* Slots to reserve in `gl_pathv'.  */
    int gl_flags; /* Set to FLAGS, maybe | GLOB_MAGCHAR.  */

    /* If the GLOB_ALTDIRFUNC flag is set, the following functions
       are used instead of the normal file access functions.  */
    void function (void*) gl_closedir;

    void* function (void*) gl_readdir;

    void* function (const(char)*) gl_opendir;

    int function (const(char)*, void*) gl_lstat;
    int function (const(char)*, void*) gl_stat;
}

/* If the GLOB_ALTDIRFUNC flag is set, the following functions
   are used instead of the normal file access functions.  */

/* Do glob searching for PATTERN, placing results in PGLOB.
   The bits defined above may be set in FLAGS.
   If a directory cannot be opened or read and ERRFUNC is not nil,
   it is called with the pathname that caused the error, and the
   `errno' value from the failing call; if it returns non-zero
   `glob' returns GLOB_ABEND; if it returns zero, the error is ignored.
   If memory cannot be allocated for PGLOB, GLOB_NOSPACE is returned.
   Otherwise, `glob' returns zero.  */

int glob (
    const(char)* __pattern,
    int __flags,
    int function (const(char)*, int) __errfunc,
    glob_t* __pglob);

/* Free storage allocated in PGLOB by a previous `glob' call.  */
void globfree (glob_t* __pglob);
