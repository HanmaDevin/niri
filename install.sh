#!/usr/bin/env bash
#     ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

REPO="${HOME}/niri"
CFG_PATH="${REPO}/.config"

installDevTools() {
  local packages=("nodejs" "gcc" "npm" "make" "git-delta" "debugedit" "fakeroot" "lazygit" "jdk21-openjdk" "docker" "rustup" "gdb" "cmake" "meson" "pkg-config" "github-cli" "automake")
  sudo pacman -S --needed --noconfirm "${packages[@]}"

  local formatter=("stylua" "prettier" "beautysh" "python-black" "gofumpt" "clang-format-all-git" "dockerfmt" "yamlfmt" "google-java-format-git")
  local servers=("rust-analyzer" "jdtls" "bash-language-server" "docker-ls" "hyprls-git" "jedi-language-server" "vscode-css-languageserver" "vscode-html-languageserver" "gopls" "gradle-language-server" "texlab" "yaml-language-server" "vscode-json-languageserver" "marksman")

  yay -S --needed --noconfirm "${formatter[@]}" "${servers[@]}"
  rustup default stable
}

installExtensions() {
  if ! command -v codium >/dev/null 2>&1; then
    return 1
  fi

  while read -r x; do
    codium --install-extension "${x}"
  done <"${REPO}/extensions.txt"
}

installNiri() {
  local packages=("niri" "gnome-system-monitor" "nushell" "swayidle" "libreoffice" "mpv-mpris" "bluez" "bluez-utils" "networkmanager" "brightnessctl" "wine" "bluez-obex" "sddm" "qt6-svg" "qt6-virtualkeyboard" "qt6-multimedia-ffmpeg" "network-manager-applet" "networkmanager-openvpn" "ufw" "grub" "os-prober" "kitty" "ntfs-3g" "reflector" "polkit-gnome" "btop" "plymouth" "gamemode" "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "ttf-font-awesome" "ttf-nerd-fonts-symbols" "ttf-jetbrains-mono-nerd" "noto-fonts-emoji" "wireplumber" "libfido2" "qt5-wayland" "qt6-wayland" "gamescope" "pam-u2f" "gnome-keyring" "xdg-desktop-portal-gtk" "nm-connection-editor" "wlsunset" "cliphist" "cava" "wl-clipboard" "xdg-desktop-portal-wlr" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects" "pacman-contrib" "libimobiledevice" "usbmuxd" "gvfs-gphoto2" "ifuse" "grim" "slurp" "steam" "helix" "satty" "adw-gtk-theme" "file-roller" "vulkan-headers" "nautilus" "papers" "loupe" "showtime" "impression" "power-profiles-daemon" "linux-headers" "texlive")
  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

installTerminalTools() {
  sudo pacman -Syu

  local packages=("zip" "unzip" "man" "fastfetch" "glow" "tree" "wget" "eza" "zoxide" "fzf" "bat" "ripgrep" "fd" "starship" "python-pip" "python-requests" "python-pipx" "openssh" "python-dotenv" "openvpn" "ncdu" "inetutils" "net-tools" "jq" "tealdeer" "wireguard-tools" "ffmpeg4.4" "cpio")
  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

installAurPackages() {
  local packages=("nb" "gpu-screen-recorder" "noctalia-shell" "spotify" "brave-bin" "vscodium-bin" "xpadneo-dkms" "nwg-look" "openvpn3" "xwayland-satellite" "localsend-bin" "qt6ct-kde" "qt5ct-kde" "pinta" "lazydocker" "ufw-docker" "qt-heif-image-plugin" "tte" "luajit-tiktoken-bin" "ani-cli" "ani-skip-git" "vesktop" "proton-vpn-gtk-app")
  yay -S --needed --noconfirm "${packages[@]}"
}

setup_firewall() {
  gum spin --spinner dot --title "Firewall Setup..." -- sleep 2
  # Allow nothing in, everything out
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  # Allow ports for LocalSend
  sudo ufw allow 53317/udp
  sudo ufw allow 53317/tcp

  sudo ufw allow KDEConnect

  # Allow Docker containers to use DNS on host
  sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'

  # Turn on the firewall
  sudo ufw --force enable

  # Enable UFW systemd service to start on boot
  sudo systemctl enable ufw

  # Turn on Docker protections
  sudo ufw-docker install
  sudo ufw reload
}

installYay() {
  if ! command -v yay >/dev/null 2>&1; then
    cwd=$(pwd)
    echo ">>> Installing yay..."
    git clone https://aur.archlinux.org/yay.git "${HOME}/yay"
    cd "${HOME}/yay"
    makepkg -si
    cd "${cwd}"
  fi
}

installDeepCoolDriver() {
  if gum confirm ">>> Do you want to install DeepCool CPU-Fan driver?"; then
    sudo cp "${REPO}/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "${REPO}/DeepCool/deepcool-digital.service" "/etc/systemd/system"
    sudo systemctl enable deepcool-digital
  fi
}

configure_git() {
  local name email
  if gum confirm ">>> Want to configure git?"; then
    name=$(gum input --prompt ">>> What is your user name? ")
    git config --global user.name "${name}"
    email=$(gum input --prompt ">>> What is your email? ")
    git config --global user.email "${email}"
    git config --global pull.rebase true
  fi

  git config --global core.pager 'delta -n'
  git config --global interactive.diffFilter 'delta --color-only -n'
  git config --global delta.navigate true
  git config --global merge.conflictStyle zdiff3

  if gum confirm ">>> Want to create a ssh-key?"; then
    ssh-keygen -t ed25519 -C "${email}"
  fi
}

set_shell() {
  local shell
  shell=$(gum choose "Nu" "Zsh" "Fish")
  case "${shell,,}" in
    "zsh")
      sudo pacman -S --needed --noconfirm "zsh"
      ;;
    "fish")
      sudo pacman -S --needed --noconfirm "fish"
      ;;
  esac

  echo ">>> Trying to change the shell to: ${shell,,}"
  chsh -s "/usr/bin/${shell,,}"
}

