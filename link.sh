#!/usr/bin/env bash

shopt -s dotglob

function link_files_of_dir() {
    SEARCH_DIRECTORY=$1 # ./home/*
    TARGET_DIRECTORY=$2
    INDENT=$3
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
            echo -e "File '$DOTFILE' already exists ($(file "$DOTFILE"))"
            continue
        }

        # Linking fun:
        echo -e "$INDENT Creating symlink: $DOTFILE > ./$FILE"
        ln -S "$DOTFILE" "./$FILE"
    done
}

link_files_of_dir "home"   "$HOME" "-"
link_files_of_dir "config" "$HOME/.config"
