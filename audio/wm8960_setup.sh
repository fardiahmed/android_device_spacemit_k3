#!/vendor/bin/sh
# WM8960 Audio HAT (BPI-SM10): enable the DAPM output-mixer and mic-boost
# switches, which default off, once the card is up. The card is found by name;
# the control values are the standard WM8960 enable and are worth checking on
# the real board (levels, and whether both mics or just one are wired).
c=""
while read idx rest; do
    case "$rest" in
        *wm8960*) c="$idx"; break;;
    esac
done < /proc/asound/cards
[ -z "$c" ] && exit 0
tm() { /vendor/bin/tinymix2 -D "$c" "$1" "$2" >/dev/null 2>&1; }

# Playback: DAC -> output mixer -> headphone / speaker
tm 'Left Output Mixer PCM Playback Switch' 1
tm 'Right Output Mixer PCM Playback Switch' 1
tm 'Playback Volume' 255
tm 'Headphone Playback Volume' 120
tm 'Speaker Playback Volume' 127

# Capture: LINPUT1 / RINPUT1 -> boost -> input mixer -> ADC
tm 'Left Boost Mixer LINPUT1 Switch' 1
tm 'Right Boost Mixer RINPUT1 Switch' 1
tm 'Left Input Mixer Boost Switch' 1
tm 'Right Input Mixer Boost Switch' 1
tm 'Capture Volume' 60
tm 'ADC PCM Capture Volume' 195
tm 'Capture Switch' 1
