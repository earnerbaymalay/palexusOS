// SynapseOS — Cyberdeck Onboarding Gate (QtQuick / QML)
// Redesigned by Huihui Qwen 2.5 Coder Abliterated & Antigravity
// Chamfered obsidian glass architecture with dual traveling white-hot light trails,
// liquid chrome master emblem with ambient Mauve breathing glow,
// streamlined 4-stage cyberdeck provisioning flow,
// fully unified with SDDM greeter (synapse-greeter) and Command HUD (synapse-hud).

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Effects

Window {
    id: root
    width: 980
    height: 660
    minimumWidth: 920
    minimumHeight: 620
    visible: true
    title: "SynapseOS // Cyberdeck Onboarding Gate"
    color: "#060609"

    readonly property var accents: ({
        mauve: "#cba6f7", tungsten: "#fab387", crimson: "#f38ba8",
        sapphire: "#74c7ec", emerald: "#a6e3a1"
    })
    property string variant: (typeof backend !== "undefined" && backend && backend.selectedWallpaper) ? backend.selectedWallpaper : "monolith-mauve"
    readonly property color accent: accents[variant.split("-").pop()] || accents.mauve
    readonly property color surface: "#0e0e17"
    readonly property color surfaceContainer: "#141422"
    readonly property color surfaceCard: "#11111c"
    readonly property color textMain: "#cdd6f4"
    readonly property color textSub: "#a6adc8"
    readonly property color textMuted: "#6c7086"
    readonly property color borderMuted: "#26263a"
    readonly property color borderGlow: withAlpha(accent, 0.45)
    readonly property string mono: "JetBrainsMono Nerd Font"

    readonly property string backendOperator: (typeof backend !== "undefined" && backend && backend.operator) ? backend.operator : "operator"
    readonly property string backendHostname: (typeof backend !== "undefined" && backend && backend.hostname) ? backend.hostname : "synapse-deck"
    readonly property string backendAiEngine: (typeof backend !== "undefined" && backend && backend.selectedAiEngine) ? backend.selectedAiEngine : "claude"
    readonly property string backendIconTheme: (typeof backend !== "undefined" && backend && backend.selectedIconTheme) ? backend.selectedIconTheme : "Synapse-Liquid-Chrome"
    readonly property var backendCombos: (typeof backend !== "undefined" && backend && backend.combos) ? backend.combos : ({})
    readonly property string chromeLogoPath: (typeof backend !== "undefined" && backend && backend.chromeLogoPath) ? backend.chromeLogoPath : ""
    readonly property string claudeKey: (typeof backend !== "undefined" && backend && backend.claudeApiKey) ? backend.claudeApiKey : ""

    property int currentStep: 0
    readonly property int totalSteps: 4
    property bool showClaudeKey: false

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    // --- Deep Obsidian Void & Radial Lighting ---
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0c0c16" }
            GradientStop { position: 0.5; color: "#060609" }
            GradientStop { position: 1.0; color: "#040406" }
        }
    }

    // --- Circuit leads either side of the panel (matching synapse-greeter) ---
    Item {
        id: circuitLeads
        anchors.fill: parent
        z: 0

        // Left lead
        Item {
            x: panel.x - 64
            y: panel.y + 110
            width: 64
            height: 2
            Rectangle { anchors.fill: parent; color: root.withAlpha(root.accent, 0.25) }
            Rectangle {
                width: 32; height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.45; color: root.accent }
                    GradientStop { position: 0.5; color: "#ffffff" }
                    GradientStop { position: 0.55; color: root.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on x {
                    loops: Animation.Infinite
                    duration: 2500
                    from: 64; to: -32
                }
            }
            Rectangle {
                width: 6; height: 6; x: -3; y: -2
                color: "#060609"
                border { color: root.accent; width: 1.5 }
            }
        }

        // Right lead
        Item {
            x: panel.x + panel.width
            y: panel.y + 110
            width: 64
            height: 2
            Rectangle { anchors.fill: parent; color: root.withAlpha(root.accent, 0.25) }
            Rectangle {
                width: 32; height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.45; color: root.accent }
                    GradientStop { position: 0.5; color: "#ffffff" }
                    GradientStop { position: 0.55; color: root.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on x {
                    loops: Animation.Infinite
                    duration: 2500
                    from: -32; to: 64
                }
            }
            Rectangle {
                width: 6; height: 6; x: 61; y: -2
                color: "#060609"
                border { color: root.accent; width: 1.5 }
            }
        }
    }

    // --- Main Monolithic Obsidian Glass Panel ---
    Item {
        id: panel
        readonly property real c: 20
        anchors.fill: parent
        anchors.margins: 20
        z: 1

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

        // Base Chamfered Obsidian Glass Slab
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

        // Dual Travelling White-Hot Light Trails along Chamfered Border
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
                dashPattern: [14, 120]
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

        // Interior Panel Content Column
        Column {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            // ================================================================
            // 1. HEADER: BRANDING & PROGRESS RAIL
            // ================================================================
            Row {
                width: parent.width
                height: 52
                spacing: 14

                // Authentic 3D Liquid Chrome Master Logo
                Item {
                    id: logoBox
                    width: 52
                    height: 52
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: glowBack
                        anchors.centerIn: parent
                        width: 56; height: 56
                        radius: 28
                        color: root.withAlpha(root.accent, 0.16)
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            PropertyAnimation { to: 0.75; duration: 2200; easing.type: Easing.InOutSine }
                            PropertyAnimation { to: 0.15; duration: 2200; easing.type: Easing.InOutSine }
                        }
                    }

                    Image {
                        id: chromeLogo
                        anchors.fill: parent
                        source: root.chromeLogoPath ? "file://" + root.chromeLogoPath : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        visible: status === Image.Ready
                    }

                    // Geometric fallback emblem
                    Rectangle {
                        anchors.centerIn: parent
                        width: 38; height: 38
                        radius: 6
                        color: "#141422"
                        border.color: root.accent
                        border.width: 1.5
                        visible: !chromeLogo.visible
                        Text {
                            anchors.centerIn: parent
                            text: "SY"
                            color: root.accent
                            font { family: root.mono; pixelSize: 15; bold: true }
                        }
                    }
                }

                // Title & Subtitle Readout
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    width: parent.width - 70 - stepRail.width - 20

                    Row {
                        spacing: 8
                        Text {
                            text: "SYNAPSE // ONBOARDING GATE"
                            color: "#ffffff"
                            font { family: root.mono; pixelSize: 15; bold: true; letterSpacing: 1.4 }
                        }
                        Rectangle {
                            height: 16; width: 68
                            radius: 3
                            color: "#08080d"
                            border.color: root.accent
                            Text {
                                anchors.centerIn: parent
                                text: "v1.0.0-PROT"
                                color: root.accent
                                font { family: root.mono; pixelSize: 8; bold: true }
                            }
                        }
                    }
                    Text {
                        text: "Autonomous Cyberdeck Provisioning & Cockpit Initialization"
                        color: root.textSub
                        font { family: root.mono; pixelSize: 11 }
                    }
                }

                // Streamlined 4-Step Orbital Progress Rail
                Row {
                    id: stepRail
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    readonly property var stepsMeta: [
                        { idx: "01", name: "IDENTITY" },
                        { idx: "02", name: "NEURAL" },
                        { idx: "03", name: "DEFENSE" },
                        { idx: "04", name: "STUDIO" }
                    ]

                    Repeater {
                        model: stepRail.stepsMeta
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: 86
                            height: 28
                            radius: 4

                            readonly property bool isActive: index === root.currentStep
                            readonly property bool isDone: index < root.currentStep

                            color: isActive ? root.withAlpha(root.accent, 0.20) : (isDone ? "#131320" : "#0a0a12")
                            border.color: isActive ? root.accent : (isDone ? root.withAlpha(root.accent, 0.5) : root.borderMuted)
                            border.width: isActive ? 1.5 : 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    text: modelData.idx
                                    color: isActive ? "#ffffff" : (isDone ? root.accent : root.textMuted)
                                    font { family: root.mono; pixelSize: 10; bold: true }
                                }
                                Text {
                                    text: modelData.name
                                    color: isActive ? root.accent : (isDone ? root.textMain : root.textMuted)
                                    font { family: root.mono; pixelSize: 9; bold: true; letterSpacing: 0.8 }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentStep = index
                            }
                        }
                    }
                }
            }

            // Divider Line with Accent Sheen
            Rectangle {
                width: parent.width
                height: 1
                color: root.withAlpha(root.accent, 0.35)
            }

            // ================================================================
            // 2. MAIN STAGE CONTENT (STREAMLINED 4-STAGE FLOW)
            // ================================================================
            Item {
                id: stageContainer
                width: parent.width
                height: parent.height - 138

                // ============================================================
                // STAGE 01: IDENTITY & SYSTEM READOUT
                // ============================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 0

                    Column {
                        anchors.fill: parent
                        spacing: 16

                        Row {
                            spacing: 8
                            Text {
                                text: "Stage 01 // Deck Identity & Node Status"
                                color: root.accent
                                font { family: root.mono; pixelSize: 14; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle {
                                width: 72; height: 18; radius: 3; color: "#09090d"; border.color: root.accent
                                Text { anchors.centerIn: parent; text: "ACTIVE NODE"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } }
                            }
                        }

                        Text {
                            text: "Welcome to SynapseOS. Your cyberdeck workspace is provisioned with hardened memory protection, BORE process scheduling, and native neural copilot integration."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 12 }
                            width: parent.width
                        }

                        // Identity Cards Grid
                        Row {
                            width: parent.width
                            height: 140
                            spacing: 14

                            // Operator Profile Card
                            Rectangle {
                                width: (parent.width - 14) / 2
                                height: parent.height
                                radius: 8
                                color: root.surfaceCard
                                border.color: root.borderMuted
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        Rectangle { width: 8; height: 8; radius: 4; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: "OPERATOR PROFILE"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true; letterSpacing: 1.0 } }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        Text { text: "OPERATOR:"; color: root.textMuted; width: 90; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: root.backendOperator; color: "#ffffff"; font.family: root.mono; font.pixelSize: 12; font.bold: true }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        Text { text: "NODE NAME:"; color: root.textMuted; width: 90; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: root.backendHostname; color: "#ffffff"; font.family: root.mono; font.pixelSize: 12; font.bold: true }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        Text { text: "PRIVILEGES:"; color: root.textMuted; width: 90; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: "WHEEL / ROOTLESS EXEC"; color: "#a6e3a1"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                    }
                                }
                            }

                            // Kernel & Hardware Telemetry Card
                            Rectangle {
                                width: (parent.width - 14) / 2
                                height: parent.height
                                radius: 8
                                color: root.surfaceCard
                                border.color: root.borderMuted
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        Rectangle { width: 8; height: 8; radius: 4; color: "#74c7ec"; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: "PLATFORM ARCHITECTURE"; color: "#74c7ec"; font.family: root.mono; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.0 }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        Text { text: "KERNEL:"; color: root.textMuted; width: 90; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: "Arch Linux 6.13+ · BORE Scheduler"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        Text { text: "COMPOSITOR:"; color: root.textMuted; width: 90; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: "Wayland (Sway) / XFCE Dual-Stack"; color: "#ffffff"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        Text { text: "MEMORY:"; color: root.textMuted; width: 90; font.family: root.mono; font.pixelSize: 11 }
                                        Text { text: "ZRAM zstd Compression Active"; color: "#fab387"; font.family: root.mono; font.pixelSize: 11; font.bold: true }
                                    }
                                }
                            }
                        }

                        // Cyberdeck Philosophy Banner
                        Rectangle {
                            width: parent.width
                            height: 72
                            radius: 8
                            color: "#0a0a12"
                            border.color: root.withAlpha(root.accent, 0.3)

                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 14

                                Rectangle {
                                    width: 44; height: 44; radius: 22
                                    color: root.withAlpha(root.accent, 0.15)
                                    border.color: root.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: "⚡"; font.pixelSize: 18 }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3
                                    Text { text: "ZERO TELEMETRY · SOVEREIGN COMPUTING"; color: "#ffffff"; font { family: root.mono; pixelSize: 11; bold: true; letterSpacing: 1.0 } }
                                    Text { text: "SynapseOS contains zero background trackers, analytics, or third-party phone-home beacons. You own your deck."; color: root.textSub; font { family: root.mono; pixelSize: 10 } }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // STAGE 02: NEURAL AI COPILOT
                // ============================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 1

                    Column {
                        anchors.fill: parent
                        spacing: 14

                        Row {
                            spacing: 8
                            Text {
                                text: "Stage 02 // Neural AI Engine Selection"
                                color: root.accent
                                font { family: root.mono; pixelSize: 14; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle {
                                width: 72; height: 18; radius: 3; color: "#09090d"; border.color: root.accent
                                Text { anchors.centerIn: parent; text: "COPILOT"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } }
                            }
                        }

                        Text {
                            text: "Select your primary AI copilot for system-wide quickfire queries (Super+S), intelligent command synthesis, and code intelligence."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 12 }
                            width: parent.width
                        }

                        // Neural Engine Providers
                        Row {
                            id: neuralRow
                            width: parent.width
                            height: 124
                            spacing: 12

                            readonly property var engines: [
                                { id: "claude",   title: "Anthropic Claude 3.7", desc: "Frontier reasoning model with extended thinking. System-wide code generation & deep synthesis.", col: "#cba6f7", badge: "RECOMMENDED" },
                                { id: "ollama",   title: "Ollama Local (11434)", desc: "100% offline private local LLM running Qwen 2.5 Coder Abliterated on your local GPU.", col: "#a6e3a1", badge: "SOVEREIGN" },
                                { id: "deepseek", title: "DeepSeek R1 / API",    desc: "Open reasoning API engine with high token throughput and cost-efficient intelligence.", col: "#74c7ec", badge: "FLEXIBLE" }
                            ]

                            Repeater {
                                model: neuralRow.engines
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (neuralRow.width - 24) / 3
                                    height: neuralRow.height
                                    radius: 8

                                    readonly property bool isSelected: root.backendAiEngine === modelData.id
                                    color: isSelected ? root.surfaceContainer : root.surfaceCard
                                    border.color: isSelected ? modelData.col : root.borderMuted
                                    border.width: isSelected ? 2 : 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 6

                                        Row {
                                            width: parent.width
                                            Text {
                                                text: modelData.title
                                                color: "#ffffff"
                                                font { family: root.mono; pixelSize: 11; bold: true }
                                                width: parent.width - 70
                                                elide: Text.ElideRight
                                            }
                                            Rectangle {
                                                width: 62; height: 16; radius: 3; color: "#08080d"
                                                border.color: modelData.col
                                                Text { anchors.centerIn: parent; text: modelData.badge; color: modelData.col; font { family: root.mono; pixelSize: 8; bold: true } }
                                            }
                                        }

                                        Text {
                                            text: modelData.desc
                                            color: root.textSub
                                            font { family: root.mono; pixelSize: 10 }
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                        }

                                        Item { width: parent.width; height: 4 }

                                        Row {
                                            spacing: 6
                                            Rectangle {
                                                width: 10; height: 10; radius: 5
                                                color: isSelected ? modelData.col : "transparent"
                                                border.color: modelData.col; border.width: 1.5
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            Text {
                                                text: isSelected ? "ACTIVE COPILOT" : "CLICK TO ACTIVATE"
                                                color: isSelected ? modelData.col : root.textMuted
                                                font { family: root.mono; pixelSize: 9; bold: true }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.selectedAiEngine = modelData.id
                                    }
                                }
                            }
                        }

                        // API Key Configuration Field (Optional)
                        Rectangle {
                            width: parent.width
                            height: 68
                            radius: 8
                            color: root.surfaceCard
                            border.color: root.borderMuted

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                Row {
                                    spacing: 8
                                    Text { text: "API AUTHENTICATION TOKEN (OPTIONAL):"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                                    Text { text: "(Stored locally in ~/.config/synapse/anthropic_key)"; color: root.textMuted; font { family: root.mono; pixelSize: 9 } }
                                }

                                Row {
                                    width: parent.width
                                    height: 30
                                    spacing: 8

                                    Rectangle {
                                        width: parent.width - 100
                                        height: parent.height
                                        radius: 4
                                        color: "#08080d"
                                        border.color: root.borderMuted

                                        TextInput {
                                            id: keyInput
                                            anchors.fill: parent
                                            anchors.margins: 6
                                            text: root.claudeKey
                                            color: "#ffffff"
                                            echoMode: root.showClaudeKey ? TextInput.Normal : TextInput.Password
                                            font { family: root.mono; pixelSize: 11 }
                                            onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeApiKey = text
                                        }
                                    }

                                    Rectangle {
                                        width: 92; height: parent.height; radius: 4
                                        color: "#141422"; border.color: root.borderMuted
                                        Text { anchors.centerIn: parent; text: root.showClaudeKey ? "HIDE [×]" : "SHOW [⊙]"; color: root.textMain; font { family: root.mono; pixelSize: 9; bold: true } }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showClaudeKey = !root.showClaudeKey }
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // STAGE 03: CYBERDECK HARDWARE & DEFENSE COMBOS
                // ============================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 2

                    Column {
                        anchors.fill: parent
                        spacing: 12

                        Row {
                            spacing: 8
                            Text {
                                text: "Stage 03 // Cyberdeck Hardware & Defense Combos"
                                color: root.accent
                                font { family: root.mono; pixelSize: 14; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle {
                                width: 72; height: 18; radius: 3; color: "#09090d"; border.color: root.accent
                                Text { anchors.centerIn: parent; text: "HARDENED"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } }
                            }
                        }

                        Text {
                            text: "Toggle advanced security, memory scrubbing, and latency optimization modules. All options are tuned for zero friction."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 12 }
                            width: parent.width
                        }

                        // 6 Essential Cyberdeck Combos Grid
                        Grid {
                            id: comboGrid
                            width: parent.width
                            columns: 3
                            spacing: 10

                            readonly property var comboItems: [
                                { k: "stealth",    title: "Stealth Tor Routing", desc: "Routes all egress DNS and TCP network traffic through Tor onion circuits.", col: "#f38ba8" },
                                { k: "mem_scrub",  title: "Memory Buffer Scrub", desc: "Zeroes kernel memory allocations on process exit to defeat cold-boot extraction.", col: "#fab387" },
                                { k: "bore",       title: "BORE CPU Scheduler",  desc: "Burst-Oriented Response Enhancer guarantees desktop input smoothness under load.", col: "#a6e3a1" },
                                { k: "zram",       title: "ZRAM zstd Swap",      desc: "In-memory compressed swap device eliminates physical disk wear and thrashing.", col: "#74c7ec" },
                                { k: "wayland",    title: "Wayland Compositor",  desc: "Hardware-accelerated tearing-free GPU compositing with Wayland/Sway stack.", col: "#b4befe" },
                                { k: "hotkey_hud", title: "Mnemonic Cheat Sheet",desc: "Super+K floating shortcut HUD to master keyboard navigation instantly.", col: "#cba6f7" }
                            ]

                            Repeater {
                                model: comboGrid.comboItems
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (comboGrid.width - 20) / 3
                                    height: 94
                                    radius: 6

                                    readonly property bool isOn: root.backendCombos[modelData.k] !== false
                                    color: isOn ? root.surfaceContainer : "#090910"
                                    border.color: isOn ? modelData.col : root.borderMuted
                                    border.width: isOn ? 1.5 : 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 4

                                        Row {
                                            width: parent.width
                                            Text {
                                                text: modelData.title
                                                color: "#ffffff"
                                                font { family: root.mono; pixelSize: 11; bold: true }
                                                width: parent.width - 50
                                                elide: Text.ElideRight
                                            }
                                            Rectangle {
                                                width: 44; height: 18; radius: 3
                                                color: "#06060a"
                                                border.color: isOn ? modelData.col : root.borderMuted
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: isOn ? "ON" : "OFF"
                                                    color: isOn ? modelData.col : root.textMuted
                                                    font { family: root.mono; pixelSize: 9; bold: true }
                                                }
                                            }
                                        }

                                        Text {
                                            text: modelData.desc
                                            color: root.textSub
                                            font { family: root.mono; pixelSize: 9 }
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // STAGE 04: THEME STUDIO & COCKPIT LAUNCH (FIXES SECTION 5)
                // ============================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 3

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Row {
                            spacing: 8
                            Text {
                                text: "Stage 04 // Visual Theme Studio & Cockpit Launch"
                                color: root.accent
                                font { family: root.mono; pixelSize: 14; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle {
                                width: 72; height: 18; radius: 3; color: "#09090d"; border.color: root.accent
                                Text { anchors.centerIn: parent; text: "PALETTE"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } }
                            }
                        }

                        Text {
                            text: "Select your visual theme. Choosing an accent synchronizes the SDDM greeter, border light trails, and Command HUD."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                            width: parent.width
                        }

                        // Wallpapers Grid with Explicit Scoping (Fixed parent scoping bug)
                        Grid {
                            id: wallGrid
                            width: parent.width
                            columns: 4
                            spacing: 8

                            readonly property var wallpapers: [
                                { id: "monolith-mauve",    name: "Monolith · Mauve",    col: "#cba6f7", desc: "Classic Monolith" },
                                { id: "tower-mauve",       name: "Basalt Tower",        col: "#cba6f7", desc: "Cyberdeck Pillars" },
                                { id: "carbon-mauve",      name: "Forged Carbon",       col: "#cba6f7", desc: "Carbon Weave" },
                                { id: "monolith-tungsten", name: "Warm Tungsten",       col: "#fab387", desc: "Industrial Gold" },
                                { id: "carbon-crimson",    name: "Stealth Crimson",     col: "#f38ba8", desc: "High Contrast" },
                                { id: "monolith-sapphire", name: "Aerospace Sapphire",  col: "#74c7ec", desc: "Cold Chromium" },
                                { id: "monolith-emerald",  name: "Matrix Emerald",      col: "#a6e3a1", desc: "Phosphor Terminal" }
                            ]

                            Repeater {
                                model: wallGrid.wallpapers
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (wallGrid.width - 24) / 4
                                    height: 48
                                    radius: 6

                                    readonly property bool isSelected: root.variant === modelData.id
                                    color: isSelected ? root.surfaceContainer : root.surfaceCard
                                    border.color: isSelected ? modelData.col : root.borderMuted
                                    border.width: isSelected ? 2 : 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 8

                                        Rectangle {
                                            width: 14; height: 14; radius: 7
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: modelData.col
                                            border.color: "#ffffff"; border.width: 1
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2
                                            width: parent.width - 26

                                            Text { text: modelData.name; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 8; elide: Text.ElideRight; width: parent.width }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.variant = modelData.id
                                            if (typeof backend !== "undefined" && backend) backend.selectedWallpaper = modelData.id
                                        }
                                    }
                                }
                            }
                        }

                        // Mnemonic Keybinding Cheat Sheet Tiles
                        Rectangle {
                            width: parent.width
                            height: 64
                            radius: 6
                            color: root.surfaceCard
                            border.color: root.borderMuted

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 120
                                    Text { text: "MNEMONICS:"; color: "#fab387"; font.family: root.mono; font.pixelSize: 10; font.bold: true }
                                    Text { text: "Super + Key"; color: root.textMuted; font.family: root.mono; font.pixelSize: 9 }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 12

                                    Row {
                                        spacing: 6
                                        Rectangle { width: 68; height: 18; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + S"; color: "#fff"; font.family: root.mono; font.pixelSize: 9; font.bold: true } }
                                        Text { text: "Command HUD"; color: root.textSub; font.family: root.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                    Row {
                                        spacing: 6
                                        Rectangle { width: 68; height: 18; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + T"; color: "#fff"; font.family: root.mono; font.pixelSize: 9; font.bold: true } }
                                        Text { text: "Kitty Terminal"; color: root.textSub; font.family: root.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                    Row {
                                        spacing: 6
                                        Rectangle { width: 68; height: 18; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + B"; color: "#fff"; font.family: root.mono; font.pixelSize: 9; font.bold: true } }
                                        Text { text: "Chromium"; color: root.textSub; font.family: root.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                    Row {
                                        spacing: 6
                                        Rectangle { width: 68; height: 18; radius: 3; color: "#06060a"; border.color: "#45475a"; Text { anchors.centerIn: parent; text: "Super + I"; color: "#fff"; font.family: root.mono; font.pixelSize: 9; font.bold: true } }
                                        Text { text: "Installer"; color: root.textSub; font.family: root.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }
                            }
                        }

                        // Quick Launcher Action Tiles
                        Row {
                            width: parent.width
                            height: 36
                            spacing: 10

                            Rectangle {
                                width: (parent.width - 20) / 3; height: parent.height; radius: 4; color: "#141422"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ OPEN COMMAND HUD ]"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("synapse-hud") }
                            }
                            Rectangle {
                                width: (parent.width - 20) / 3; height: parent.height; radius: 4; color: "#141422"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ INSTALL DISK (CALAMARES) ]"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("calamares -d") }
                            }
                            Rectangle {
                                width: (parent.width - 20) / 3; height: parent.height; radius: 4; color: "#141422"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ KEYBOARD CHEAT-SHEET ]"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("synapse-shortcuts") }
                            }
                        }
                    }
                }
            }

            // Divider Line
            Rectangle {
                width: parent.width
                height: 1
                color: root.withAlpha(root.accent, 0.35)
            }

            // ================================================================
            // 3. BOTTOM NAVIGATION BAR
            // ================================================================
            Item {
                width: parent.width
                height: 38

                // Back Button
                Rectangle {
                    width: 130
                    height: 36
                    radius: 4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.currentStep > 0 ? "#141422" : "#0a0a10"
                    border.color: root.currentStep > 0 ? root.borderMuted : "#161622"
                    enabled: root.currentStep > 0

                    Text {
                        anchors.centerIn: parent
                        text: "◀ PREVIOUS"
                        color: root.currentStep > 0 ? root.textMain : root.textMuted
                        font { family: root.mono; pixelSize: 11; bold: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: root.currentStep > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (root.currentStep > 0) root.currentStep--
                    }
                }

                // Step Status Text
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Rectangle { width: 6; height: 6; radius: 3; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: "STAGE 0" + (root.currentStep + 1) + " // 04"
                        color: root.textSub
                        font { family: root.mono; pixelSize: 11; bold: true; letterSpacing: 1.0 }
                    }
                }

                // Next / Finish Action Button
                Rectangle {
                    width: root.currentStep === root.totalSteps - 1 ? 230 : 150
                    height: 36
                    radius: 4
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.accent

                    Text {
                        anchors.centerIn: parent
                        text: root.currentStep === root.totalSteps - 1 ? "INITIATE CYBERDECK ▶" : "CONTINUE ▶"
                        color: "#08080e"
                        font { family: root.mono; pixelSize: 11; bold: true; letterSpacing: 0.8 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentStep < root.totalSteps - 1) {
                                root.currentStep++
                            } else {
                                if (typeof backend !== "undefined" && backend) backend.applyAndFinish()
                            }
                        }
                    }
                }
            }
        }
    }
}
