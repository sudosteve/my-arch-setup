# my-arch-setup

Easy install, from Arch ISO:

    curl -LO tinyurl.com/stevearchinstall
    sh stevearchinstall

Run `./checklists.sh` to compare pacmanlist.txt / aurlist.txt against the explicitly installed packages (`--no-aur` skips the AUR lookup). Packages in hardware_specific_packages.txt are ignored. These lists are the only copy; the dotfiles repo no longer has its own.