detect_nvidia() {
  local gpu
  gpu=$(lspci | grep -i '.* vga .* nvidia .*')

  shopt -s nocasematch

  if [[ ${gpu} == *' nvidia '* ]]; then
    echo ">>> Nvidia GPU is present"
    gum spin --spinner dot --title "Installaling nvidia drivers now..." -- sleep 2
    sudo pacman -S --needed --noconfirm nvidia-open nvidia-utils nvidia-settings
  fi
}

get_wallpaper() {
  if gum confirm ">>> Do you want to download cool wallpaper?"; then
    if [ ! -d "${HOME}/Pictures/Wallpapers" ]; then
      mkdir -p "${HOME}/Pictures/Wallpapers"
    fi
    git clone "https://github.com/HanmaDevin/Wallpapes.git" "${HOME}/Wallpapes"
    cp ~/Wallpapes/* "${HOME}/Pictures/Wallpapers"
    rm -rf "${HOME}/Wallpapes"
    rm -rf "${HOME}/Pictures/Wallpapers/.git"
  fi
}

copy_config() {
  gum spin --spinner dot --title "Creating Home..." -- sleep 2
  mkdir -p "${HOME}/Desktop"
  mkdir -p "${HOME}/Downloads"
  mkdir -p "${HOME}/Pictures"
  mkdir -p "${HOME}/Videos"

  if [[ ! -d "${HOME}/Pictures/Screenshots" ]]; then
    mkdir -p "${HOME}/Pictures/Screenshots"
  fi

  cp "${REPO}/.zshrc" "${HOME}"
  cp "${REPO}/.zoxide.nu" "${HOME}"
  cp -r "${CFG_PATH}" "${HOME}"
  get_wallpaper
  cp "${REPO}/.face" "${HOME}"

  sudo cp -r "${REPO}/fonts" "/usr/share"
  sudo cp "${REPO}/etc/pacman.conf" "/etc/pacman.conf"
  sudo cp -r "${REPO}/plymouth/arch-mac-style" "/usr/share/plymouth/themes"
  sudo cp -r "${REPO}/grub/Stylish-4k" "/boot/grub/themes"
  sudo cp "${REPO}/etc/default/grub" "/etc/default"
  sudo plymouth-set-default-theme -R "arch-mac-style"
  sudo grub-mkconfig -o "/boot/grub/grub.cfg"
  sudo cp -r "${REPO}/bin" "/usr"
  sudo cp -r "${REPO}/etc/xdg" "/etc"
  sudo cp -r "${REPO}/icons" "/usr/share"
  sudo cp -r "${REPO}/sddm/sddm-astronaut-theme" "/usr/share/sddm/themes"
  sudo cp -r "${REPO}/sddm/sddm.conf" "/etc"

  set_shell
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "HanmaDevin Niri Setup"
echo -e "${NONE}"
ans=$(echo -en "[1] Install Niri\n[2] Install Packages\n[3] Apply Configurations\n[4] Exit" | gum table -c "What do you wish to do?")
case ${ans} in
  *1*)
    echo ">>> Installation started."
    echo ">>> Updating System..."
    sudo pacman -Syu

    if ! command -v gum >/dev/null 2>&1; then
      sudo pacman -S --noconfirm gum
    fi

    echo ">>> Installing required packages..."
    installNiri
    installTerminalTools
    installYay
    installDevTools
    installAurPackages
    copy_config
    installExtensions
    detect_nvidia
    installDeepCoolDriver
    configure_git
    setup_firewall
    "${REPO}/setup-fingerprint"

    sudo systemctl enable sddm
    sudo systemctl enable reflector
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    sudo systemctl enable power-profiles-daemon
    ;;
  *2*)
    installNiri
    installAurPackages
    ;;
  *3*)
    copy_config
    ;;
  *4*)
    exit 0
    ;;
esac

clear
echo -e "${MAGENTA}"
cat <<"EOF"
    ____       __                __
   / __ \___  / /_  ____  ____  / /_
  / /_/ / _ \/ __ \/ __ \/ __ \/ __/
 / _, _/  __/ /_/ / /_/ / /_/ / /_
/_/ |_|\___/_.___/\____/\____/\__/
EOF
echo "and thank you for choosing Hyprdev :)"
echo -e "${NONE}"

if gum confirm "Reboot System?"; then
  clear
  sudo systemctl reboot
else
  clear
  exit 0
fi
