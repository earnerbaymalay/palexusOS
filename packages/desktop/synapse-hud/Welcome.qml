// SynapseOS — Cyberdeck Onboarding Gate (QtQuick / QML)
// author: earnerbaymalay
// Chamfered obsidian glass panels with dual traveling white-hot light trails,
// fluid cinematic step transitions with cubic easing, segmented orbital conduit
// progress rail, Claude & Multi-Model AI Engine console with live query testing,
// 12 modular hardware/kernel/privacy feature combos across 4 categories,
// fully unified with SDDM greeter (synapse-greeter) Catppuccin Mocha obsidian design.
// 6-step onboarding sequence.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Effects

Window {
    id: root
    width: 1080
    height: 740
    minimumWidth: 1020
    minimumHeight: 700
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
    readonly property string chromePath: (typeof backend !== "undefined" && backend && backend.chromeEmblemPath) ? backend.chromeEmblemPath : ""
    readonly property string chromeLogoPath: (typeof backend !== "undefined" && backend && backend.chromeLogoPath) ? backend.chromeLogoPath : ""
    readonly property string chromeSpinPath: (typeof backend !== "undefined" && backend && backend.chromeSpinPath) ? backend.chromeSpinPath : ""
    readonly property string chromePlatePath: (typeof backend !== "undefined" && backend && backend.chromePlatePath) ? backend.chromePlatePath : ""
    readonly property string claudeKey: (typeof backend !== "undefined" && backend && backend.claudeApiKey) ? backend.claudeApiKey : ""
    readonly property string claudeResponse: (typeof backend !== "undefined" && backend && backend.claudeTestResponse) ? backend.claudeTestResponse : "Ready. Enter prompt above and click 'EXECUTE NEURAL QUERY' to test live communication."

    property int currentStep: 0
    readonly property int totalSteps: 6
    property bool showClaudeKey: false

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    // --- Deep Obsidian Void & Radial Lighting ---
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0a0a12" }
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
            x: panel.x - 72
            y: panel.y + 140
            width: 72
            height: 2
            Rectangle { anchors.fill: parent; color: root.withAlpha(root.accent, 0.3) }
            Rectangle {
                width: 36; height: 2
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
                    from: 72; to: -36
                }
            }
            Rectangle {
                width: 8; height: 8; x: -4; y: -3
                color: "#060609"
                border { color: root.accent; width: 1.5 }
            }
        }

        // Right lead
        Item {
            x: panel.x + panel.width
            y: panel.y + 140
            width: 72
            height: 2
            Rectangle { anchors.fill: parent; color: root.withAlpha(root.accent, 0.3) }
            Rectangle {
                width: 36; height: 2
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
                    from: -36; to: 72
                }
            }
            Rectangle {
                width: 8; height: 8; x: 68; y: -3
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
        anchors.margins: 26
        z: 1

        // Base Chamfered Obsidian Glass Slab
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 1.2
                strokeColor: root.borderMuted
                fillColor: Qt.rgba(11 / 255, 11 / 255, 18 / 255, 0.95)
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

        // Dual Traveling White-Hot Light Trails (SDDM Greeter Signature)
        Shape {
            id: trails
            anchors.fill: parent
            readonly property real sw: 2.2
            readonly property real perim: (2 * (panel.width + panel.height) - 4 * panel.c + 2 * Math.SQRT2 * panel.c) / sw
            property real offset: 0
            NumberAnimation on offset {
                loops: Animation.Infinite
                from: trails.perim; to: 0
                duration: 7200
            }
            // Faint resting accent outline
            ShapePath {
                strokeColor: root.withAlpha(root.accent, 0.22)
                strokeWidth: trails.sw
                fillColor: "transparent"
                joinStyle: ShapePath.MiterJoin
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
            // Accent traveling trail
            ShapePath {
                strokeColor: root.accent
                strokeWidth: trails.sw
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.DashLine
                dashPattern: [trails.perim * 0.12, trails.perim * 0.38]
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
            // White-hot trailing head
            ShapePath {
                strokeColor: "#ffffff"
                strokeWidth: trails.sw
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.DashLine
                dashPattern: [trails.perim * 0.022, trails.perim * 0.478]
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

        MultiEffect {
            source: trails
            anchors.fill: trails
            blurEnabled: true
            blurMax: 20
            blur: 0.55
            brightness: 0.30
            z: -1
        }

        // --- Panel Interior Layout ---
        Column {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 12

            // ================================================================
            // 1. TOP HEADER: 4D Plate Object + Orbital Telemetry Readout
            // ================================================================
            Item {
                width: parent.width
                height: 64

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    // 4D Rotating Chamfered Plate Viewport
                    Item {
                        id: plateViewport
                        width: 66
                        height: 66
                        anchors.verticalCenter: parent.verticalCenter

                        // Breathing Ambient Tesseract Glow
                        Rectangle {
                            id: plateGlow
                            anchors.centerIn: parent
                            width: 62; height: 62
                            radius: 12
                            color: root.withAlpha(root.accent, 0.18)
                            scale: 1.0
                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.92; to: 1.14; duration: 2400; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 1.14; to: 0.92; duration: 2400; easing.type: Easing.InOutSine }
                            }
                        }

                        // 360° Right-to-Left Rotating 4D Chamfered Plate Object
                        AnimatedImage {
                            id: plateAnim
                            anchors.fill: parent
                            source: root.chromeSpinPath ? ("file://" + root.chromeSpinPath) : (root.chromePlatePath ? ("file://" + root.chromePlatePath) : "")
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            playing: true
                            paused: false
                        }

                        // Fallback static hero still if animated webp is unavailable
                        Image {
                            anchors.fill: parent
                            visible: plateAnim.status !== Image.Ready && plateAnim.status !== Image.Loading
                            source: root.chromePlatePath ? ("file://" + root.chromePlatePath) : (root.chromeLogoPath ? ("file://" + root.chromeLogoPath) : "")
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                        // Tactical Corner Brackets around Plate
                        Rectangle { width: 5; height: 1; x: 0; y: 0; color: root.accent }
                        Rectangle { width: 1; height: 5; x: 0; y: 0; color: root.accent }
                        Rectangle { width: 5; height: 1; x: parent.width - 5; y: 0; color: root.accent }
                        Rectangle { width: 1; height: 5; x: parent.width - 1; y: 0; color: root.accent }
                        Rectangle { width: 5; height: 1; x: 0; y: parent.height - 1; color: root.accent }
                        Rectangle { width: 1; height: 5; x: 0; y: parent.height - 5; color: root.accent }
                        Rectangle { width: 5; height: 1; x: parent.width - 5; y: parent.height - 1; color: root.accent }
                        Rectangle { width: 1; height: 5; x: parent.width - 1; y: parent.height - 5; color: root.accent }

                        MouseArea {
                            id: plateHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            ToolTip.visible: containsMouse
                            ToolTip.text: "Authentic 4D Chamfered Obsidian Plate // 360° Spatial Rotation"
                            ToolTip.delay: 200
                        }
                    }

                    // Console Header Typography
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Row {
                            spacing: 8
                            Text {
                                text: "SYNAPSE"
                                color: root.accent
                                font { family: root.mono; pixelSize: 16; bold: true; letterSpacing: 4.0 }
                            }
                            Text {
                                text: "// ONBOARDING GATE"
                                color: root.textMain
                                font { family: root.mono; pixelSize: 14; bold: true; letterSpacing: 1.6 }
                            }
                            Rectangle {
                                width: 84; height: 18; radius: 3; color: "#0a0a10"; border.color: root.accent; border.width: 1
                                Text { anchors.centerIn: parent; text: "SEC-LEVEL 0"; color: root.accent; font { family: root.mono; pixelSize: 9; bold: true } }
                            }
                        }
                        Text {
                            text: "4D CHAMFERED OBSIDIAN HARDWARE // SYSTEM PROVISIONING CONSOLE"
                            color: root.textSub
                            font { family: root.mono; pixelSize: 10; letterSpacing: 1.0 }
                        }
                    }
                }

                // SDDM Greeter System Telemetry Readout
                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Row {
                        anchors.right: parent.right
                        spacing: 8
                        Text { text: "OPERATOR:"; color: root.textMuted; font { family: root.mono; pixelSize: 10 } }
                        Text { text: root.backendOperator; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                        Text { text: "NODE:"; color: root.textMuted; font { family: root.mono; pixelSize: 10 } }
                        Text { text: root.backendHostname; color: "#74c7ec"; font { family: root.mono; pixelSize: 10; bold: true } }
                    }
                    Row {
                        anchors.right: parent.right
                        spacing: 8
                        Text { text: "KERNEL: linux-cachyos · BORE"; color: root.textSub; font { family: root.mono; pixelSize: 10 } }
                        Text { text: "DNS: Quad9 DoT"; color: "#a6e3a1"; font { family: root.mono; pixelSize: 10 } }
                    }
                    Row {
                        anchors.right: parent.right
                        spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "STAGE // 0" + (root.currentStep + 1) + " OF 06 · ONLINE"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                    }
                }
            }

            // Divider Line with Accent Gradient
            Rectangle {
                width: parent.width
                height: 1
                color: root.withAlpha(root.accent, 0.40)
            }

            // ================================================================
            // 2. ORBITAL STEP PROGRESS RAIL (Segmented Cyberdeck Conduit Bus)
            // ================================================================
            Row {
                id: stepRail
                width: parent.width
                height: 28
                spacing: 6

                readonly property var stepsMeta: [
                    { idx: "01", name: "IDENTITY" },
                    { idx: "02", name: "AI ENGINE" },
                    { idx: "03", name: "CONTROLS" },
                    { idx: "04", name: "ICONS" },
                    { idx: "05", name: "THEME" },
                    { idx: "06", name: "LAUNCH" }
                ]

                Repeater {
                    model: parent.stepsMeta
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: (stepRail.width - (stepRail.stepsMeta.length - 1) * stepRail.spacing) / stepRail.stepsMeta.length
                        height: 26

                        readonly property bool isActive: index === root.currentStep
                        readonly property bool isDone: index < root.currentStep

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: isActive ? root.withAlpha(root.accent, 0.18) : (isDone ? "#10101a" : "#0a0a10")
                            border.color: isActive ? root.accent : (isDone ? root.withAlpha(root.accent, 0.45) : root.borderMuted)
                            border.width: isActive ? 1.5 : 1

                            // Active step traveling light bullet along top edge
                            Rectangle {
                                visible: isActive
                                width: 20; height: 2
                                x: 0; y: 0
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.5; color: "#ffffff" }
                                    GradientStop { position: 1.0; color: root.accent }
                                }
                                NumberAnimation on x {
                                    running: isActive
                                    loops: Animation.Infinite
                                    from: -20; to: parent.width
                                    duration: 1600
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: isDone ? "[✓]" : modelData.idx
                                    font { family: root.mono; pixelSize: 9; bold: true }
                                    color: isActive ? "#ffffff" : (isDone ? "#a6e3a1" : root.textMuted)
                                }
                                Text {
                                    text: modelData.name
                                    font { family: root.mono; pixelSize: 9; bold: isActive }
                                    color: isActive ? root.accent : (isDone ? root.textMain : root.textMuted)
                                }
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

            // ================================================================
            // 3. MAIN CINEMATIC STEP CONTAINER (Smooth Fluid Slide & Fade)
            // ================================================================
            Item {
                id: stepViewport
                width: parent.width
                height: parent.height - 64 - 1 - 28 - 12 - 40 - 24 // remaining height
                clip: true

                // Animated step slider
                Item {
                    id: slideContainer
                    width: parent.width
                    height: parent.height
                    x: 0
                    opacity: 1.0

                    property int prevStep: 0

                    onPrevStepChanged: {
                        slideAnim.restart()
                    }

                    ParallelAnimation {
                        id: slideAnim
                        NumberAnimation { target: slideContainer; property: "opacity"; from: 0.15; to: 1.0; duration: 280; easing.type: Easing.OutCubic }
                        NumberAnimation { target: slideContainer; property: "x"; from: 18; to: 0; duration: 280; easing.type: Easing.OutCubic }
                    }
                }

                // ========================================================
                // STEP 1: IDENTITY — Operator Call-Sign & Hostname
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 0

                    Column {
                        anchors.fill: parent
                        spacing: 14

                        Row {
                            spacing: 8
                            Text {
                                text: "Step 1 · Operator Identity"
                                color: root.accent
                                font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle { width: 50; height: 16; radius: 3; color: "#09090d"; border.color: root.accent; Text { anchors.centerIn: parent; text: "AUTH"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } } }
                        }
                        Text {
                            text: "Set your username and hostname for this system. These identify you in the terminal and on the network."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // Form Container (Chamfered Obsidian Plate)
                        Rectangle {
                            width: parent.width
                            height: 195
                            radius: 8
                            color: root.surfaceCard
                            border.color: root.borderMuted
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                // Field 1: Operator
                                Column {
                                    width: parent.width
                                    spacing: 4
                                    Row {
                                        spacing: 6
                                        Text { text: "Username / Call-Sign:"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
                                        Text { text: "[PRIMARY ACCOUNT]"; color: "#a6e3a1"; font { family: root.mono; pixelSize: 9; bold: true } }
                                    }
                                    TextField {
                                        id: opInput
                                        width: parent.width
                                        height: 36
                                        text: root.backendOperator
                                        color: root.textMain
                                        font { family: root.mono; pixelSize: 12 }
                                        background: Rectangle {
                                            color: "#08080e"
                                            radius: 6
                                            border.color: opInput.activeFocus ? root.accent : root.borderMuted
                                            border.width: opInput.activeFocus ? 1.5 : 1
                                        }
                                        onTextChanged: if (typeof backend !== "undefined" && backend) backend.operator = text
                                    }
                                }

                                // Field 2: Hostname
                                Column {
                                    width: parent.width
                                    spacing: 4
                                    Row {
                                        spacing: 6
                                        Text { text: "Hostname:"; color: "#74c7ec"; font { family: root.mono; pixelSize: 11; bold: true } }
                                        Text { text: "[NETWORK NAME]"; color: root.textMuted; font { family: root.mono; pixelSize: 9 } }
                                    }
                                    TextField {
                                        id: hostInput
                                        width: parent.width
                                        height: 36
                                        text: root.backendHostname
                                        color: root.textMain
                                        font { family: root.mono; pixelSize: 12 }
                                        background: Rectangle {
                                            color: "#08080e"
                                            radius: 6
                                            border.color: hostInput.activeFocus ? "#74c7ec" : root.borderMuted
                                            border.width: hostInput.activeFocus ? 1.5 : 1
                                        }
                                        onTextChanged: if (typeof backend !== "undefined" && backend) backend.hostname = text
                                    }
                                }
                            }
                        }

                        // Greeter Readout Preview Box
                        Rectangle {
                            width: parent.width
                            height: 105
                            radius: 8
                            color: "#08080e"
                            border.color: root.withAlpha(root.accent, 0.35)
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 5

                                Row {
                                    spacing: 8
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#fab387"; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "LOGIN SCREEN PREVIEW"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true } }
                                }
                                Text {
                                    text: "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> Authenticated user: <font color='" + root.accent + "'><b>" + opInput.text + "</b></font> (tty7 · session ready)<br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> Hostname: <font color='#74c7ec'><b>" + hostInput.text + "</b></font> · Quad9 DoT active on :853<br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> AI engine: <font color='#fab387'><b>Synapse</b></font> (daemon standby on 127.0.0.1:11434)"
                                    textFormat: Text.StyledText
                                    color: root.textSub
                                    font { family: root.mono; pixelSize: 11 }
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // STEP 2: AI ENGINE — Claude & Multi-Model
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 1

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Row {
                            spacing: 8
                            Text {
                                text: "Step 2 · AI Engine Setup"
                                color: root.accent
                                font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle { width: 72; height: 16; radius: 3; color: "#09090d"; border.color: root.accent; Text { anchors.centerIn: parent; text: "REASONING"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } } }
                        }
                        Text {
                            text: "Choose your primary AI engine. Enter an Anthropic API key for cloud access, or run fully offline with local models."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // AI Provider Selector Cards
                        Row {
                            width: parent.width
                            height: 68
                            spacing: 8

                            readonly property var providers: [
                                { id: "claude", name: "Claude (Anthropic)", badge: "CLAUDE 3.7", desc: "Anthropic Sonnet / Opus reasoning engine", col: "#cba6f7" },
                                { id: "gemini", name: "Gemini (Google)", badge: "GEMINI 2.5", desc: "DeepMind multimodal 2M token context", col: "#74c7ec" },
                                { id: "ollama", name: "Local Ollama", badge: "SOVEREIGN", desc: "Qwen 2.5 / DeepSeek 100% offline", col: "#a6e3a1" },
                                { id: "hybrid", name: "Hybrid Mesh", badge: "AUTONOMOUS", desc: "Local fast triage with Claude escalation", col: "#fab387" }
                            ]

                            Repeater {
                                model: parent.providers
                                delegate: Rectangle {
                                    required property var modelData
                                    width: (parent.width - 24) / 4
                                    height: parent.height
                                    radius: 6
                                    color: (root.backendAiEngine === modelData.id) ? root.surfaceContainer : root.surfaceCard
                                    border.color: (root.backendAiEngine === modelData.id) ? modelData.col : root.borderMuted
                                    border.width: (root.backendAiEngine === modelData.id) ? 1.5 : 1

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

                        // Dedicated Claude Console Card (High-Tech Orbital Terminal)
                        Rectangle {
                            width: parent.width
                            height: 254
                            radius: 8
                            color: root.surfaceCard
                            border.color: root.accent
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 8

                                Row {
                                    spacing: 8
                                    Rectangle { width: 8; height: 8; radius: 4; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "AI CONSOLE // LIVE TEST INTERFACE"; color: root.accent; font { family: root.mono; pixelSize: 11; bold: true } }
                                    Rectangle {
                                        width: 60; height: 16; radius: 3; color: "#08080e"; border.color: root.accent
                                        Text { anchors.centerIn: parent; text: "ACTIVE"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } }
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
                                                text: root.showClaudeKey ? "[ MASK ]" : "[ REVEAL ]"
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
                                            background: Rectangle { color: "#08080e"; radius: 6; border.color: claudeKeyInput.activeFocus ? root.accent : root.borderMuted }
                                            onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeApiKey = text
                                        }
                                    }

                                    Column {
                                        width: parent.width * 0.42
                                        spacing: 3
                                        Text { text: "Model:"; color: root.textSub; font { family: root.mono; pixelSize: 10; bold: true } }
                                        TextField {
                                            id: claudeModelInput
                                            width: parent.width
                                            height: 32
                                            text: "claude-3-7-sonnet-20250219"
                                            color: "#74c7ec"
                                            font { family: root.mono; pixelSize: 11 }
                                            background: Rectangle { color: "#08080e"; radius: 6; border.color: root.borderMuted }
                                            onTextChanged: if (typeof backend !== "undefined" && backend) backend.claudeModel = text
                                        }
                                    }
                                }

                                // Interactive Test Prompt
                                Text { text: "Test Prompt:"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true } }
                                Row {
                                    width: parent.width
                                    height: 32
                                    spacing: 8

                                    TextField {
                                        id: testPromptInput
                                        width: parent.width - 190
                                        height: 32
                                        text: "Synthesize cyberdeck defense status and verify neural readiness."
                                        placeholderText: "Type a prompt to test your AI connection..."
                                        color: root.textMain
                                        font { family: root.mono; pixelSize: 11 }
                                        background: Rectangle { color: "#08080e"; radius: 6; border.color: testPromptInput.activeFocus ? root.accent : root.borderMuted }
                                    }

                                    Rectangle {
                                        width: 178; height: 32; radius: 6
                                        color: root.accent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "EXECUTE QUERY ▶"
                                            color: "#08080e"
                                            font { family: root.mono; pixelSize: 10; bold: true }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (typeof backend !== "undefined" && backend) {
                                                    claudeResponseText.text = "Handshaking with AI engine..."
                                                    backend.testClaudeQuery(testPromptInput.text, claudeKeyInput.text, claudeModelInput.text)
                                                }
                                            }
                                        }
                                    }
                                }

                                // AI Test Output Monitor (Phosphor CRT Viewport)
                                Rectangle {
                                    width: parent.width
                                    height: 68
                                    radius: 6
                                    color: "#050508"
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
                // STEP 3: SYSTEM CONTROLS (12 Toggles, 4 Categories)
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 2

                    ScrollView {
                        anchors.fill: parent
                        contentWidth: parent.width
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 8

                            Row {
                                spacing: 8
                                Text {
                                    text: "Step 3 · System Controls"
                                    color: root.accent
                                    font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                                }
                                Rectangle { width: 78; height: 16; radius: 3; color: "#09090d"; border.color: root.accent; Text { anchors.centerIn: parent; text: "12-MATRIX"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } } }
                            }
                            Text {
                                text: "Enable or disable individual features. Each toggle can be changed later in system settings."
                                color: root.textSub
                                font { family: root.mono; pixelSize: 11 }
                                width: parent.width
                            }

                            // ---- PRIVACY & STEALTH ----
                            Item { width: parent.width; height: 6 }
                            Row {
                                spacing: 6
                                Rectangle { width: 3; height: 14; radius: 1; color: "#cba6f7"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "PRIVACY & STEALTH"; color: "#cba6f7"; font { family: root.mono; pixelSize: 10; bold: true; letterSpacing: 1.2 } }
                            }
                            Grid {
                                width: parent.width
                                columns: 3
                                spacing: 6

                                readonly property var privacyCombos: [
                                    { k: "stealth",  title: "MAC Randomization", desc: "Randomizes your network hardware address on each connection to prevent tracking.", col: "#cba6f7" },
                                    { k: "dot",      title: "Encrypted DNS",     desc: "Routes all DNS lookups through Quad9 over TLS (port 853). Prevents DNS snooping.", col: "#74c7ec" },
                                    { k: "firewall", title: "Inbound Firewall",  desc: "Drops all unsolicited incoming connections. Only traffic you initiate gets through.", col: "#f38ba8" },
                                    { k: "mem_scrub",title: "Session Scrub",     desc: "Clears clipboard contents and temporary tokens when the screen locks.", col: "#bac2de" }
                                ]

                                Repeater {
                                    model: parent.privacyCombos
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - 12) / 3
                                        height: 72
                                        radius: 6
                                        readonly property bool isOn: !!root.backendCombos[modelData.k]
                                        color: isOn ? root.surfaceContainer : "#0b0b12"
                                        border.color: isOn ? modelData.col : root.borderMuted
                                        border.width: isOn ? 1.5 : 1

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4

                                            Row {
                                                width: parent.width
                                                Text { text: modelData.title; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width - 60 }
                                                Rectangle {
                                                    width: 54; height: 15; radius: 3; color: "#060609"
                                                    border.color: isOn ? modelData.col : root.borderMuted
                                                    Text { anchors.centerIn: parent; text: isOn ? "ON" : "OFF"; color: isOn ? modelData.col : root.textMuted; font { family: root.mono; pixelSize: 8; bold: true } }
                                                }
                                            }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                        }
                                    }
                                }
                            }

                            // ---- PERFORMANCE ----
                            Item { width: parent.width; height: 4 }
                            Row {
                                spacing: 6
                                Rectangle { width: 3; height: 14; radius: 1; color: "#fab387"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "PERFORMANCE"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true; letterSpacing: 1.2 } }
                            }
                            Grid {
                                width: parent.width
                                columns: 3
                                spacing: 6

                                readonly property var perfCombos: [
                                    { k: "bore",     title: "BORE Scheduler",    desc: "Prioritizes interactive apps for snappier window response and reduced input latency.", col: "#fab387" },
                                    { k: "zram",     title: "ZRAM Swap",         desc: "Uses compressed RAM as a fast swap device. Reduces disk I/O under memory pressure.", col: "#74c7ec" },
                                    { k: "audio_rt", title: "Low-Latency Audio", desc: "Locks PipeWire to 64-sample buffers for real-time DSP and music production.", col: "#a6e3a1" }
                                ]

                                Repeater {
                                    model: parent.perfCombos
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - 12) / 3
                                        height: 72
                                        radius: 6
                                        readonly property bool isOn: !!root.backendCombos[modelData.k]
                                        color: isOn ? root.surfaceContainer : "#0b0b12"
                                        border.color: isOn ? modelData.col : root.borderMuted
                                        border.width: isOn ? 1.5 : 1

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4

                                            Row {
                                                width: parent.width
                                                Text { text: modelData.title; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width - 60 }
                                                Rectangle {
                                                    width: 54; height: 15; radius: 3; color: "#060609"
                                                    border.color: isOn ? modelData.col : root.borderMuted
                                                    Text { anchors.centerIn: parent; text: isOn ? "ON" : "OFF"; color: isOn ? modelData.col : root.textMuted; font { family: root.mono; pixelSize: 8; bold: true } }
                                                }
                                            }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                        }
                                    }
                                }
                            }

                            // ---- AI & NEURAL ----
                            Item { width: parent.width; height: 4 }
                            Row {
                                spacing: 6
                                Rectangle { width: 3; height: 14; radius: 1; color: "#a6e3a1"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "AI & NEURAL"; color: "#a6e3a1"; font { family: root.mono; pixelSize: 10; bold: true; letterSpacing: 1.2 } }
                            }
                            Grid {
                                width: parent.width
                                columns: 3
                                spacing: 6

                                readonly property var aiCombos: [
                                    { k: "ollama",     title: "Local AI Daemon",  desc: "Starts Ollama on boot so local AI models are instantly ready on port 11434.", col: "#a6e3a1" },
                                    { k: "vector_mem", title: "Vector Memory",    desc: "Keeps a local SQLite vector store so your AI assistant remembers past sessions.", col: "#cba6f7" },
                                    { k: "gpu_tensor", title: "GPU Acceleration", desc: "Unlocks full GPU performance clocks for faster AI inference and compute workloads.", col: "#fab387" }
                                ]

                                Repeater {
                                    model: parent.aiCombos
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - 12) / 3
                                        height: 72
                                        radius: 6
                                        readonly property bool isOn: !!root.backendCombos[modelData.k]
                                        color: isOn ? root.surfaceContainer : "#0b0b12"
                                        border.color: isOn ? modelData.col : root.borderMuted
                                        border.width: isOn ? 1.5 : 1

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4

                                            Row {
                                                width: parent.width
                                                Text { text: modelData.title; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width - 60 }
                                                Rectangle {
                                                    width: 54; height: 15; radius: 3; color: "#060609"
                                                    border.color: isOn ? modelData.col : root.borderMuted
                                                    Text { anchors.centerIn: parent; text: isOn ? "ON" : "OFF"; color: isOn ? modelData.col : root.textMuted; font { family: root.mono; pixelSize: 8; bold: true } }
                                                }
                                            }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                        }
                                    }
                                }
                            }

                            // ---- SYSTEM ----
                            Item { width: parent.width; height: 4 }
                            Row {
                                spacing: 6
                                Rectangle { width: 3; height: 14; radius: 1; color: "#b4befe"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "SYSTEM"; color: "#b4befe"; font { family: root.mono; pixelSize: 10; bold: true; letterSpacing: 1.2 } }
                            }
                            Grid {
                                width: parent.width
                                columns: 3
                                spacing: 6

                                readonly property var sysCombos: [
                                    { k: "wayland",    title: "Wayland Compositor", desc: "Run the desktop under Wayland (Sway) for GPU-accelerated compositing. Falls back to XFCE/X11.", col: "#b4befe" },
                                    { k: "hotkey_hud", title: "Keybinding HUD",     desc: "Shows a keyboard shortcut overlay on login to help you learn the system controls.", col: "#cba6f7" }
                                ]

                                Repeater {
                                    model: parent.sysCombos
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - 12) / 3
                                        height: 72
                                        radius: 6
                                        readonly property bool isOn: !!root.backendCombos[modelData.k]
                                        color: isOn ? root.surfaceContainer : "#0b0b12"
                                        border.color: isOn ? modelData.col : root.borderMuted
                                        border.width: isOn ? 1.5 : 1

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4

                                            Row {
                                                width: parent.width
                                                Text { text: modelData.title; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width - 60 }
                                                Rectangle {
                                                    width: 54; height: 15; radius: 3; color: "#060609"
                                                    border.color: isOn ? modelData.col : root.borderMuted
                                                    Text { anchors.centerIn: parent; text: isOn ? "ON" : "OFF"; color: isOn ? modelData.col : root.textMuted; font { family: root.mono; pixelSize: 8; bold: true } }
                                                }
                                            }
                                            Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (typeof backend !== "undefined" && backend) backend.toggleCombo(modelData.k)
                                        }
                                    }
                                }
                            }

                            Item { width: parent.width; height: 8 }
                        }
                    }
                }

                // ========================================================
                // STEP 4: ICON SUITE
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 3

                    ScrollView {
                        anchors.fill: parent
                        contentWidth: parent.width
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 12

                            Row {
                                spacing: 8
                                Text {
                                    text: "Step 4 · Icon Suite"
                                    color: root.accent
                                    font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                                }
                                Rectangle { width: 68; height: 16; radius: 3; color: "#09090d"; border.color: root.accent; Text { anchors.centerIn: parent; text: "FINISH"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } } }
                            }
                            Text {
                                text: "Choose an icon style designed for high-contrast dark workspaces. All themes use hardware-accelerated vector rendering."
                                color: root.textSub
                                font { family: root.mono; pixelSize: 11 }
                                width: parent.width
                            }

                            readonly property var iconThemes: [
                                { id: "Synapse-Liquid-Chrome",   name: "Liquid Mauve Chrome (Default)", col: "#cba6f7", desc: "High-gloss mirror chrome finish with 45° diamond chamfers and liquid mauve sheen." },
                                { id: "Synapse-Smoked-Obsidian", name: "Smoked Obsidian & Neon",        col: "#b4befe", desc: "Mirror-finish jet-black ceramic dish with knurled metal rim and glowing purple conduit." },
                                { id: "Synapse-Radial-Tungsten", name: "Radial Milled Tungsten",        col: "#fab387", desc: "Concentric lathe tool marks with anisotropic cross-reflection and singularity torus." },
                                { id: "Synapse-Aerospace-Billet",name: "Aerospace Billet & Satin",      col: "#74c7ec", desc: "Brushed titanium chassis plate with bead-blasted satin mauve pocket and micro-bolts." }
                            ]

                            Repeater {
                                model: parent.iconThemes
                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: 62
                                    radius: 6
                                    color: (root.backendIconTheme === modelData.id) ? root.surfaceContainer : root.surfaceCard
                                    border.color: (root.backendIconTheme === modelData.id) ? modelData.col : root.borderMuted
                                    border.width: (root.backendIconTheme === modelData.id) ? 1.5 : 1

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

                            Item { width: parent.width; height: 8 }
                        }
                    }
                }

                // ========================================================
                // STEP 5: VISUAL THEME — Wallpaper & Accent Variant
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 4

                    ScrollView {
                        anchors.fill: parent
                        contentWidth: parent.width
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 10

                            Row {
                                spacing: 8
                                Text {
                                    text: "Step 5 · Visual Theme"
                                    color: root.accent
                                    font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                                }
                                Rectangle { width: 68; height: 16; radius: 3; color: "#09090d"; border.color: root.accent; Text { anchors.centerIn: parent; text: "PALETTE"; color: root.accent; font { family: root.mono; pixelSize: 8; bold: true } } }
                            }
                            Text {
                                text: "Pick your accent color and wallpaper. Your choice syncs across the login screen, taskbar, and HUD border glow."
                                color: root.textSub
                                font { family: root.mono; pixelSize: 11 }
                                width: parent.width
                            }

                            readonly property var wallpapers: [
                                { id: "monolith-mauve",    name: "Monolith · Mauve (Default)", col: "#cba6f7", desc: "Classic monolithic geometry in deep Mauve" },
                                { id: "tower-mauve",       name: "Basalt Tower · Mauve",        col: "#cba6f7", desc: "Brutalist cyberdeck pillars under ultraviolet aurora" },
                                { id: "carbon-mauve",      name: "Forged Carbon · Mauve",       col: "#cba6f7", desc: "High-density forged carbon weave with violet accents" },
                                { id: "monolith-tungsten", name: "Monolith · Tungsten",         col: "#fab387", desc: "Industrial warm tungsten anodized finish" },
                                { id: "carbon-crimson",    name: "Forged Carbon · Crimson",     col: "#f38ba8", desc: "High-contrast stealth crimson weave" },
                                { id: "monolith-sapphire", name: "Monolith · Sapphire",         col: "#74c7ec", desc: "Cold aerospace sapphire chrome" },
                                { id: "monolith-emerald",  name: "Monolith · Emerald",          col: "#a6e3a1", desc: "Matrix phosphor terminal green" }
                            ]

                            Grid {
                                width: parent.width
                                columns: 3
                                spacing: 8

                                Repeater {
                                    model: parent.wallpapers
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - 16) / 3
                                        height: 46
                                        radius: 6
                                        color: (root.variant === modelData.id) ? root.surfaceContainer : root.surfaceCard
                                        border.color: (root.variant === modelData.id) ? modelData.col : root.borderMuted
                                        border.width: (root.variant === modelData.id) ? 1.5 : 1

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8

                                            Rectangle {
                                                width: 12; height: 12; radius: 6; anchors.verticalCenter: parent.verticalCenter
                                                color: modelData.col; border.color: "#ffffff"; border.width: 1
                                            }

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                width: parent.width - 28

                                                Text { text: modelData.name; color: "#ffffff"; font.family: root.mono; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                                Text { text: modelData.desc; color: root.textSub; font.family: root.mono; font.pixelSize: 8; elide: Text.ElideRight; width: parent.width }
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

                            Item { width: parent.width; height: 8 }
                        }
                    }
                }

                // ========================================================
                // STEP 6: LAUNCH — System Verification & Cockpit Launch
                // ========================================================
                Item {
                    anchors.fill: parent
                    visible: root.currentStep === 5

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Row {
                            spacing: 8
                            Text {
                                text: "Step 6 · Launch"
                                color: root.accent
                                font { family: root.mono; pixelSize: 13; bold: true; letterSpacing: 1.2 }
                            }
                            Rectangle { width: 84; height: 16; radius: 3; color: "#09090d"; border.color: "#a6e3a1"; Text { anchors.centerIn: parent; text: "VERIFIED [✓]"; color: "#a6e3a1"; font { family: root.mono; pixelSize: 8; bold: true } } }
                        }
                        Text {
                            text: "All settings configured. Review your choices below and hit the button to launch your desktop."
                            color: root.textSub
                            font { family: root.mono; pixelSize: 11 }
                        }

                        // Master Diagnostic Readout (Pre-flight Checklist)
                        Rectangle {
                            width: parent.width
                            height: 140
                            radius: 6
                            color: "#07070c"
                            border.color: root.withAlpha(root.accent, 0.40)
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4

                                Text {
                                    textFormat: Text.StyledText
                                    text: "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>USERNAME:</b> <font color='" + root.accent + "'>" + root.backendOperator + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>HOSTNAME:</b> <font color='#74c7ec'>" + root.backendHostname + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>AI ENGINE:</b> <font color='#fab387'>" + root.backendAiEngine.toUpperCase() + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>ICON SUITE:</b> <font color='#ffffff'>" + root.backendIconTheme + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>THEME:</b> <font color='" + root.accent + "'>" + root.variant.toUpperCase() + "</font><br>" +
                                          "<font color='#a6e3a1'>[&nbsp;&nbsp;OK&nbsp;&nbsp;]</font> <b>PRIVACY:</b> <font color='#a6e3a1'>Quad9 DoT · MAC Randomization · BORE Scheduler</font>"
                                    color: root.textSub
                                    font { family: root.mono; pixelSize: 11 }
                                }
                            }
                        }

                        // Mnemonic Keybinding Cheat Sheet Tiles
                        Rectangle {
                            width: parent.width
                            height: 90
                            radius: 6
                            color: root.surfaceCard
                            border.color: root.borderMuted

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text { text: "KEYBOARD SHORTCUTS [ SUPER + KEY ]:"; color: "#fab387"; font { family: root.mono; pixelSize: 10; bold: true } }

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
                                                width: 72; height: 18; radius: 3; color: "#06060a"; border.color: "#45475a"
                                                Text { anchors.centerIn: parent; text: modelData[0]; color: "#ffffff"; font { family: root.mono; pixelSize: 9; bold: true } }
                                            }
                                            Text { text: modelData[1]; color: root.textSub; font { family: root.mono; pixelSize: 10 } }
                                        }
                                    }
                                }
                            }
                        }

                        // Quick Launcher Action Tiles
                        Row {
                            width: parent.width
                            height: 34
                            spacing: 8

                            Rectangle {
                                width: (parent.width - 16) / 3; height: parent.height; radius: 4; color: "#141422"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ OPEN COMMAND HUD ]"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("synapse-hud") }
                            }
                            Rectangle {
                                width: (parent.width - 16) / 3; height: parent.height; radius: 4; color: "#141422"; border.color: root.borderMuted
                                Text { anchors.centerIn: parent; text: "[ INSTALL DISK (CALAMARES) ]"; color: root.accent; font { family: root.mono; pixelSize: 10; bold: true } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof backend !== "undefined" && backend) backend.launchCmd("calamares -d") }
                            }
                            Rectangle {
                                width: (parent.width - 16) / 3; height: parent.height; radius: 4; color: "#141422"; border.color: root.borderMuted
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
                color: root.withAlpha(root.accent, 0.40)
            }

            // ================================================================
            // 4. BOTTOM NAVIGATION BAR
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
                        text: "ORBITAL STAGE 0" + (root.currentStep + 1) + " // 06"
                        color: root.textSub
                        font { family: root.mono; pixelSize: 11; bold: true; letterSpacing: 1.0 }
                    }
                }

                // Next / Finish Action Button
                Rectangle {
                    width: root.currentStep === root.totalSteps - 1 ? 240 : 160
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
