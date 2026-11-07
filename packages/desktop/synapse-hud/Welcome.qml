// SynapseOS — Cyberdeck Onboarding Gate (Qt6 / Material You Cockpit)
// Redesigned by Huihui Qwen 2.5 Coder Abliterated & Antigravity
// Calm, luxury sidebar + canvas layout with generous whitespace and Catppuccin Mocha aesthetic.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Effects

Window {
    id: root
    width: 980
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

    property int activeNav: 0
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

        // Ambient border drop-glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent"
            border.color: root.accent
            border.width: 1
            opacity: 0.35
            radius: panel.c + 2
        }

        // Chamfered Obsidian Glass Slab
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

        // Animated Travelling Border Light Trails
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

        // ====================================================================
        // MAIN SPLIT LAYOUT: LEFT SIDEBAR + RIGHT CONTENT CANVAS
        // ====================================================================
        Row {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 18

            // ----------------------------------------------------------------
            // 1. LEFT SIDEBAR (NAVIGATION & MASTER CONTROLS)
            // ----------------------------------------------------------------
            Rectangle {
                id: sidebar
                width: 250
                height: parent.height
                radius: 12
                color: root.surface
                border.color: root.borderMuted
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // Brand Header
                    Row {
                        spacing: 12
                        Item {
                            width: 38; height: 38
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 42; height: 42; radius: 21
                                color: root.withAlpha(root.accent, 0.20)
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    PropertyAnimation { to: 0.85; duration: 2200; easing.type: Easing.InOutSine }
                                    PropertyAnimation { to: 0.25; duration: 2200; easing.type: Easing.InOutSine }
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
                                width: 30; height: 30; radius: 6
                                color: "#141422"; border.color: root.accent; border.width: 1.5
                                visible: !chromeLogo.visible
                                Text { anchors.centerIn: parent; text: "SY"; color: root.accent; font.family: root.mono; font.pixelSize: 12; font.bold: true }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text {
                                text: "SYNAPSEOS"
                                color: "#ffffff"
                                font.family: root.mono; font.pixelSize: 13; font.bold: true; font.letterSpacing: 1.4
                            }
                            Text {
                                text: "Cyberdeck Gate"
                                color: root.accent
                                font.family: root.mono; font.pixelSize: 10
                            }
                        }
                    }

                    // Divider
                    Rectangle { width: parent.width; height: 1; color: root.withAlpha(root.accent, 0.25) }

                    // Navigation Menu
                    readonly property var navItems: [
                        { idx: 0, title: "Overview",   desc: "Deck Identity & Status", tag: "01" },
                        { idx: 1, title: "AI Copilot", desc: "Neural Engine Selection", tag: "02" },
                        { idx: 2, title: "Theme",      desc: "Wallpaper & Accents",    tag: "03" },
                        { idx: 3, title: "Defense",    desc: "Security & Latency",     tag: "04" },
                        { idx: 4, title: "Shortcuts",  desc: "Mnemonic Cheat Sheet",   tag: "05" }
                    ]

                    Repeater {
                        model: parent.navItems
                        delegate: Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 44
                            radius: 8

                            readonly property bool isCurrent: root.activeNav === modelData.idx
                            color: isCurrent ? root.surfaceContainer : (navMouse.containsMouse ? "#202030" : "transparent")
                            border.color: isCurrent ? root.accent : "transparent"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    width: 24; height: 20; radius: 4
                                    color: isCurrent ? root.accent : "#141422"
                                    border.color: isCurrent ? root.accent : root.borderMuted
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.tag
                                        color: isCurrent ? "#08080e" : root.accent
                                        font.family: root.mono; font.pixelSize: 9; font.bold: true
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1
                                    Text {
                                        text: modelData.title
                                        color: isCurrent ? "#ffffff" : root.textMain
                                        font.family: root.mono; font.pixelSize: 11; font.bold: isCurrent
                                    }
                                    Text {
                                        text: modelData.desc
                                        color: root.textSub
                                        font.family: root.mono; font.pixelSize: 8
                                    }
                                }
                            }

                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeNav = modelData.idx
                            }
                        }
                    }

                    Item { width: parent.width; height: 16 }

                    // Bottom Launcher Action
                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: 8
                        color: root.accent

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "ENTER DESKTOP ▶"
                                color: "#08080e"
                                font.family: root.mono; font.pixelSize: 10; font.bold: true; font.letterSpacing: 0.8
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

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "[Esc] Quick Launch"
                        color: root.textMuted
                        font.family: root.mono; font.pixelSize: 9
                    }
                }
            }

            // ----------------------------------------------------------------
            // 2. RIGHT CONTENT CANVAS (FOCUSED, BREATHABLE, SPACIOUS)
            // ----------------------------------------------------------------
            Rectangle {
                id: contentCanvas
                width: parent.width - sidebar.width - 18
                height: parent.height
                radius: 12
                color: root.surface
                border.color: root.borderMuted
                border.width: 1

                // Top Header Row inside Canvas
                Item {
                    id: canvasHeader
                    width: parent.width
                    height: 52
                    anchors.top: parent.top

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 22
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Rectangle {
                            width: 6; height: 6; radius: 3
                            color: root.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.activeNav === 0 ? "SYSTEM OVERVIEW" :
                                  root.activeNav === 1 ? "NEURAL AI COPILOT" :
                                  root.activeNav === 2 ? "VISUAL THEME STUDIO" :
                                  root.activeNav === 3 ? "HARDWARE & DEFENSE" : "MNEMONIC CONTROLS"
                            color: root.accent
                            font.family: root.mono; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1.2
                        }
                    }

                    // Window Close button
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        width: 26; height: 26; radius: 6
                        color: closeMouse.containsMouse ? "#f38ba8" : "#26263a"

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

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width; height: 1
                        color: root.withAlpha(root.accent, 0.20)
                    }
                }

                // Canvas Body Container
                Item {
                    anchors.top: canvasHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 22

                    // ========================================================
                    // TAB 0: SYSTEM OVERVIEW
                    // ========================================================
                    Item {
                        anchors.fill: parent
                        visible: root.activeNav === 0

                        Column {
                            anchors.fill: parent
                            spacing: 18

                            Column {
                                spacing: 4
                                Text {
                                    text: "Welcome to SynapseOS"
                                    color: "#ffffff"
                                    font.family: root.mono; font.pixelSize: 20; font.bold: true
                                }
                                Text {
                                    text: "A sovereign, neural-hardened cyberdeck workspace with zero telemetry."
                                    color: root.textSub
                                    font.family: root.mono; font.pixelSize: 12
                                }
                            }

                            // Identity & Platform Cards
                            Row {
                                width: parent.width
                                height: 150
                                spacing: 14

                                Rectangle {
                                    width: (parent.width - 14) / 2
                                    height: parent.height
                                    radius: 10
                                    color: root.surfaceContainer
                                    border.color: root.borderMuted

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 10

                                        Text { text: "OPERATOR TELEMETRY"; color: root.accent; font.family: root.mono; font.pixelSize: 11; font.bold: true }

                                        Row {
                                            spacing: 8
                                            Text { text: "OPERATOR:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 11; width: 80 }
                                            Text { text: root.backendOperator; color: "#ffffff"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                        }
                                        Row {
                                            spacing: 8
                                            Text { text: "HOST NODE:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 11; width: 80 }
                                            Text { text: root.backendHostname; color: "#ffffff"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                        }
                                        Row {
                                            spacing: 8
                                            Text { text: "SECURITY:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 11; width: 80 }
                                            Text { text: "HARDENED [ACTIVE]"; color: "#a6e3a1"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 14) / 2
                                    height: parent.height
                                    radius: 10
                                    color: root.surfaceContainer
                                    border.color: root.borderMuted

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 10

                                        Text { text: "KERNEL ARCHITECTURE"; color: "#74c7ec"; font.family: root.mono; font.pixelSize: 11; font.bold: true }

                                        Row {
                                            spacing: 8
                                            Text { text: "CORE:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 11; width: 80 }
                                            Text { text: "Arch Linux 6.13+"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                        }
                                        Row {
                                            spacing: 8
                                            Text { text: "SCHEDULER:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 11; width: 80 }
                                            Text { text: "BORE Low-Latency Zen"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                        }
                                        Row {
                                            spacing: 8
                                            Text { text: "MEMORY:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 11; width: 80 }
                                            Text { text: "ZRAM zstd Compression"; color: "#fab387"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                        }
                                    }
                                }
                            }

                            // Quick Actions Banner
                            Row {
                                width: parent.width
                                height: 44
                                spacing: 12

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: parent.height
                                    radius: 8
                                    color: root.surfaceContainer
                                    border.color: root.accent

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Text { text: "▶"; color: root.accent; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: "OPEN COMMAND HUD"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("synapse-hud")
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: parent.height
                                    radius: 8
                                    color: root.surfaceContainer
                                    border.color: "#a6e3a1"

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Text { text: "⤓"; color: "#a6e3a1"; font.family: root.mono; font.pixelSize: 13 }
                                        Text { text: "INSTALL DISK (CALAMARES)"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("calamares -d")
                                    }
                                }
                            }
                        }
                    }

                    // ========================================================
                    // TAB 1: AI NEURAL COPILOT
                    // ========================================================
                    Item {
                        anchors.fill: parent
                        visible: root.activeNav === 1

                        Column {
                            anchors.fill: parent
                            spacing: 16

                            Column {
                                spacing: 4
                                Text { text: "Neural AI Copilot"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 18; font.bold: true }
                                Text { text: "Select your primary AI model for quickfire queries (Super+S) and autonomous reasoning."; color: root.textSub; font.family: root.mono; font.pixelSize: 11 }
                            }

                            // 3 Clean Model Cards
                            readonly property var copilotOptions: [
                                { id: "claude",   title: "Anthropic Claude 3.7 Sonnet", desc: "Frontier reasoning engine with extended thinking & deep code synthesis.", col: "#cba6f7", badge: "RECOMMENDED" },
                                { id: "ollama",   title: "Ollama Local (11434)",         desc: "100% Offline sovereign inference running Qwen 2.5 Coder Abliterated.", col: "#a6e3a1", badge: "SOVEREIGN" },
                                { id: "deepseek", title: "DeepSeek R1 / API",            desc: "Open reasoning API engine with high speed and efficient throughput.", col: "#74c7ec", badge: "FLEXIBLE" }
                            ]

                            Repeater {
                                model: parent.copilotOptions
                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: 58
                                    radius: 8

                                    readonly property bool isSelected: root.backendAiEngine === modelData.id
                                    color: isSelected ? root.surfaceContainer : (copilotMouse.containsMouse ? "#202030" : "#141420")
                                    border.color: isSelected ? modelData.col : root.borderMuted
                                    border.width: isSelected ? 1.5 : 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12

                                        Rectangle {
                                            width: 14; height: 14; radius: 7
                                            color: isSelected ? modelData.col : "transparent"
                                            border.color: modelData.col; border.width: 2
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2
                                            width: parent.width - 120
                                            Text { text: modelData.title; color: isSelected ? "#ffffff" : root.textMain; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9 }
                                        }

                                        Rectangle {
                                            width: 76; height: 20; radius: 4; color: "#08080d"
                                            border.color: isSelected ? modelData.col : root.borderMuted
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: modelData.badge; color: isSelected ? modelData.col : root.textMuted; font.family: root.mono; font.pixelSize: 8; font.bold: true }
                                        }
                                    }

                                    MouseArea {
                                        id: copilotMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.selectedAiEngine = modelData.id
                                    }
                                }
                            }

                            // Optional Token Field
                            Rectangle {
                                width: parent.width
                                height: 46
                                radius: 8
                                color: root.surfaceContainer
                                border.color: root.borderMuted

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Text { text: "API KEY:"; color: root.textMuted; font.family: root.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }

                                    TextInput {
                                        id: keyBox
                                        width: parent.width - 130
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: root.claudeKey
                                        color: "#ffffff"
                                        echoMode: root.showClaudeKey ? TextInput.Normal : TextInput.Password
                                        font.family: root.mono; font.pixelSize: 11
                                        selectByMouse: true
                                        selectionColor: root.accent
                                        onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeApiKey = text

                                        Text {
                                            text: "Optional authentication token..."
                                            color: "#585b70"
                                            font: keyBox.font
                                            visible: !keyBox.text
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Rectangle {
                                        width: 54; height: 28; radius: 4; color: "#222234"; border.color: root.borderMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: root.showClaudeKey ? "HIDE" : "SHOW"; color: root.textSub; font.family: root.mono; font.pixelSize: 9; font.bold: true }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showClaudeKey = !root.showClaudeKey }
                                    }
                                }
                            }
                        }
                    }

                    // ========================================================
                    // TAB 2: VISUAL THEME STUDIO (SECTION 5 FULLY RESOLVED)
                    // ========================================================
                    Item {
                        anchors.fill: parent
                        visible: root.activeNav === 2

                        Column {
                            anchors.fill: parent
                            spacing: 14

                            Column {
                                spacing: 4
                                Text { text: "Visual Theme & Accent Palette"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 18; font.bold: true }
                                Text { text: "Click any variant below to immediately shift the accent color, border glow, and light trails."; color: root.textSub; font.family: root.mono; font.pixelSize: 11 }
                            }

                            // Wallpapers Gallery
                            Grid {
                                id: galleryGrid
                                width: parent.width
                                columns: 2
                                spacing: 10

                                readonly property var galleryItems: [
                                    { id: "monolith-mauve",    name: "Monolith · Mauve (Default)", col: "#cba6f7", desc: "Classic Monolith in Violet Sheen" },
                                    { id: "tower-mauve",       name: "Basalt Tower · Mauve",       col: "#cba6f7", desc: "Brutalist Cyberdeck Pillars" },
                                    { id: "carbon-mauve",      name: "Forged Carbon · Mauve",      col: "#cba6f7", desc: "High-Density Carbon Weave" },
                                    { id: "monolith-tungsten", name: "Monolith · Tungsten",        col: "#fab387", desc: "Industrial Warm Gold Finish" },
                                    { id: "carbon-crimson",    name: "Forged Carbon · Crimson",    col: "#f38ba8", desc: "Stealth High-Contrast Crimson" },
                                    { id: "monolith-sapphire", name: "Monolith · Sapphire",        col: "#74c7ec", desc: "Aerospace Cold Chromium" },
                                    { id: "monolith-emerald",  name: "Monolith · Emerald",         col: "#a6e3a1", desc: "Phosphor Matrix Terminal Green" }
                                ]

                                Repeater {
                                    model: galleryGrid.galleryItems
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (galleryGrid.width - 10) / 2
                                        height: 48
                                        radius: 8

                                        readonly property bool isSelected: root.variant === modelData.id
                                        color: isSelected ? root.surfaceContainer : (swatchMouse.containsMouse ? "#202030" : "#141420")
                                        border.color: isSelected ? modelData.col : root.borderMuted
                                        border.width: isSelected ? 2 : 1

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            Rectangle {
                                                width: 16; height: 16; radius: 8
                                                color: modelData.col
                                                border.color: "#ffffff"; border.width: 1
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 1
                                                width: parent.width - 32
                                                Text { text: modelData.name; color: isSelected ? "#ffffff" : root.textMain; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                                Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 8; elide: Text.ElideRight; width: parent.width }
                                            }
                                        }

                                        MouseArea {
                                            id: swatchMouse
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

                            // Icon Theme Readout
                            Rectangle {
                                width: parent.width
                                height: 38
                                radius: 8
                                color: root.surfaceContainer
                                border.color: root.borderMuted

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8
                                    Rectangle { width: 10; height: 10; radius: 5; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "METALLIC ICON SUITE: " + root.backendIconTheme; color: root.accent; font.family: root.mono; font.pixelSize: 10; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }

                    // ========================================================
                    // TAB 3: HARDWARE & DEFENSE
                    // ========================================================
                    Item {
                        anchors.fill: parent
                        visible: root.activeNav === 3

                        Column {
                            anchors.fill: parent
                            spacing: 12

                            Column {
                                spacing: 4
                                Text { text: "Cyberdeck Defense & Latency"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 18; font.bold: true }
                                Text { text: "Hardened modules pre-configured for low latency and zero data leakage."; color: root.textSub; font.family: root.mono; font.pixelSize: 11 }
                            }

                            readonly property var defenseModules: [
                                { k: "stealth",   title: "Stealth Tor Routing", desc: "Routes all egress DNS and network traffic through Tor circuits.", col: "#f38ba8" },
                                { k: "bore",      title: "BORE CPU Scheduler",  desc: "Burst-Oriented Response Enhancer prevents GUI micro-stutters.", col: "#a6e3a1" },
                                { k: "zram",      title: "ZRAM zstd Swap",      desc: "Fast compressed RAM swap device; eliminates physical disk thrashing.", col: "#74c7ec" },
                                { k: "mem_scrub", title: "Memory Buffer Scrub", desc: "Zeroes kernel memory allocations on exit to defeat cold-boot extraction.", col: "#fab387" },
                                { k: "wayland",   title: "Wayland Compositor",  desc: "GPU hardware-accelerated tearing-free Sway desktop compositing.", col: "#b4befe" }
                            ]

                            Repeater {
                                model: parent.defenseModules
                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: 42
                                    radius: 8

                                    readonly property bool isOn: root.backendCombos[modelData.k] !== false
                                    color: isOn ? root.surfaceContainer : (moduleMouse.containsMouse ? "#202030" : "#141420")
                                    border.color: isOn ? modelData.col : root.borderMuted
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 12

                                        Rectangle {
                                            width: 44; height: 22; radius: 4
                                            color: isOn ? modelData.col : "#08080d"
                                            border.color: isOn ? modelData.col : root.borderMuted
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: isOn ? "ON" : "OFF"; color: isOn ? "#08080d" : root.textMuted; font.family: root.mono; font.pixelSize: 9; font.bold: true }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1
                                            width: parent.width - 64
                                            Text { text: modelData.title; color: isOn ? "#ffffff" : root.textMain; font.family: root.mono; font.pixelSize: 10; font.bold: true }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 8; elide: Text.ElideRight; width: parent.width }
                                        }
                                    }

                                    MouseArea {
                                        id: moduleMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                    }
                                }
                            }
                        }
                    }

                    // ========================================================
                    // TAB 4: SHORTCUTS CHEAT SHEET
                    // ========================================================
                    Item {
                        anchors.fill: parent
                        visible: root.activeNav === 4

                        Column {
                            anchors.fill: parent
                            spacing: 14

                            Column {
                                spacing: 4
                                Text { text: "Mnemonic Navigation"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 18; font.bold: true }
                                Text { text: "Hardware shortcuts designed for high-efficiency terminal and cyberdeck workflows."; color: root.textSub; font.family: root.mono; font.pixelSize: 11 }
                            }

                            readonly property var hotkeys: [
                                { key: "Super + S", label: "Command HUD & Copilot", desc: "Global Quickfire search & AI assistant overlay" },
                                { key: "Super + T", label: "Kitty GPU Terminal",    desc: "Hardware-accelerated terminal with fish shell" },
                                { key: "Super + B", label: "Hardened Chromium",     desc: "Zero-telemetry privacy-hardened web browser" },
                                { key: "Super + F", label: "Thunar File Manager",   desc: "Fast native desktop file manager" },
                                { key: "Super + I", label: "Calamares Installer",   desc: "Install SynapseOS permanently to NVMe/SSD" },
                                { key: "Super + K", label: "Cheat Sheet HUD",       desc: "Floating keyboard shortcut reference overlay" }
                            ]

                            Repeater {
                                model: parent.hotkeys
                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: 38
                                    radius: 6
                                    color: root.surfaceContainer
                                    border.color: root.borderMuted

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 12

                                        Rectangle {
                                            width: 82; height: 22; radius: 4
                                            color: "#06060a"; border.color: root.accent
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: modelData.key; color: root.accent; font.family: root.mono; font.pixelSize: 9; font.bold: true }
                                        }

                                        Text { text: modelData.label; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; anchors.verticalCenter: parent.verticalCenter; width: 180 }
                                        Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
