import std/[os, strutils, strformat]

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

    echo &"{indentation} '{src}' -> '{dest}'"

    # Walk over directory, link files, handle subdirectories later:
    for kind, path in walkDir(src, true):
        # Directory:
        if kind in [pcDir, pcLinkToDir]:
            dirs.add path
            continue
        # File:
        let symlink: Symlink = newSymlink(absolutePath(src / path), dest / path)
        echo &"{indentation}>\t Creating symlink: {symlink}"
        try:
            if symlink.dest.symlinkExists():
                try:
                    symlink.dest.removeFile()
                except OSError as e:
                    let msg: string = e.msg.replace("\n", " - ")
                    echo &"[Error] Could not remove file '{symlink.dest}' ({msg})"
            symlink.createSymlink()
        except OSError as e:
            let msg: string = e.msg.replace("\n", " - ")
            echo &"{indentation}! [Error] Could not create symlink: {symlink} ({msg})"
            failedSymlinks.add symlink

    # Subdirectories:
    for path in dirs:
        linkFilesInDirectory(src / path, dest / path, true, indent + defaultIndent)


linkFilesInDirectory("home", getHomeDir()) ## Files for `/*`
linkFilesInDirectory("root", "/", true)    ## Files for `/home/$USER/*`

if failedSymlinks.len() != 0:
    echo "\nFailed to create these symlinks:\n - " & failedSymlinks.join("\n - ")
