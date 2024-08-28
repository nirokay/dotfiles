import std/[os, strutils, strformat, terminal]

# Directories: ----------------------------------------------------------------

var
    pathHome: string
    pathRoot: string = "/"

if paramCount() < 1:
    styledEcho fgRed, "Please provide path to user home as $1 and optionally path to the root of the filesystem as $2"
    quit 2
else:
    pathHome = paramStr(1)
    if paramCount() >= 2: pathRoot = paramStr(2)

if not pathHome.dirExists() or pathHome == "":
    styledEcho fgRed, &"User directory '{pathHome}' does not exist."
    quit 1
if not pathRoot.dirExists() or pathRoot == "":
    styledEcho fgRed, &"Root directory '{pathRoot}' does not exist."
    quit 1


# Consent: --------------------------------------------------------------------

styledEcho fgDefault, &"User directory is set to ", fgYellow, pathHome, fgDefault
styledEcho fgDefault, &"Root directory is set to ", fgYellow, pathRoot, fgDefault

stdout.write "Please verify if those are correct [y/N] "
case getch():
    of 'Y', 'y':
        echo "\nContinuing..."
    of 'N', 'n':
        echo "\nAborting..."
        quit 1
    else:
        echo "\nUnclear input, aborting..."
        quit 1


# Start linking process: ------------------------------------------------------

const defaultIndent: int = 2

type Symlink* = object
    src*, dest*: string
proc newSymlink*(src, dest: string): Symlink = Symlink(
    src: src,
    dest: dest
)

proc `$`*(symlink: Symlink): string =
    result = &"'{symlink.src}' -> '{symlink.dest}'"

proc createSymlink*(symlink: Symlink, needsSudo: bool = false) = createSymlink(symlink.src, symlink.dest)
    #[
    let
        command: string = (if needsSudo: "sudo " else: "") & &"""ln "{symlink.src}" "{symlink.dest}" """
        status: int = execShellCmd(command)
    echo command
    if status != 0:
        raise OSError.newException("Failed to create file (missing permissions?)")
    ]#
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
                    styledEcho fgRed, &"{indentation}! [Error] Could not remove old symlink '{symlink.dest}' ({msg})", fgDefault
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


linkFilesInDirectory("home", pathHome, false) ## Files for `/*`
linkFilesInDirectory("root", pathRoot, true)  ## Files for `/home/$USER/*`

if failedSymlinks.len() != 0:
    styledEcho fgRed, "\nFailed to create these symlinks:", fgDefault
    echo " - " & failedSymlinks.join("\n - ")
