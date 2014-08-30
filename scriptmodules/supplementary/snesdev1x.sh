rp_module_id="snesdev1x"
rp_module_desc="SNESDev for RetroPie GPIO-Adapter Version 1.X"
rp_module_menus="3+configure"

function sources_snesdev1x() {
    gitPullOrClone "$rootdir/supplementary/SNESDev-Rpi" git://github.com/petrockblog/SNESDev-RPi.git
}

function build_snesdev1x() {
    pushd "$rootdir/supplementary/SNESDev-Rpi"
    ADAPTERVER=ADAPTERVER1X make
    popd
}

function install_snesdev1x() {
    pushd "$rootdir/supplementary/SNESDev-Rpi"
    make install
    popd
}

function sup_checkInstallSNESDev1x() {
    if [[ ! -d "$rootdir/supplementary/SNESDev-Rpi" ]]; then
        sources_snesdev1x
        build_snesdev1x
        install_snesdev1x
    fi
}

# start SNESDev on boot and configure RetroArch input settings
function sup_enableSNESDevAtStart1x()
{
    clear
    printMsg "Enabling SNESDev on boot."

    case $1 in
      1)
        ensureKeyValueBootconfig "button_enabled" "0" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad1_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad2_enabled" "1" "/etc/snesdev.cfg"
        ;;
      2)
        ensureKeyValueBootconfig "button_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad1_enabled" "0" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad2_enabled" "0" "/etc/snesdev.cfg"
        ;;
      3)
        ensureKeyValueBootconfig "button_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad1_enabled" "1" "/etc/snesdev.cfg"
        ensureKeyValueBootconfig "gamepad2_enabled" "1" "/etc/snesdev.cfg"
        ;;
      *)
        echo "[sup_enableSNESDevAtStart] I do not understand what is going on here."
        ;;
    esac

}

function configure_snesdev1x() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable SNESDev on boot and SNESDev keyboard mapping."
             2 "Enable SNESDev on boot and SNESDev keyboard mapping (polling pads and button)."
             3 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only pads)."
             4 "Enable SNESDev on boot and SNESDev keyboard mapping (polling only button).")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [ "$choices" != "" ]; then
        case $choices in
            1) sup_checkInstallSNESDev1x
               pushd "$rootdir/supplementary/SNESDev-Rpi/"
               make uninstallservice
               popd
               dialog --backtitle "$__backtitle" --msgbox "Disabled SNESDev on boot." 22 76
                            ;;
            2) sup_checkInstallSNESDev1x
               sup_enableSNESDevAtStart1x 3
               pushd "$rootdir/supplementary/SNESDev-Rpi/"
               make installservice
               popd
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling pads and button)." 22 76
                            ;;
            3) sup_checkInstallSNESDev1x
               sup_enableSNESDevAtStart1x 1
               pushd "$rootdir/supplementary/SNESDev-Rpi/"
               make installservice
               popd
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling only pads)." 22 76
                            ;;
            4) sup_checkInstallSNESDev1x
               sup_enableSNESDevAtStart1x 2
               pushd "$rootdir/supplementary/SNESDev-Rpi/"
               make installservice
               popd
               dialog --backtitle "$__backtitle" --msgbox "Enabled SNESDev on boot (polling only button)." 22 76
                            ;;
        esac
    else
        break
    fi
}