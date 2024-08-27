#!/usr/bin/env bash

shopt -s dotglob
FAILED_LIST=()

function link_files_of_dir() {
    SEARCH_DIRECTORY=$1 # ./home/*
    TARGET_DIRECTORY=$2
    INDENT=$3
    [ -z "$INDENT" ] && INDENT="-"
    echo -e "Linking files in '$SEARCH_DIRECTORY' to '$TARGET_DIRECTORY'!"
    [ ! -d "$SEARCH_DIRECTORY" ] && {
        echo -e "Creating directory '$SEARCH_DIRECTORY'"
        mkdir "$SEARCH_DIRECTORY" || echo -e "Failed to create directory '$SEARCH_DIRECTORY'"
    }
    for FILE in "$SEARCH_DIRECTORY"/**; do
        # Recursion:
        [ -d "$FILE" ] && link_files_of_dir "$FILE" "$TARGET_DIRECTORY/$(basename "$FILE")" "$INDENT-"

        # Avoid empty directories:
        [[ "$FILE" == *"*" ]] && {
            echo -e "Empty directory $FILE"
            continue
        }
        DOTFILE="$TARGET_DIRECTORY/$(basename "$FILE")"

        # Existing target:
        [ -d "$DOTFILE" ] && {
            echo -e "Directory with name '$DOTFILE' exists, cannot create symlink)"
            continue
        }
        [ -f "$DOTFILE" ] && {
            #echo -e "File '$DOTFILE' already exists ($(file "$DOTFILE"))"
            if test -L "$DOTFILE"; then
                #echo -e "Removing symlink '$DOTFILE'"
                if ! mv "$DOTFILE" "$HOME/.local/share/Trash/files/$(basename "$DOTFILE")_deleted_by_dotfiles"; then
                    rm "$DOTFILE"
                fi
            else
                FAILED_LIST+=( "$FILE" )
                continue
            fi
        }

        # Linking fun:
        echo -e "$INDENT Creating symlink: '$DOTFILE' -> '$FILE'"
        ln -s "$FILE" "$DOTFILE"
    done
}

PWD=$(pwd)

link_files_of_dir "$PWD/home"   "$HOME"
link_files_of_dir "$PWD/config" "$HOME/.config"

[ -n "${FAILED_LIST[*]}" ] && echo -e "\nFailed to link these files:\n${FAILED_LIST[*]}"
