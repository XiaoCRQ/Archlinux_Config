function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

fish_vi_key_bindings
function fish_user_key_bindings
    # 在 insert 模式下绑定 'jk' 到 escape
    bind -M insert jj "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"
    # 在可视模式下，使用 y 复制到系统剪贴板
    bind -M visual y 'fish_clipboard_copy; commandline -f end-selection'

    # 在正常模式下，使用 p 从系统剪贴板粘贴
    bind -M default p fish_clipboard_paste
end

starship init fish | source
if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
end

alias pamcan pacman
alias ls 'eza --icons'
alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias q 'qs -c ii'

# function fish_prompt
#   set_color cyan; echo (pwd)
#   set_color green; echo '> '
# end
