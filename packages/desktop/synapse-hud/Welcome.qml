// SynapseOS — Cyberdeck Onboarding Gate (Qt6 / Material You Cockpit)
// Designed to identically match Command HUD (synapse-hud/Main.qml) and SDDM (synapse-greeter)
// Frameless chamfered obsidian glass cockpit, dual traveling white-hot light trails,
// authentic 3D liquid chrome master logo with ambient breathing Mauve glow,
// and unified 4-quadrant interactive cyberdeck dashboard.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Effects

Window {
    id: root
    width: 960
    height: 640
    visible: true
    title: "SynapseOS // Cyberdeck Onboarding Gate"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Dialog
    color: "transparent"

    readonly property var accents: ({
        mauve: "#cba6f7", tungsten: "#fab387", crimson: "#f38ba8",
        sapphire: "#74c7ec", emerald: "#a6e3a1"
    })
    property string variant: (typeof backend !== "undefined" && backend && backend.selectedWallpaper) ? backend.selectedWallpaper : "monolith-mauve"
    readonly property color accent: accents[variant.split("-").pop()] || accents.mauve
    readonly property color surface: "#181825"
    readonly property color surfaceContainer: "#1e1e2e"
    readonly property color textMain: "#cdd6f4"
    readonly property color textSub: "#a6adc8"
    readonly property color textMuted: "#6c7086"
    readonly property color borderMuted: "#313244"
    readonly property string mono: "JetBrainsMono Nerd Font"

    readonly property string backendOperator: (typeof backend !== "undefined" && backend && backend.operator) ? backend.operator : "operator"
    readonly property string backendHostname: (typeof backend !== "undefined" && backend && backend.hostname) ? backend.hostname : "synapse-deck"
    readonly property string backendAiEngine: (typeof backend !== "undefined" && backend && backend.selectedAiEngine) ? backend.selectedAiEngine : "claude"
    readonly property string backendIconTheme: (typeof backend !== "undefined" && backend && backend.selectedIconTheme) ? backend.selectedIconTheme : "Synapse-Liquid-Chrome"
    readonly property var backendCombos: (typeof backend !== "undefined" && backend && backend.combos) ? backend.combos : ({})
    readonly property string chromeLogoPath: (typeof backend !== "undefined" && backend && backend.chromeLogoPath) ? backend.chromeLogoPath : ""
    readonly property string claudeKey: (typeof backend !== "undefined" && backend && backend.claudeApiKey) ? backend.claudeApiKey : ""

    property bool showClaudeKey: false

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    FocusScope {
        id: panel
        anchors.fill: parent
        anchors.margins: 12
        focus: true
        readonly property real c: 18

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (typeof backend !== "undefined" && backend) {
                    backend.applyAndFinish()
                } else {
                    root.close()
                }
                event.accepted = true
            }
        }

        // Drop shadow / glow border
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent"
            border.color: root.accent
            border.width: 1
            opacity: 0.35
            radius: panel.c + 2
        }

        // Chamfered Obsidian Glass Slab (Identical to synapse-hud)
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 1.5
                strokeColor: root.borderMuted
                fillColor: Qt.rgba(13 / 255, 14 / 255, 21 / 255, 0.96)
                startX: panel.c; startY: 0
                PathLine { x: panel.width - panel.c; y: 0 }
                PathLine { x: panel.width; y: panel.c }
                PathLine { x: panel.width; y: panel.height - panel.c }
                PathLine { x: panel.width - panel.c; y: panel.height }
                PathLine { x: panel.c; y: panel.height }
                PathLine { x: 0; y: panel.height - panel.c }
                PathLine { x: 0; y: panel.c }
                PathLine { x: panel.c; y: 0 }
            }
        }

        // Animated Travelling Border Trails
        Shape {
            id: trails
            anchors.fill: parent
            readonly property real perim: 2 * (panel.width + panel.height)
            property real offset: 0
            NumberAnimation on offset {
                loops: Animation.Infinite
                from: trails.perim; to: 0
                duration: 6500
            }
            ShapePath {
                strokeColor: root.accent
                strokeWidth: 2
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [12, 120]
                dashOffset: trails.offset
                startX: panel.c; startY: 0
                PathLine { x: panel.width - panel.c; y: 0 }
                PathLine { x: panel.width; y: panel.c }
                PathLine { x: panel.width; y: panel.height - panel.c }
                PathLine { x: panel.width - panel.c; y: panel.height }
                PathLine { x: panel.c; y: panel.height }
                PathLine { x: 0; y: panel.height - panel.c }
                PathLine { x: 0; y: panel.c }
                PathLine { x: panel.c; y: 0 }
            }
        }

        // Interior Content Column
        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // ================================================================
            // 1. HEADER ROW: LOGO, TITLE, METADATA & CLOSE BUTTON
            // ================================================================
            Item {
                width: parent.width
                height: 44

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    // Authentic 3D Liquid Chrome Master Logo
                    Item {
                        width: 40; height: 40
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 44; height: 44; radius: 22
                            color: root.withAlpha(root.accent, 0.18)
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                PropertyAnimation { to: 0.8; duration: 2200; easing.type: Easing.InOutSine }
                                PropertyAnimation { to: 0.2; duration: 2200; easing.type: Easing.InOutSine }
                            }
                        }

                        Image {
                            id: chromeLogo
                            anchors.fill: parent
                            source: root.chromeLogoPath ? "file://" + root.chromeLogoPath : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true; mipmap: true
                            visible: status === Image.Ready
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 32; height: 32; radius: 6
                            color: "#141422"; border.color: root.accent; border.width: 1.5
                            visible: !chromeLogo.visible
                            Text { anchors.centerIn: parent; text: "SY"; color: root.accent; font.family: root.mono; font.pixelSize: 13; font.bold: true }
                        }
                    }

                    // Title Readout
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Row {
                            spacing: 8
                            Text {
                                text: "󰚩 SYNAPSE // CYBERDECK ONBOARDING GATE"
                                color: root.accent
                                font.family: root.mono; font.pixelSize: 13; font.bold: true; font.letterSpacing: 1.2
                            }
                            Rectangle {
                                height: 16; width: 62; radius: 3; color: "#08080d"; border.color: root.accent
                                Text { anchors.centerIn: parent; text: "v1.0.0-PROT"; color: root.accent; font.family: root.mono; font.pixelSize: 8; font.bold: true }
                            }
                        }
                        Text {
                            text: "OPERATOR: " + root.backendOperator + "  ·  NODE: " + root.backendHostname + "  ·  KERNEL: ARCH 6.13+ BORE ZEN"
                            color: root.textSub
                            font.family: root.mono; font.pixelSize: 10
                        }
                    }
                }

                // Header Right: Controls
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "[Esc] Enter Desktop"
                        color: "#6c7086"
                        font.family: root.mono; font.pixelSize: 10
                    }

                    Rectangle {
                        width: 26; height: 26; radius: 6
                        color: closeMouse.containsMouse ? "#f38ba8" : "#313244"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: closeMouse.containsMouse ? "#11111b" : "#cdd6f4"
                            font.family: root.mono; font.pixelSize: 11; font.bold: true
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof backend !== "undefined" && backend) {
                                    backend.applyAndFinish()
                                } else {
                                    root.close()
                                }
                            }
                        }
                    }
                }
            }

            // Divider Line
            Rectangle {
                width: parent.width; height: 1
                color: root.withAlpha(root.accent, 0.35)
            }

            // ================================================================
            // 2. UNIFIED CYBERDECK COCKPIT DASHBOARD (2x2 CATEGORY GRID)
            // ================================================================
            Grid {
                width: parent.width
                columns: 2
                spacing: 12

                // ------------------------------------------------------------
                // QUADRANT 1: 🧠 AI NEURAL COPILOT
                // ------------------------------------------------------------
                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 236
                    radius: 12
                    color: root.surface
                    border.color: root.borderMuted
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Row {
                            spacing: 6
                            Text { text: "🧠 AI NEURAL COPILOT"; color: root.accent; font.family: root.mono; font.pixelSize: 11; font.bold: true; font.letterSpacing: 0.8 }
                        }
                        Rectangle { width: parent.width; height: 1; color: root.withAlpha(root.accent, 0.3) }

                        // 3 AI Engine Option Rows
                        readonly property var aiEngines: [
                            { id: "claude",   title: "Anthropic Claude 3.7", desc: "Frontier Extended Reasoning Copilot", col: "#cba6f7", badge: "RECOMMENDED" },
                            { id: "ollama",   title: "Ollama Local (11434)", desc: "100% Offline Qwen 2.5 Coder Abliterated", col: "#a6e3a1", badge: "SOVEREIGN" },
                            { id: "deepseek", title: "DeepSeek R1 / API",    desc: "Open Reasoning API Endpoint", col: "#74c7ec", badge: "FLEXIBLE" }
                        ]

                        Repeater {
                            model: parent.aiEngines
                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 38
                                radius: 8

                                readonly property bool isSelected: root.backendAiEngine === modelData.id
                                color: isSelected ? root.surfaceContainer : (rowMouse.containsMouse ? "#202030" : "#11111b")
                                border.color: isSelected ? modelData.col : root.borderMuted
                                border.width: isSelected ? 1.5 : 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Rectangle {
                                        width: 12; height: 12; radius: 6
                                        color: isSelected ? modelData.col : "transparent"
                                        border.color: modelData.col; border.width: 1.5
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1
                                        width: parent.width - 90
                                        Text { text: modelData.title; color: isSelected ? "#ffffff" : root.textMain; font.family: root.mono; font.pixelSize: 10; font.bold: true }
                                        Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 8; elide: Text.ElideRight; width: parent.width }
                                    }

                                    Rectangle {
                                        width: 62; height: 16; radius: 3; color: "#06060a"
                                        border.color: isSelected ? modelData.col : root.borderMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: modelData.badge; color: isSelected ? modelData.col : root.textMuted; font.family: root.mono; font.pixelSize: 7; font.bold: true }
                                    }
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.selectedAiEngine = modelData.id
                                }
                            }
                        }

                        // API Token Input Box
                        Rectangle {
                            width: parent.width
                            height: 34
                            radius: 6
                            color: "#11111b"
                            border.color: root.borderMuted

                            Row {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 6

                                Text { text: "TOKEN:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }

                                TextInput {
                                    id: tokenInput
                                    width: parent.width - 110
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.claudeKey
                                    color: "#ffffff"
                                    echoMode: root.showClaudeKey ? TextInput.Normal : TextInput.Password
                                    font.family: root.mono; font.pixelSize: 10
                                    selectByMouse: true
                                    selectionColor: root.accent
                                    onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeApiKey = text

                                    Text {
                                        text: "Optional sk-ant / API Key..."
                                        color: "#585b70"
                                        font: tokenInput.font
                                        visible: !tokenInput.text
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle {
                                    width: 48; height: 22; radius: 4; color: "#1e1e2e"; border.color: root.borderMuted
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: root.showClaudeKey ? "HIDE" : "SHOW"; color: root.textSub; font.family: root.mono; font.pixelSize: 8; font.bold: true }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showClaudeKey = !root.showClaudeKey }
                                }
                            }
                        }
                    }
                }

                // ------------------------------------------------------------
                // QUADRANT 2: 🎨 VISUAL THEME & WALLPAPER (SECTION 5 RESOLVED)
                // ------------------------------------------------------------
                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 236
                    radius: 12
                    color: root.surface
                    border.color: root.borderMuted
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Row {
                            spacing: 6
                            Text { text: "🎨 VISUAL THEME & ACCENT PALETTE"; color: "#fab387"; font.family: root.mono; font.pixelSize: 11; font.bold: true; font.letterSpacing: 0.8 }
                        }
                        Rectangle { width: parent.width; height: 1; color: Qt.rgba(250/255, 179/255, 135/255, 0.3) }

                        // 7 Wallpapers Grid - Instant Live Accent Color Shift
                        Grid {
                            id: themeGrid
                            width: parent.width
                            columns: 2
                            spacing: 6

                            readonly property var wallpapers: [
                                { id: "monolith-mauve",    name: "Monolith · Mauve",   col: "#cba6f7", desc: "Default Violet" },
                                { id: "tower-mauve",       name: "Basalt Tower",       col: "#cba6f7", desc: "Cyberdeck Pillars" },
                                { id: "carbon-mauve",      name: "Forged Carbon",      col: "#cba6f7", desc: "Stealth Weave" },
                                { id: "monolith-tungsten", name: "Warm Tungsten",      col: "#fab387", desc: "Industrial Gold" },
                                { id: "carbon-crimson",    name: "Stealth Crimson",    col: "#f38ba8", desc: "High Contrast" },
                                { id: "monolith-sapphire", name: "Cold Sapphire",      col: "#74c7ec", desc: "Aerospace Blue" },
                                { id: "monolith-emerald",  name: "Matrix Emerald",     col: "#a6e3a1", desc: "Terminal Phosphor" }
                            ]

                            Repeater {
                                model: themeGrid.wallpapers
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (themeGrid.width - 6) / 2
                                    height: 34
                                    radius: 6

                                    readonly property bool isSelected: root.variant === modelData.id
                                    color: isSelected ? root.surfaceContainer : (wallMouse.containsMouse ? "#202030" : "#11111b")
                                    border.color: isSelected ? modelData.col : root.borderMuted
                                    border.width: isSelected ? 2 : 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 8

                                        Rectangle {
                                            width: 12; height: 12; radius: 6
                                            color: modelData.col
                                            border.color: "#ffffff"; border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1
                                            width: parent.width - 24
                                            Text { text: modelData.name; color: isSelected ? "#ffffff" : root.textMain; font.family: root.mono; font.pixelSize: 9; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 7; elide: Text.ElideRight; width: parent.width }
                                        }
                                    }

                                    MouseArea {
                                        id: wallMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.variant = modelData.id
                                            if (typeof backend !== "undefined" && backend) backend.selectedWallpaper = modelData.id
                                        }
                                    }
                                }
                            }
                        }

                        // Metallic Icon Theme Badge
                        Rectangle {
                            width: parent.width
                            height: 28
                            radius: 6
                            color: "#11111b"
                            border.color: root.borderMuted

                            Row {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 8
                                Rectangle { width: 10; height: 10; radius: 5; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "ICON SUITE: " + root.backendIconTheme; color: root.accent; font.family: root.mono; font.pixelSize: 9; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }

                // ------------------------------------------------------------
                // QUADRANT 3: 🛡️ HARDWARE & DEFENSE TOGGLES
                // ------------------------------------------------------------
                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 240
                    radius: 12
                    color: root.surface
                    border.color: root.borderMuted
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Row {
                            spacing: 6
                            Text { text: "🛡️ HARDWARE & DEFENSE MODULES"; color: "#a6e3a1"; font.family: root.mono; font.pixelSize: 11; font.bold: true; font.letterSpacing: 0.8 }
                        }
                        Rectangle { width: parent.width; height: 1; color: Qt.rgba(166/255, 227/255, 161/255, 0.3) }

                        readonly property var toggles: [
                            { k: "stealth",    title: "Stealth Tor Routing", desc: "Route DNS & egress through onion circuits", col: "#f38ba8" },
                            { k: "bore",       title: "BORE CPU Scheduler",  desc: "Ultra-low latency interactive response", col: "#a6e3a1" },
                            { k: "zram",       title: "ZRAM zstd Swap",      desc: "In-memory compression eliminates disk swap", col: "#74c7ec" },
                            { k: "mem_scrub",  title: "Memory Buffer Scrub", desc: "Wipe memory buffers on process termination", col: "#fab387" },
                            { k: "wayland",    title: "Wayland Compositor",  desc: "GPU hardware-accelerated Sway stack", col: "#b4befe" }
                        ]

                        Repeater {
                            model: parent.toggles
                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 32
                                radius: 6

                                readonly property bool isOn: root.backendCombos[modelData.k] !== false
                                color: isOn ? root.surfaceContainer : (togMouse.containsMouse ? "#202030" : "#11111b")
                                border.color: isOn ? modelData.col : root.borderMuted
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8

                                    Rectangle {
                                        width: 38; height: 18; radius: 4
                                        color: isOn ? modelData.col : "#08080d"
                                        border.color: isOn ? modelData.col : root.borderMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: isOn ? "ON" : "OFF"; color: isOn ? "#08080d" : root.textMuted; font.family: root.mono; font.pixelSize: 8; font.bold: true }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1
                                        width: parent.width - 50
                                        Text { text: modelData.title; color: isOn ? "#ffffff" : root.textMain; font.family: root.mono; font.pixelSize: 9; font.bold: true }
                                        Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 7; elide: Text.ElideRight; width: parent.width }
                                    }
                                }

                                MouseArea {
                                    id: togMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                }
                            }
                        }
                    }
                }

                // ------------------------------------------------------------
                // QUADRANT 4: 🚀 SYSTEM CONTROLS & COCKPIT LAUNCH
                // ------------------------------------------------------------
                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 240
                    radius: 12
                    color: root.surface
                    border.color: root.borderMuted
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Row {
                            spacing: 6
                            Text { text: "🚀 SYSTEM CONTROLS & LAUNCH"; color: "#74c7ec"; font.family: root.mono; font.pixelSize: 11; font.bold: true; font.letterSpacing: 0.8 }
                        }
                        Rectangle { width: parent.width; height: 1; color: Qt.rgba(116/255, 199/255, 236/255, 0.3) }

                        // Keyboard Shortcuts Matrix
                        Rectangle {
                            width: parent.width
                            height: 72
                            radius: 6
                            color: "#11111b"
                            border.color: root.borderMuted

                            Grid {
                                anchors.fill: parent
                                anchors.margins: 6
                                columns: 2
                                spacing: 6

                                Row {
                                    spacing: 6
                                    Rectangle { width: 62; height: 16; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + S"; color: "#fff"; font.family: root.mono; font.pixelSize: 8; font.bold: true } }
                                    Text { text: "Command HUD"; color: root.textSub; font.family: root.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Row {
                                    spacing: 6
                                    Rectangle { width: 62; height: 16; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + T"; color: "#fff"; font.family: root.mono; font.pixelSize: 8; font.bold: true } }
                                    Text { text: "Kitty Terminal"; color: root.textSub; font.family: root.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Row {
                                    spacing: 6
                                    Rectangle { width: 62; height: 16; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + B"; color: "#fff"; font.family: root.mono; font.pixelSize: 8; font.bold: true } }
                                    Text { text: "Hardened Chromium"; color: root.textSub; font.family: root.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Row {
                                    spacing: 6
                                    Rectangle { width: 62; height: 16; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + I"; color: "#fff"; font.family: root.mono; font.pixelSize: 8; font.bold: true } }
                                    Text { text: "Calamares Installer"; color: root.textSub; font.family: root.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }

                        // Direct Launch Actions
                        Row {
                            width: parent.width
                            height: 34
                            spacing: 8

                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: parent.height
                                radius: 6
                                color: "#141422"
                                border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ OPEN HUD ]"; color: root.accent; font.family: root.mono; font.pixelSize: 9; font.bold: true }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("synapse-hud")
                                }
                            }

                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: parent.height
                                radius: 6
                                color: "#141422"
                                border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ INSTALL DISK ]"; color: "#a6e3a1"; font.family: root.mono; font.pixelSize: 9; font.bold: true }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("calamares -d")
                                }
                            }
                        }

                        // Master Action Button: INITIATE CYBERDECK & ENTER DESKTOP
                        Rectangle {
                            width: parent.width
                            height: 44
                            radius: 8
                            color: root.accent

                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    text: "INITIATE CYBERDECK & ENTER DESKTOP ▶"
                                    color: "#08080e"
                                    font.family: root.mono; font.pixelSize: 11; font.bold: true; font.letterSpacing: 0.8
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (typeof backend !== "undefined" && backend) {
                                        backend.applyAndFinish()
                                    } else {
                                        root.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Divider Line
            Rectangle {
                width: parent.width; height: 1
                color: root.withAlpha(root.accent, 0.35)
            }

            // Bottom Footer Status Bar
            Item {
                width: parent.width
                height: 20

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Rectangle { width: 6; height: 6; radius: 3; color: "#a6e3a1"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "ZERO TELEMETRY ACTIVE  ·  SOVEREIGN LINUX COCKPIT"; color: root.textMuted; font.family: root.mono; font.pixelSize: 9 }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "SUPER + S OPENS HUD AT ANY TIME"
                    color: root.accent
                    font.family: root.mono; font.pixelSize: 9; font.bold: true
                }
            }
        }
    }
}
