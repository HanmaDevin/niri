#!/usr/bin/env bash

packages=("sddm" "niri" "qt5-wayland" "qt6-wayland" "qt5-quickcontrols" "qt5-quckcontrols2" "qt5-graphicaleffects" "grim" "slurp" "satty" "gnome-system-monitor" "nwg-look" "impression" "showtime" "papers" "loupe" "nautilus" "noctalia-shell" "qt5ct-kde" "qt6ct-kde" "gpu-screen-recorder" "gradia")

for pkg in "${packages[@]}"; do
  yay -Rns --noconfirm "${pkg}"
done
