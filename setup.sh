#!/bin/bash

# dotfiles by abstractowl
# -----------------------
# Script to set up my dotfiles on a new computer. By running this file, you are
# agreeing that I cannot be held responsible if this script causes your computer
# to crash, become incredibly usable, catch fire, gain conscious will, or
# malfunction in any other way.

# Without further ado...

# Declare variables
can_install="y" # TRUE if not found

INSTALL_DIR=$HOME
LOCAL_DIR="./dot_files"

declare -a existing_files # Array used by files_exist()

# Target files we may overwrite
declare -a VIM_FILES
VIM=( ".vimrc" )
declare -a ZSH_FILES
ZSH=(".zshrc" ".zsh_aliases")
declare -a TMUX_FILES
TMUX=(".tmux.conf")

# Accepts an array of files ($1) and copies them from $LOCAL_DIR to $INSTALL_DIR
copy_files()
{
    local files_array=(${!1})
    for file in ${files_array[@]}
    do
        cp "$LOCAL_DIR/$file" "$INSTALL_DIR/$file"
    done
}

# Accepts an array of files ($1) and returns 1 if any of the files in the list
# exist. Otherwise, returns 0. Also adds existing files to the $existing_files
# array which is overwritten each time this function is run.
files_exist()
{
    local files_array=(${!1})
    existing_files=()

    for file in ${files_array[@]}
    do
        if [ -f "$INSTALL_DIR/$file" ]; then
            existing_files+=( $file );
        fi
    done

    if [ ${#existing_files[@]} = 0 ]; then
        return 0
    else
        return 1
    fi
}

prompt_overwrite()
{
    can_install="y" # Reset value

    echo '-- The following files already exist:'
    for existing_file in ${existing_files[@]}
    do
        echo "   * $existing_file"
    done

    read -p '-- Overwrite? [y/N] ' can_install

    echo
}

# Installs tmux dotfiles.
install_tmux()
{
    can_install="y" # Reset value
    files_exist TMUX[@]
    if [ $? = 1 ]; then
        prompt_overwrite
    fi

    if [ "$can_install" = "y" ]; then
        # Copy .vimrc over
        echo " -> Copying .tmux.conf to $INSTALL_DIR/.tmux.conf..."
        copy_files TMUX[@]
        # Add extra setup things later if needd

        # Done
        echo "-- Done!"
    else
        echo "Skipping tmux..."
    fi
}

# Installs vim dotfiles.
install_vim()
{
    can_install="y" # Reset value
    files_exist VIM[@]
    if [ $? = 1 ]; then
        prompt_overwrite
    fi

    if [ "$can_install" = "y" ]; then
        # Copy .vimrc over
        echo " -> Copying .vimrc to $INSTALL_DIR/.vimrc..."
        copy_files VIM[@]

        # Install Vundle
        if [ ! -f $INSTALL_DIR/.vim/bundle/vundle/README.md ]; then
            echo "-- Installing Vundle..."

            echo " -> Make Vundle directory"
            mkdir -p $INSTALL_DIR/.vim/bundle > /dev/null 2>&1

            echo " -> Clone GitHub repository"
            git clone https://github.com/gmarik/vundle \
                $INSTALL_DIR/.vim/bundle/vundle > /dev/null 2>&1
        fi

        # Auto install bundles
        echo "-- Installing bundles..."
        vim +BundleInstall +qall

        # Add extra setup things later if needed

        # Done
        echo "-- Done!"
    else
        echo "Skipping vim..."
    fi
}

# Installs zsh dotfiles.
install_zsh()
{
    local zsh_dir=`which zsh`
    can_install="y" # Reset value
    if [ "$zsh_dir" = "" ]; then
        echo "-- You do not have zsh installed."
        can_install="n"
    fi

    if [ "$can_install" = "y" ]; then
        files_exist ZSH[@]
        if [ $? = 1 ]; then
            prompt_overwrite
        fi
    fi

    if [ "$can_install" = "y" ]; then
        # Install oh-my-zsh
        if [ ! -d $INSTALL_DIR/.oh-my-zsh ]; then
            echo "-- Installing oh-my-zsh..."
            git clone https://github.com/robbyrussell/oh-my-zsh \
                $INSTALL_DIR/.oh-my-zsh > /dev/null 2>&1
        fi

        # Copy .zshrc over
        echo " -> Copying .zshrc to $INSTALL_DIR/.zshrc..."
        copy_files ZSH[@]

        echo "export PATH=\$PATH:$PATH" >> $INSTALL_DIR/.zshrc

        # Add in custom theme
        cp config/ember.zsh-theme ~/.oh-my-zsh/themes/

        echo " -> Changing default shell to zsh..."
        chsh -s `which zsh`

        # Add extra setup things later if needed

        # Done
        echo "-- Done!"
    else
        echo "Skipping zsh..."
    fi
}

# main program function
main()
{
    # Print welcome
    echo ".files - by abstractOwl. Enjoy!"
    echo

    install_tmux
    echo

    install_vim
    echo

    install_zsh
    echo

    echo "Done! You may have to restart your terminal for ZSH changes to " \
        "take effect."
}

main