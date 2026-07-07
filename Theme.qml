pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Adjust this to wherever the generator actually writes the file.
    property string path: Quickshell.env("HOME") + "/.config/quickshell/theme.json"

    // --- raw parse -----------------------------------------------------
    // blockLoading keeps this simple/synchronous, which is fine for a
    // small config file read once (and re-read on change below).
    FileView {
        id: themeFile
        path: root.path
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    readonly property var data: {
        const raw = themeFile.text();
        if (!raw || raw.length === 0)
            return {};
        try {
            return JSON.parse(raw);
        } catch (e) {
            console.warn("Theme: failed to parse", root.path, e);
            return {};
        }
    }

    // --- resolved, mode-aware output ------------------------------------
    readonly property string mode: data.mode || "default"
    readonly property bool isDarkMode: !!data.is_dark_mode
    readonly property string wallpaper: data.image || ""

    // { name: { dark: {color}, default: {color}, light: {color} } }
    //   -> { name: "#rrggbb" } using the active mode (fallback: default)
    function resolveSection(section) {
        const out = {};
        if (!section)
            return out;
        for (const key in section) {
            const entry = section[key];
            const chosen = entry[root.mode] || entry["default"] || entry["dark"] || entry["light"];
            out[key] = chosen ? chosen.color : "#000000";
        }
        return out;
    }

    // Tonal palettes aren't mode-dependent (each ramp is a full 0-100 scale),
    // just strip the {color: ...} wrapper.
    function resolvePalette(palette) {
        const out = {};
        if (!palette)
            return out;
        for (const tone in palette)
            out[tone] = palette[tone].color;
        return out;
    }

    readonly property var base16: resolveSection(data.base16)
    readonly property var colors: resolveSection(data.colors)

    readonly property var palettes: {
        const out = {};
        const p = data.palettes || {};
        for (const name in p)
            out[name] = resolvePalette(p[name]);
        return out;
    }
}
