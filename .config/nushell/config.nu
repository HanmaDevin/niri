# config.nu
#
# Installed by:
# version = "0.110.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
$env.PATH = (
    $env.PATH | split row (char esep) | append [
        $"($env.HOME)/.local/bin"
        $"($env.HOME)/go/bin"
        $"($env.HOME)/.cargo/bin"
    ] | uniq
)
$env.VISUAL = "helix"
$env.EDITOR = "helix"
$env.FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
$env.FZF_CTRL_T_OPTS = "--preview 'bat -n --color=always --line-range :500 {}'"
$env.FZF_ALT_C_OPTS = "--walker-skip .git,node_modules,target --preview 'tree -C {}'"
$env.FZF_CTRL_R_OPTS = "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort' --color header:italic --header 'Press CTRL-Y to copy command into clipboard'"
$env.config.show_banner = false
alias gp = git pull
alias gclone = gh repo clone
alias repolist = gh repo list
alias hx = helix
alias la = ls -a
alias lg = lazygit
alias q = exit
alias v = nvim
alias vi = nvim
alias bat = bat -p -P --color=always --theme="Dracula"
alias anime = ani-cli --skip
alias remove = yay -Rnus
alias i = yay -S --needed
alias editmonitor = helix ~/.config/niri/monitors.kdl
alias editkeys = helix ~/.config/niri/keybinds.kdl
alias editkbd = helix ~/.config/niri/input.kdl
plugin add nu_plugin_gstat
plugin use gstat
fastfetch
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
def install [...pkgs: string] {
    if ($pkgs | is-empty) {
        let selection = (yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window 'down:65%:wrap' --bind 'alt-p:toggle-preview' --bind 'alt-b:change-preview:yay -Gpa {1} | tail -n +5')
        if ($selection | is-empty) { return }
        # Nushell handles lists natively
        echo $selection | xargs yay -S --noconfirm
    } else { yay -S --needed --noconfirm ...$pkgs }
}
def unpack [file: path, dest?: path] {
    let target = if ($dest == null) { $env.PWD } else { $dest }
    let ext = ($file | path parse).extension | str downcase
    match $ext {
        "zip" => { unzip $file -d $target }
        "gz" => { tar xvzf $file -C $target }
        "tar" => { tar xvf $file -C $target }
        "rar" => { rar x $file $target }
        _ => { print "Unsupported format" }
    }
}
def to-env [keys: list<string>, values: list<string>] {
    $keys | zip $values | each {|it| 
        $"($it.0)="($it.1)"" 
    } | save --append .env
}
source ./completions/gh-completions.nu
zoxide init --cmd cd nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu
