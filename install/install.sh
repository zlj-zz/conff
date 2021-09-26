#!/usr/bin/env bash

# insure that script is completed
promise() {
    # color
    color_fg_red='\033[31m'
    color_fg_green='\033[32m'
    color_fg_blue='\033[34m'
    color_fg_aoi='\033[36m'
    color_end='\033[0m'

    # config constant
    repo_url='https://github.com/zlj-zz/dotconfig.git'
    config_name='.configrc'
    path_to_config_dir="$HOME/$config_name"
    backup_dir="$HOME/backup_`date +%Y-%m-%d_%H-%M-%S`"

    # requirement
    requirement="git"

    # red
    msg_red() {
        echo -en "${color_fg_red}$1${color_end}"
    }

    # green
    msg_green() {
        echo -en "${color_fg_green}$1${color_end}"
    }

    # aoi
    msg_aoi() {
        echo -en "${color_fg_aoi}$1${color_end}"
    }

    # blue
    msg_blue() {
        echo -en "${color_fg_blue}$1${color_end}"
    }

    # title
    msg_title() {
        echo -en "\n========"; msg_aoi " $1 "; echo "========"
    }

    # check for requirement
    check_required() {
        msg_aoi "check for requirement\n"
        idx=1
        for command in $requirement; do
            echo -en "${idx}. "; msg_blue $command

            if type $command > /dev/null 2>&1; then
                msg_green " √\n"
            else
                msg_red " ✘\n"
                msg_red "\n${command} is required\n"
                return 1
            fi
            ((idx++))
        done
        msg_aoi "check for requirement: "; msg_green "DONE\n"
        return 0
    }

    # create backup dir
    mkdir_backup() {
        echo -n "create backup dir: "; msg_aoi "${backup_dir}"
        if mkdir "${backup_dir}" > /dev/null 2>&1; then
            msg_green " √\n"
        else
            msg_red " ✘\n"
            exit 1
        fi
    }

    # clone git repo
    clone_repo() {
        msg_aoi "clone ${repo_url}\n"
        if git clone --recursive "${repo_url}" "${path_to_config_dir}"; then
            return 0
        fi
        return 1
    }

    check_repo() {
        echo -n "check "; msg_aoi "${path_to_config_dir}"
        if [ -e $path_to_config_dir ]; then
            msg_green " √\n"
            return 0
        else
            msg_red " ✘\n"
            if clone_repo; then
                return 0
            else
                return 1
            fi
        fi
    }

    # link
    mk_symlink() {
        if [ -e "$1" ]
        then
            # check dotfile is exists
            if [ -e $2 -o -L $2 ]; then
                # create backup dir if not exists
                if [ ! -d $backup_dir ]; then mkdir_backup; fi
                # backup dotfile
                echo -n "mv "; msg_aoi "${2}"; echo -n " to "; msg_aoi "${backup_dir} "
                if mv "$2" "$backup_dir/" > /dev/null 2>&1; then
                    msg_green "√\n"
                else
                    msg_red "✘\n"
                fi
            fi
            echo -n "link "; msg_aoi "${1}"; echo -n " to "; msg_aoi "${2}"
            if ln -s "$1" "$2" > /dev/null 2>&1; then
                msg_green " √\n"
            else
                msg_red " ✘\n"
            fi
        else
            echo -n "file "; msg_aoi "${1}"; msg_red " is not exists\n"
        fi
    }

    install_config() {
        msg_aoi "install config\n"
        local path_to_config="${path_to_config_dir}/config"
        ls "${path_to_config}" | while read item
        do
            mk_symlink "${path_to_config}/${item}" "${HOME}/.config/${item}"
        done
        msg_aoi "install config:"; msg_green " DONE\n"
    }

    install_neovim_config() {
        msg_aoi "install neovim config\n"
        local path_to_nvim="${HOME}/.config"
        echo -n "check "; msg_aoi "${path_to_nvim}"
        if [ -e $path_to_nvim ]
        then
            msg_green " √\n"
        else
            msg_red " ✘\n"
            echo -n "mkdir directory "; msg_aoi "${path_to_nvim}"
            if mkdir -p "${path_to_nvim}" > /dev/null 2>&1
            then
                msg_green " √\n"
            else
                msg_red " ✘\n"
                exit 1
            fi
        fi
        mk_symlink "${path_to_config_dir}/nvim" "${path_to_nvim}/nvim"
        msg_aoi "install neovim config:"; msg_green " DONE\n"
    }

    install_zsh_config() {
        `$HOME/.configrc/zsh/plugins.zsh`
        echo 'ok'
    }

    install_all() {
        check_required && check_repo && install_config && install_neovim_config && install_zsh_config
    }

    # show menu
    show_menu() {
        msg_title "INSTALL"
        echo "1) install neovim config"
        echo "2) install .config (include neovim)"
        echo "3) install zsh config"
        echo "4) install all (include .config neovim zsh)"
        echo -n "select: "
        read num
        case $num in
            1) check_required && check_repo && install_neovim_config ;;
            2) check_required && check_repo && install_config;;
            3) check_required && check_repo && install_zsh_config;;
            4) check_required && check_repo && install_all;;
            *) echo "Goodbye :)" ;;
        esac
    }

    show_menu
}

promise

# vim:set ft=sh:
