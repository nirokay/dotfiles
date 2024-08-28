import std/[os, strutils, strformat, terminal]

const defaultIndent: int = 2

type Symlink* = object
    src*, dest*: string
proc `$`*(symlink: Symlink): string =
    result = &"'{symlink.src}' -> '{symlink.dest}'"
proc newSymlink*(src, dest: string): Symlink = Symlink(
    src: src,
    dest: dest
)
proc createSymlink*(symlink: Symlink) = createSymlink(symlink.src, symlink.dest)
proc symlinkExists*(symlink: Symlink): bool = symlinkExists(symlink.dest)

var failedSymlinks: seq[Symlink]

proc linkFilesInDirectory*(src: string, dest: string, sudoPrivileges: bool = false, indent: int = defaultIndent) =
    let indentation: string = repeat('-', indent)
    var dirs: seq[string]

    styledEcho fgYellow, &"{indentation}/ '{src}' -> '{dest}'", fgDefault
    if not dest.dirExists():
        try:
            styledEcho fgGreen, &"{indentation}/ Creating directory '{dest}'", fgDefault
            dest.createDir()
        except OSError as e:
            let msg: string = e.msg.replace("\n", " - ")
            styledEcho fgRed, &"{indentation}! [Error] Could not create directory: {src} ({msg})", fgDefault

    # Walk over directory, link files, handle subdirectories later:
    for kind, path in walkDir(src, true):
        # Directory:
        if kind in [pcDir, pcLinkToDir]:
            dirs.add path
            continue
        # File:
        let symlink: Symlink = newSymlink(absolutePath(src / path), dest / path)
        stdout.styledWrite fgDefault, &"{indentation}> Creating symlink: {symlink}", fgDefault
        try:
            # Remove old symlink, if exists:
            if symlink.dest.symlinkExists():
                try:
                    styledEcho fgMagenta, " [Replaing old symlink]", fgDefault
                    symlink.dest.removeFile()
                except OSError as e:
                    let msg: string = e.msg.replace("\n", " - ")
                    styledEcho fgRed, &"\n{indentation}! [Error] Could not remove old symlink '{symlink.dest}' ({msg})", fgDefault
            else:
                styledEcho fgCyan, " [Creating new symlink]", fgDefault
            # Create symlink:
            symlink.createSymlink()
        except OSError as e:
            let msg: string = e.msg.replace("\n", " - ")
            styledEcho fgRed, &"{indentation}! [Error] Could not create symlink: {symlink} ({msg})", fgDefault
            failedSymlinks.add symlink

    # Subdirectories:
    for path in dirs:
        linkFilesInDirectory(src / path, dest / path, true, indent + defaultIndent)


linkFilesInDirectory("home", getHomeDir()) ## Files for `/*`
linkFilesInDirectory("root", "/", true)    ## Files for `/home/$USER/*`

if failedSymlinks.len() != 0:
    styledEcho fgRed, "\nFailed to create these symlinks:", fgDefault
    echo " - " & failedSymlinks.join("\n - ")
