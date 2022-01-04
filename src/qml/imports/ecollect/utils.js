.pragma library

function mapVolumeValueToIcon(value) {
    if (value > 0.75)
        return "\u{f057E}";
    else if (value > 0.25)
        return "\u{f0580}";
    else if (value > 0)
        return "\u{f057F}";
    else
        return "\u{f075F}";
}
