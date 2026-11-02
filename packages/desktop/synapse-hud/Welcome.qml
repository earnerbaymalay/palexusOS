// SynapseOS — Cyberdeck Onboarding Gate (QtQuick / QML)
// Matches SDDM Greeter (synapse-greeter) obsidian chamfered aesthetic:
// - Authentic 3D liquid chrome master emblem stamped at header
// - Chamfered obsidian glass panel with traveling border trails and bloom
// - Circuit leads with traveling light pulses
// - 8-step sequential cyberdeck provisioning sequence:
//   01. Identity & Call-sign
//   02. Claude & Multi-Model AI Engine (Dedicated Claude input console)
//   03. Workstation Profile Archetype
//   04. Modular Hardware, Kernel & Privacy Feature Combos (12 toggles)
//   05. Metallic Icon Suite
//   06. Cyberdeck Theme & Accent
//   07. Terminal Idle Screensaver
//   08. System Verification & Cockpit Launch

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Effects

Window {
    id: root
    width: 1040
    height: 720
    minimumWidth: 980
    minimumHeight: 680
    visible: true
    title: "SynapseOS · Cyberdeck Onboarding Gate"
    color: "#09090d"

    readonly property var accents: ({
        mauve: "#cba6f7", tungsten: "#fab387", crimson: "#f38ba8",
        sapphire: "#74c7ec", emerald: "#a6e3a1"
    })
    property string variant: (typeof backend !== "undefined" && backend && backend.selectedWallpaper) ? backend.selectedWallpaper : "monolith-mauve"
    readonly property color accent: accents[variant.split("-").pop()] || accents.mauve
    readonly property color surface: "#14141e"
    readonly property color surfaceContainer: "#181825"
    readonly property color textMain: "#cdd6f4"
    readonly property color textSub: "#a6adc8"
    readonly property color textMuted: "#6c7086"
    readonly property color borderMuted: "#313244"
    readonly property string mono: "JetBrainsMono Nerd Font"

    readonly property string backendOperator: (typeof backend !== "undefined" && backend && backend.operator) ? backend.operator : "operator"
    readonly property string backendHostname: (typeof backend !== "undefined" && backend && backend.hostname) ? backend.hostname : "synapse-deck"
    readonly property string backendAiEngine: (typeof backend !== "undefined" && backend && backend.selectedAiEngine) ? backend.selectedAiEngine : "claude"
    readonly property string backendProfile: (typeof backend !== "undefined" && backend && backend.selectedProfile) ? backend.selectedProfile : "ai_deck"
    readonly property string backendIconTheme: (typeof backend !== "undefined" && backend && backend.selectedIconTheme) ? backend.selectedIconTheme : "Synapse-Liquid-Chrome"
    readonly property string backendScreensaver: (typeof backend !== "undefined" && backend && backend.selectedScreensaver) ? backend.selectedScreensaver : "torus"
    readonly property var backendCombos: (typeof backend !== "undefined" && backend && backend.combos) ? backend.combos : ({})
    readonly property string chromePath: (typeof backend !== "undefined" && backend && backend.chromeEmblemPath) ? backend.chromeEmblemPath : ""
    readonly property string claudeKey: (typeof backend !== "undefined" && backend && backend.claudeApiKey) ? backend.claudeApiKey : ""
    readonly property string claudeResponse: (typeof backend !== "undefined" && backend && backend.claudeTestResponse) ? backend.claudeTestResponse : "Ready. Enter prompt above and click 'Query Claude' to test live communication."

    property int currentStep: 0
    readonly property int totalSteps: 8
    property bool showClaudeKey: false

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    // Background Wallpaper / Subtle Radial Depth
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0d0d15" }
            GradientStop { position: 0.6; color: "#09090d" }
            GradientStop { position: 1.0; color: "#060608" }
        }
    }

    // --- Circuit leads either side of the panel (from synapse-greeter) ---
    Item {
        id: circuitLeads
        anchors.fill: parent
        z: 0

        // Left lead
        Item {
            x: panel.x - 70
            y: panel.y + 160
            width: 70
            height: 2
            Rectangle { anchors.fill: parent; color: root.withAlpha(root.accent, 0.35) }
            Rectangle {
                id: pulseLeft
                width: 32; height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: root.accent }
                    GradientStop { position: 1.0; color: "#ffffff" }
                }
                NumberAnimation on x {
                    loops: Animation.Infinite
                    duration: 2400
                    from: 70; to: -32
                }
            }
            Rectangle {
                width: 8; height: 8; x: -4; y: -3
                color: "#09090d"
                border { color: root.accent; width: 1.5 }
            }
        }

        // Right lead
        Item {
            x: panel.x + panel.width
            y: panel.y + 160
            width: 70
            height: 2
            Rectangle { anchors.fill: parent; color: root.withAlpha(root.accent, 0.35) }
            Rectangle {
                id: pulseRight
                width: 32; height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ffffff" }
                    GradientStop { position: 0.5; color: root.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on x {
                    loops: Animation.Infinite
                    duration: 2400
                    from: -32; to: 70
                }
            }
            Rectangle {
                width: 8; height: 8; x: 66; y: -3
                color: "#09090d"
                border { color: root.accent; width: 1.5 }
            }
        }
    }

    // --- Central Chamfered Obsidian Panel ---
    Item {
        id: panel
        readonly property real c: 18
        readonly property real pad: 16
        anchors.fill: parent
        anchors.margins: 28
        z: 1

        // Chamfered Base Body
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 1.2
                strokeColor: root.borderMuted
                fillColor: Qt.rgba(12 / 255, 12 / 255, 18 / 255, 0.94)
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

        // Travelling Glowing Outline Trails (from synapse-greeter)
        Shape {
            id: trails
            anchors.fill: parent
            readonly property real perim: 2 * (panel.width + panel.height)
            property real offset: 0
            NumberAnimation on offset {
                loops: Animation.Infinite
                from: trails.perim; to: 0
                duration: 6800
            }
            ShapePath {
                strokeColor: root.accent
                strokeWidth: 2
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [16, 140]
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
            ShapePath {
                strokeColor: "#ffffff"
                strokeWidth: 2
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [4, 152]
                dashOffset: trails.offset - 10
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

        MultiEffect {
            source: trails
            anchors.fill: trails
            blurEnabled: true
            blurMax: 24
            blur: 0.65
            brightness: 0.35
            z: -1
        }

        // --- Panel Content ---
        Column {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 12

            // 1. TOP HEADER (Emblem + Title + SDDM Telemetry)
            Item {
                width: parent.width
                height: 58

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    // Stamped 3D Liquid Chrome Master Plate
                    Image {
                        width: 96
                        height: 54
                        source: root.chromePath ? ("file://" + root.chromePath) : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Row {
                            spacing: 8
                            Text {
                                text: "SYNAPSE"
                                color: root.accent
                                font { family: root.mono; pixelSize: 15; bold: true; letterSpacing: 3.5 }
                            }
                            Text {
                                text: "// ONBOARDING GATE"
                                color: root.textMain
                                font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.5 }
                            }
                        }
                        Text {
                            text: "AUTHENTIC 3D LIQUID CHROME · CYBERDECK PROVISIONING"
                            color: root.textSub
                            font { family: root.mono; pixelSize: 10; letterSpacing: 0.8 }
                        }
                    }
                }

                // SDDM System Telemetry Readout
                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        anchors.right: parent.right
                        text: "HOST: " + root.backendHostname
                        color: root.textSub
                        font { family: root.mono; pixelSize: 10 }
                    }
                    Text {
                        anchors.right: parent.right
                        text: "KERNEL: linux-cachyos · BORE"
                        color: root.textMain
                        font { family: root.mono; pixelSize: 10 }
                    }
                    Row {
                        anchors.right: parent.right
                        spacing: 8
                        Text { text: "DNS: Quad9 DoT"; color: "#74c7ec"; font { family: root.mono; pixelSize: 10 } }
                        Text { text: "● PROVISIONING"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                    }
                }
            }

            // Divider Line with Accent Gradient
            Rectangle {
                width: parent.width
                height: 1
                color: root.withAlpha(root.accent, 0.45)
            }

            // 2. STEP PROGRESS RAIL (Conduit Pips)
            Row {
                width: parent.width
                height: 24
                spacing: 6

                readonly property var stepNames: [
                    "01 CALL-SIGN", "02 CLAUDE & AI", "03 ARCHETYPE",
                    "04 COMBOS", "05 METALLIC", "06 THEME",
                    "07 SCREENSAVER", "08 LAUNCH"
                ]

                Repeater {
                    model: parent.stepNames
                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        width: (parent.width - (parent.stepNames.length - 1) * parent.spacing) / parent.stepNames.length
                        height: 22
                        radius: 4
                        color: index === root.currentStep ? root.accent : (index < root.currentStep ? "#1e1e2e" : "#11111b")
                        border.color: index === root.currentStep ? root.accent : (index < root.currentStep ? root.withAlpha(root.accent, 0.4) : "#313244")
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font { family: root.mono; pixelSize: 9; bold: true }
                            color: index === root.currentStep ? "#11111b" : (index < root.currentStep ? root.accent : root.textMuted)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentStep = index
                        }
                    }
                }
            }

            // 3. MAIN STEP CONTAINER (Stack / Switcher)
            Item {
                id: pageContainer
                width: parent.width
                height: parent.height - 58 - 1 - 24 - 44 - 36 // remaining height
                clip: true

                // ========================================================
                // STEP 1: IDENTITY & CALL-SIGN
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 0

                    Column {
                        anchors.fill: parent
                        spacing: 14

                        Text {
                            text: "QUESTION 01 // OPERATOR CALL-SIGN & NODE DESIGNATION"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Establish your operator cryptographic identity, cyberdeck node hostname, and co-pilot call-sign."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // Form Container
                        Rectangle {
                            width: parent.width
                            height: 200
                            radius: 10
                            color: root.surface
                            border.color: root.borderMuted
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                // Field 1: Operator
                                Text { text: "Operator Call-Sign / User Account:"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
                                TextField {
                                    id: opInput
                                    width: parent.width
                                    height: 34
                                    text: root.backendOperator
                                    color: root.textMain
                                    font { family: root.mono; pixelSize: 12 }
                                    background: Rectangle {
                                        color: "#0d0d15"
                                        radius: 6
                                        border.color: opInput.activeFocus ? root.accent : root.borderMuted
                                    }
                                    onTextChanged: if (typeof backend !== "undefined" && backend) backend.operator = text
                                }

                                // Field 2: Hostname
                                Text { text: "Cyberdeck Node Hostname / Domain:"; color: "#74c7ec"; font { family: root.mono; pixelSize: 11; bold: true } }
                                TextField {
                                    id: hostInput
                                    width: parent.width
                                    height: 34
                                    text: root.backendHostname
                                    color: root.textMain
                                    font { family: root.mono; pixelSize: 12 }
                                    background: Rectangle {
                                        color: "#0d0d15"
                                        radius: 6
                                        border.color: hostInput.activeFocus ? "#74c7ec" : root.borderMuted
                                    }
                                    onTextChanged: if (typeof backend !== "undefined" && backend) backend.hostname = text
                                }
                            }
                        }

                        // Greeter Readout Preview Box
                        Rectangle {
                            width: parent.width
                            height: 96
                            radius: 8
                            color: "#09090d"
                            border.color: root.borderMuted
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4

                                Text { text: "● SDDM AUTH GATE READOUT PREVIEW"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true } }
                                Text {
                                    text: "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> Authenticated operator: <font color='" + root.accent + "'><b>" + opInput.text + "</b></font> (tty7)<br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> Node hostname: <font color='#74c7ec'><b>" + hostInput.text + "</b></font> · Quad9 DoT active<br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> Local Autonomous AI Engine: <font color='#fab387'><b>Synapse</b></font> (standby on :11434)"
                                    textFormat: Text.StyledText
                                    color: root.textSub
                                    font { family: root.mono; pixelSize: 11 }
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 2: DEDICATED CLAUDE & MULTI-MODEL AI ENGINE
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 1

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: "QUESTION 02 // DEDICATED CLAUDE & MULTI-MODEL AI ENGINE"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Configure your primary agentic reasoning engine. Enter Claude / Anthropic credentials or select local sovereign models."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // AI Provider Selector Cards
                        Row {
                            width: parent.width
                            height: 68
                            spacing: 8

                            readonly property var providers: [
                                { id: "claude", name: "🟣 Claude (Anthropic)", badge: "CLAUDE 3.7", desc: "Anthropic Sonnet / Opus reasoning engine", col: "#cba6f7" },
                                { id: "gemini", name: "🔵 Gemini (Google)", badge: "GEMINI 2.5", desc: "DeepMind multimodal 2M token context", col: "#74c7ec" },
                                { id: "ollama", name: "🟢 Local Ollama", badge: "SOVEREIGN", desc: "Qwen 2.5 / DeepSeek 100% offline", col: "#a6e3a1" },
                                { id: "hybrid", name: "🟡 Hybrid Mesh", badge: "AUTONOMOUS", desc: "Local fast triage with Claude escalation", col: "#fab387" }
                            ]

                            Repeater {
                                model: parent.providers
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (parent.width - 24) / 4
                                    height: parent.height
                                    radius: 8
                                    color: (root.backendAiEngine === modelData.id) ? root.surfaceContainer : root.surface
                                    border.color: (root.backendAiEngine === modelData.id) ? modelData.col : root.borderMuted
                                    border.width: (root.backendAiEngine === modelData.id) ? 2 : 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 2

                                        Row {
                                            width: parent.width
                                            Text { text: modelData.name; color: "#ffffff"; font { family: root.mono; pixelSize: 11; bold: true } }
                                        }
                                        Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; elide: Text.ElideRight; width: parent.width }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.selectedAiEngine = modelData.id
                                    }
                                }
                            }
                        }

                        // Dedicated Claude Console Card
                        Rectangle {
                            width: parent.width
                            height: 250
                            radius: 10
                            color: root.surface
                            border.color: root.accent
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 8

                                Row {
                                    spacing: 8
                                    Text { text: "⚡ DEDICATED CLAUDE CONSOLE & INPUT INTERFACE"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
                                    Rectangle {
                                        width: 70; height: 18; radius: 4; color: "#11111b"; border.color: root.accent; border.width: 1
                                        Text { anchors.centerIn: parent; text: "ACTIVE"; color: root.accent; font { family: root.mono; pixelSize: 9; bold: true } }
                                    }
                                }

                                // Anthropic Key Field
                                Row {
                                    width: parent.width
                                    spacing: 10

                                    Column {
                                        width: parent.width * 0.55
                                        spacing: 3
                                        Row {
                                            spacing: 6
                                            Text { text: "Anthropic / Claude API Key (Optional for Local):"; color: root.textSub; font { family: root.mono; pixelSize: 10; bold: true } }
                                            Text {
                                                text: root.showClaudeKey ? "🔒 Hide" : "👁️ Show"
                                                color: root.accent
                                                font { family: root.mono; pixelSize: 9; bold: true }
                                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showClaudeKey = !root.showClaudeKey }
                                            }
                                        }
                                        TextField {
                                            id: claudeKeyInput
                                            width: parent.width
                                            height: 32
                                            echoMode: root.showClaudeKey ? TextInput.Normal : TextInput.Password
                                            placeholderText: "sk-ant-api03-..."
                                            placeholderTextColor: root.textMuted
                                            text: root.claudeKey
                                            color: root.accent
                                            font { family: root.mono; pixelSize: 11 }
                                            background: Rectangle { color: "#0d0d15"; radius: 6; border.color: claudeKeyInput.activeFocus ? root.accent : root.borderMuted }
                                            onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeApiKey = text
                                        }
                                    }

                                    Column {
                                        width: parent.width * 0.42
                                        spacing: 3
                                        Text { text: "Claude Model Designation:"; color: root.textSub; font { family: root.mono; pixelSize: 10; bold: true } }
                                        TextField {
                                            id: claudeModelInput
                                            width: parent.width
                                            height: 32
                                            text: "claude-3-7-sonnet-20250219"
                                            color: "#74c7ec"
                                            font { family: root.mono; pixelSize: 11 }
                                            background: Rectangle { color: "#0d0d15"; radius: 6; border.color: root.borderMuted }
                                            onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeModel = text
                                        }
                                    }
                                }

                                // Interactive Claude Test Input Prompt
                                Text { text: "Test Query to Claude / Local Co-Pilot:"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true } }
                                Row {
                                    width: parent.width
                                    height: 32
                                    spacing: 8

                                    TextField {
                                        id: testPromptInput
                                        width: parent.width - 130
                                        height: 32
                                        text: "Synthesize cyberdeck defense status and verify neural readiness."
                                        placeholderText: "Type any prompt for Claude or Local AI..."
                                        color: root.textMain
                                        font { family: root.mono; pixelSize: 11 }
                                        background: Rectangle { color: "#0d0d15"; radius: 6; border.color: testPromptInput.activeFocus ? root.accent : root.borderMuted }
                                    }

                                    Rectangle {
                                        width: 122
                                        height: 32
                                        radius: 6
                                        color: root.accent
                                        Text { anchors.centerIn: parent; text: "⚡ Query Claude"; color: "#11111b"; font { family: root.mono; pixelSize: 11; bold: true } }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (typeof backend !== "undefined" && backend) {
                                                    claudeResponseText.text = "Handshaking with neural copilot..."
                                                    backend.testClaudeQuery(testPromptInput.text, claudeKeyInput.text, claudeModelInput.text)
                                                }
                                            }
                                        }
                                    }
                                }

                                // Claude Test Output Terminal Box
                                Rectangle {
                                    width: parent.width
                                    height: 64
                                    radius: 6
                                    color: "#09090d"
                                    border.color: root.borderMuted

                                    Text {
                                        id: claudeResponseText
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        text: root.claudeResponse
                                        color: "#a6e3a1"
                                        font { family: root.mono; pixelSize: 10 }
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 3: WORKSTATION PROFILE ARCHETYPES
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 2

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: "QUESTION 03 // WORKSTATION PROFILE ARCHETYPE"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Select your primary operational directive to optimize CPU scheduling, memory caching, and toolchains."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        readonly property var archetypes: [
                            { id: "ai_deck", title: "🤖 AI & Neural Deck (Agentic Engine)", badge: "ACCELERATED", col: "#cba6f7", desc: "Pre-warms local Ollama daemon, keeps 8GB model weights resident in VRAM/RAM, auto-indexes vector brain memory, and unlocks Claude/Gemini CLI tools." },
                            { id: "sec_ops", title: "🛡️ Cyber Defense & Hardened SecOps", badge: "HARDENED", col: "#f38ba8", desc: "Strict inbound firewall packet drops, randomized MAC rotation on link handshake, ephemeral RAM workspaces, and terminal forensics toolchains." },
                            { id: "perf_kernel", title: "⚡ Kernel Extreme Performance & Low Latency", badge: "UNTHROTTLED", col: "#fab387", desc: "Unlocks sustained 25W PL1 thermal boost, CachyOS BORE scheduler burst prioritization, and 64-sample PipeWire audio buffer for real-time DSP." },
                            { id: "stealth_core", title: "🔒 Sovereign Stealth & Zero Telemetry", badge: "STEALTH", col: "#74c7ec", desc: "Purges all outbound analytics, strictly routes DNS-over-TLS through Quad9 (port 853), isolates browser storage, and flushes RAM on session lock." },
                            { id: "daily_driver", title: "🌌 Minimalist Cyberdeck Daily Driver", badge: "BALANCED", col: "#a6e3a1", desc: "Clean obsidian aesthetics, silent fan curve, deep C-state battery conservation, and distraction-free keyboard-driven tiling navigation." }
                        ]

                        Repeater {
                            model: parent.archetypes
                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 56
                                radius: 8
                                color: (root.backendProfile === modelData.id) ? root.surfaceContainer : root.surface
                                border.color: (root.backendProfile === modelData.id) ? modelData.col : root.borderMuted
                                border.width: (root.backendProfile === modelData.id) ? 2 : 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

                                    Rectangle {
                                        width: 14; height: 14; radius: 7; anchors.verticalCenter: parent.verticalCenter
                                        color: (root.backendProfile === modelData.id) ? modelData.col : "transparent"
                                        border.color: modelData.col; border.width: 2
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        width: parent.width - 120

                                        Row {
                                            spacing: 8
                                            Text { text: modelData.title; color: "#ffffff"; font { family: root.mono; pixelSize: 11; bold: true } }
                                            Rectangle {
                                                width: 60; height: 16; radius: 3; color: "#09090d"; border.color: modelData.col
                                                Text { anchors.centerIn: parent; text: modelData.badge; color: modelData.col; font { family: root.mono; pixelSize: 8; bold: true } }
                                            }
                                        }
                                        Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 10; elide: Text.ElideRight; width: parent.width }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.selectedProfile = modelData.id
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 4: MODULAR FEATURE COMBOS (12 Toggles)
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 3

                    Column {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            text: "QUESTION 04 // MODULAR SYSTEM FEATURE COMBOS"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Toggle individual hardware acceleration, privacy shielding, and kernel mechanics. Combine according to your workflow."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // 12-Card Grid
                        Grid {
                            width: parent.width
                            columns: 3
                            spacing: 8

                            readonly property var allCombos: [
                                { k: "stealth", title: "🛡️ Prime Directive Stealth", desc: "Dynamic MAC randomization on scan & links", col: "#cba6f7" },
                                { k: "dot", title: "🔒 Encrypted DNS (DoT)", desc: "Strict Quad9 DNS-over-TLS (port 853)", col: "#74c7ec" },
                                { k: "firewall", title: "🧱 Inbound Firewall Drop", desc: "Drop all unsolicited incoming packets", col: "#f38ba8" },
                                { k: "mem_scrub", title: "🧼 Volatile Session Scrub", desc: "Purge clipboard and temp tokens on lock", col: "#bac2de" },
                                { k: "ollama", title: "🤖 Local Ollama Daemon", desc: "Warm model standby on :11434 on boot", col: "#a6e3a1" },
                                { k: "vector_mem", title: "🧠 Vector Brain Memory", desc: "Local SQLite vector store for bash & notes", col: "#cba6f7" },
                                { k: "gpu_tensor", title: "⚡ GPU Tensor Unthrottle", desc: "Max performance clocks for neural compute", col: "#fab387" },
                                { k: "bore", title: "🚀 BORE Scheduler Boost", desc: "Burst CPU priority for interactive GUI", col: "#fab387" },
                                { k: "zram", title: "💾 ZRAM Temp Filesystem", desc: "Mount /tmp & swap on compressed ZRAM", col: "#74c7ec" },
                                { k: "audio_rt", title: "🎧 Realtime Audio Buffer", desc: "Lock PipeWire to 64-sample low-latency DSP", col: "#a6e3a1" },
                                { k: "wayland", title: "🌌 Sway Wayland Compositor", desc: "Hardware acceleration with XFCE fallback", col: "#b4befe" },
                                { k: "hotkey_hud", title: "⌨️ Mnemonic Keybinding HUD", desc: "Super+key muscle memory overlay on login", col: "#cba6f7" }
                            ]

                            Repeater {
                                model: parent.allCombos
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (parent.width - 16) / 3
                                    height: 74
                                    radius: 8
                                    readonly property bool isOn: !!root.backendCombos[modelData.k]

                                    color: isOn ? root.surfaceContainer : "#101018"
                                    border.color: isOn ? modelData.col : root.borderMuted
                                    border.width: isOn ? 1.5 : 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 4

                                        Row {
                                            width: parent.width
                                            Text { text: modelData.title; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width - 64 }
                                            Rectangle {
                                                width: 58; height: 16; radius: 3; color: "#09090d"
                                                border.color: isOn ? modelData.col : root.borderMuted
                                                Text { anchors.centerIn: parent; text: isOn ? "ACTIVE" : "STANDBY"; color: isOn ? modelData.col : root.textMuted; font { family: root.mono; pixelSize: 8; bold: true } }
                                            }
                                        }
                                        Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; elide: Text.ElideRight; width: parent.width }
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

                // ========================================================
                // STEP 5: METALLIC & REFLECTIVE ICON SUITE
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 4

                    Column {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "QUESTION 05 // METALLIC & REFLECTIVE ICON SUITE"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Select your hardware-accelerated vector suites designed for high-contrast obsidian workspaces."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        readonly property var iconThemes: [
                            { id: "Synapse-Liquid-Chrome", name: "✨ Liquid Mauve Chrome (Default)", col: "#cba6f7", desc: "High-gloss mirror chrome finish with 45° diamond chamfers and liquid mauve sheen." },
                            { id: "Synapse-Smoked-Obsidian", name: "🌑 Smoked Obsidian & Neon", col: "#b4befe", desc: "Mirror-finish jet-black ceramic dish with knurled metal rim and glowing purple conduit." },
                            { id: "Synapse-Radial-Tungsten", name: "⚙️ Radial Milled Tungsten", col: "#fab387", desc: "Concentric lathe tool marks with anisotropic cross-reflection and singularity torus." },
                            { id: "Synapse-Aerospace-Billet", name: "🛡️ Aerospace Billet & Satin", col: "#74c7ec", desc: "Brushed titanium chassis plate with bead-blasted satin mauve pocket and micro-bolts." }
                        ]

                        Repeater {
                            model: parent.iconThemes
                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 62
                                radius: 8
                                color: (root.backendIconTheme === modelData.id) ? root.surfaceContainer : root.surface
                                border.color: (root.backendIconTheme === modelData.id) ? modelData.col : root.borderMuted
                                border.width: (root.backendIconTheme === modelData.id) ? 2 : 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 14; height: 14; radius: 7; anchors.verticalCenter: parent.verticalCenter
                                        color: (root.backendIconTheme === modelData.id) ? modelData.col : "transparent"
                                        border.color: modelData.col; border.width: 2
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        width: parent.width - 50

                                        Text { text: modelData.name; color: "#ffffff"; font { family: root.mono; pixelSize: 12; bold: true } }
                                        Text { text: modelData.desc; color: root.textSub; font { family: root.mono; pixelSize: 10 } }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.selectedIconTheme = modelData.id
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 6: CYBERDECK WALLPAPER & ACCENT VARIANT
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 5

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: "QUESTION 06 // CYBERDECK THEME & ACCENT VARIANT"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Each variant dynamically synchronizes your SDDM greeter, Waybar telemetry leads, and HUD glowing borders."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        readonly property var wallpapers: [
                            { id: "monolith-mauve", name: "Monolith · Mauve (Default)", col: "#cba6f7", desc: "Classic monolithic geometry in deep Mauve" },
                            { id: "tower-mauve", name: "Basalt Tower · Mauve", col: "#cba6f7", desc: "Brutalist cyberdeck pillars under ultraviolet aurora" },
                            { id: "carbon-mauve", name: "Forged Carbon · Mauve", col: "#cba6f7", desc: "High-density forged carbon weave with violet accents" },
                            { id: "monolith-tungsten", name: "Monolith · Tungsten", col: "#fab387", desc: "Industrial warm tungsten anodized finish" },
                            { id: "carbon-crimson", name: "Forged Carbon · Crimson", col: "#f38ba8", desc: "High-contrast stealth crimson weave" },
                            { id: "monolith-sapphire", name: "Monolith · Sapphire", col: "#74c7ec", desc: "Cold aerospace sapphire chrome" },
                            { id: "monolith-emerald", name: "Monolith · Emerald", col: "#a6e3a1", desc: "Matrix phosphor terminal green" }
                        ]

                        Grid {
                            width: parent.width
                            columns: 2
                            spacing: 8

                            Repeater {
                                model: parent.wallpapers
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (parent.width - 8) / 2
                                    height: 52
                                    radius: 8
                                    color: (root.variant === modelData.id) ? root.surfaceContainer : root.surface
                                    border.color: (root.variant === modelData.id) ? modelData.col : root.borderMuted
                                    border.width: (root.variant === modelData.id) ? 2 : 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        Rectangle {
                                            width: 14; height: 14; radius: 7; anchors.verticalCenter: parent.verticalCenter
                                            color: modelData.col; border.color: "#ffffff"; border.width: 1
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2
                                            width: parent.width - 40

                                            Text { text: modelData.name; color: "#ffffff"; font { family: root.mono; pixelSize: 11; bold: true } }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; elide: Text.ElideRight; width: parent.width }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (typeof backend !== "undefined" && backend) backend.selectedWallpaper = modelData.id
                                    }
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 7: TERMINAL IDLE SCREENSAVER
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 6

                    Column {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "QUESTION 07 // TERMINAL IDLE SCREENSAVER"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "Mathematical Braille ASCII wireframes rendered on OLED obsidian black. Any keystroke resumes session."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        readonly property var screensavers: [
                            { id: "torus", name: "🟣 The Purple Donut (Geodesic Neon Torus)", col: "#cba6f7", desc: "Rotating mathematical 3D geodesic torus wireframe rendered in Braille Unicode on OLED black." },
                            { id: "brand", name: "⚡ Decrypted Cyber Matrix & Brand Reveal", col: "#fab387", desc: "Terminal matrix data stream resolving into the glowing SYNAPSE master cipher glyph." },
                            { id: "cycle", name: "🌌 Continuous Singularity Cycle", col: "#74c7ec", desc: "Seamlessly alternates between the orbital torus (40s) and cipher brand reveal (12s)." }
                        ]

                        Repeater {
                            model: parent.screensavers
                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 64
                                radius: 8
                                color: (root.backendScreensaver === modelData.id) ? root.surfaceContainer : root.surface
                                border.color: (root.backendScreensaver === modelData.id) ? modelData.col : root.borderMuted
                                border.width: (root.backendScreensaver === modelData.id) ? 2 : 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 14; height: 14; radius: 7; anchors.verticalCenter: parent.verticalCenter
                                        color: (root.backendScreensaver === modelData.id) ? modelData.col : "transparent"
                                        border.color: modelData.col; border.width: 2
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        width: parent.width - 50

                                        Text { text: modelData.name; color: "#ffffff"; font { family: root.mono; pixelSize: 12; bold: true } }
                                        Text { text: modelData.desc; color: root.textSub; font { family: root.mono; pixelSize: 10 } }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof backend !== "undefined" && backend) backend.selectedScreensaver = modelData.id
                                }
                            }
                        }

                        // Test-Fire Button
                        Rectangle {
                            width: 280
                            height: 36
                            radius: 6
                            color: "#181825"
                            border.color: root.accent
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "👁️ Test-Fire Screensaver in Fullscreen"
                                color: root.accent
                                font { family: root.mono; pixelSize: 11; bold: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof backend !== "undefined" && backend) backend.previewScreensaver()
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 8: SYSTEM VERIFICATION & COCKPIT LAUNCH
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 7

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: "QUESTION 08 // SYSTEM VERIFICATION & LAUNCH COCKPIT"
                            color: root.accent
                            font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                        }
                        Text {
                            text: "All cyberdeck parameters configured and verified. Review your operational profile and launch the desktop."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // Terminal Checklist Box
                        Rectangle {
                            width: parent.width
                            height: 140
                            radius: 8
                            color: "#09090d"
                            border.color: root.borderMuted

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4

                                Text {
                                    textFormat: Text.StyledText
                                    text: "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>OPERATOR CALL-SIGN:</b> <font color='" + root.accent + "'>" + root.backendOperator + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>CYBERDECK HOSTNODE:</b> <font color='#74c7ec'>" + root.backendHostname + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>AI ENGINE:</b> <font color='#fab387'>" + root.backendAiEngine.toUpperCase() + "</font> · Persona Armed<br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>WORKSTATION ARCHETYPE:</b> <font color='" + root.accent + "'>" + root.backendProfile.toUpperCase() + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>METALLIC ICON SUITE:</b> <font color='#ffffff'>" + root.backendIconTheme + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>PRIME DIRECTIVE STEALTH:</b> <font color='#a6e3a1'>ACTIVE (Quad9 DoT · MAC Randomized)</font>"
                                    color: root.textSub
                                    font { family: root.mono; pixelSize: 11 }
                                }
                            }
                        }

                        // Muscle Memory Shortcuts Box
                        Rectangle {
                            width: parent.width
                            height: 90
                            radius: 8
                            color: root.surface
                            border.color: root.borderMuted

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text { text: "⌨️ MNEMONIC MUSCLE MEMORY (Super + First Letter):"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true } }

                                Grid {
                                    width: parent.width
                                    columns: 3
                                    spacing: 8

                                    readonly property var keys: [
                                        ["Super + S", "Command HUD"],
                                        ["Super + T", "Kitty GPU Terminal"],
                                        ["Super + B", "Hardened Chromium"],
                                        ["Super + F", "Thunar File Manager"],
                                        ["Super + I", "Calamares Installer"],
                                        ["Super + K", "Cheat Sheet HUD"]
                                    ]
                                    Repeater {
                                        model: parent.keys
                                        delegate: Row {
                                            spacing: 6
                                            Rectangle {
                                                width: 68; height: 18; radius: 3; color: "#09090d"; border.color: "#45475a"
                                                Text { anchors.centerIn: parent; text: modelData[0]; color: "#ffffff"; font { family: root.mono; pixelSize: 9; bold: true } }
                                            }
                                            Text { text: modelData[1]; color: root.textSub; font { family: root.mono; pixelSize: 10 } }
                                        }
                                    }
                                }
                            }
                        }

                        // Quick Launcher Buttons
                        Row {
                            width: parent.width
                            height: 32
                            spacing: 8

                            Rectangle {
                                width: (parent.width - 16) / 3; height: parent.height; radius: 6; color: "#181825"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "🚀 Open HUD (Super+S)"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("synapse-hud") }
                            }
                            Rectangle {
                                width: (parent.width - 16) / 3; height: parent.height; radius: 6; color: "#181825"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "💿 Install OS (Super+I)"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("calamares -d") }
                            }
                            Rectangle {
                                width: (parent.width - 16) / 3; height: parent.height; radius: 6; color: "#181825"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "⌨️ Keybindings (Super+K)"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
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
                color: root.withAlpha(root.accent, 0.45)
            }

            // 4. BOTTOM NAVIGATION BAR
            Item {
                width: parent.width
                height: 38

                // Back Button
                Rectangle {
                    width: 120
                    height: 36
                    radius: 6
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.currentStep > 0 ? "#181825" : "#11111b"
                    border.color: root.currentStep > 0 ? root.borderMuted : "#1e1e2e"
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
                Text {
                    anchors.centerIn: parent
                    text: "Step " + (root.currentStep + 1) + " of " + root.totalSteps
                    color: root.textSub
                    font { family: root.mono; pixelSize: 11; bold: true }
                }

                // Next / Finish Button
                Rectangle {
                    width: root.currentStep === root.totalSteps - 1 ? 230 : 150
                    height: 36
                    radius: 6
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.accent

                    Text {
                        anchors.centerIn: parent
                        text: root.currentStep === root.totalSteps - 1 ? "✨ INITIATE CYBERDECK ▶" : "CONTINUE ▶"
                        color: "#11111b"
                        font { family: root.mono; pixelSize: 11; bold: true }
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
