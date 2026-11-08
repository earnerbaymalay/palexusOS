// SynapseOS — First-run setup (Qt6 / QtQuick)
// Linear, keyboard-first wizard in the greeter's chamfered obsidian style.
//   Live ISO  : Welcome (Try / Install) -> Look -> Done
//   Installed : Welcome -> Look -> Assistant -> Privacy -> Keys -> Done
// Keys: Enter = continue · Alt+Left = back · Esc = skip setup · Tab = move focus

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Window {
    id: root
    width: 920
    height: 640
    visible: true
    title: "SynapseOS Setup"
    flags: Qt.FramelessWindowHint | Qt.Dialog
    color: "transparent"

    // ---- Backend access (falls back to defaults so the file previews without one) ----
    readonly property bool hasBackend: typeof backend !== "undefined" && backend !== null
    function bk(name, fallback) { return (hasBackend && backend[name] !== undefined) ? backend[name] : fallback }

    readonly property bool isLive: bk("isLive", false)
    readonly property bool reduceMotion: bk("reduceMotion", false)
    readonly property string variant: bk("variant", "monolith-mauve")
    readonly property string scene: variant.split("-")[0]
    readonly property string accentName: variant.split("-")[1]
    readonly property string iconTheme: bk("iconTheme", "Synapse-Liquid-Chrome")
    readonly property string aiEngine: bk("aiEngine", "local")
    readonly property string modelTier: bk("modelTier", "light")
    readonly property bool downloadModels: bk("downloadModels", false)
    readonly property real ramGb: bk("ramGb", 0)
    readonly property string claudeKey: bk("claudeApiKey", "")
    readonly property string keyState: bk("keyTestState", "idle")

    // ---- Design tokens ----
    readonly property var accents: ({
        mauve: "#cba6f7", tungsten: "#fab387", crimson: "#f38ba8",
        sapphire: "#74c7ec", emerald: "#a6e3a1"
    })
    readonly property var sceneLabels: ({ monolith: "Monolith", tower: "Basalt Tower", carbon: "Forged Carbon" })
    readonly property color accent: accents[accentName] || accents.mauve
    readonly property color accentInk: "#11111b"
    readonly property color slab: Qt.rgba(13 / 255, 14 / 255, 21 / 255, 0.97)
    readonly property color surface: "#151522"
    readonly property color surfaceContainer: "#1c1c2e"
    readonly property color raised: "#25253a"
    readonly property color border: "#313244"
    readonly property color textMain: "#cdd6f4"
    readonly property color textSub: "#bac2de"
    readonly property color textMuted: "#9399b2"   // 6.2:1 on surface
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property int motion: reduceMotion ? 0 : 160

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
    function cap(s) { return s.charAt(0).toUpperCase() + s.slice(1) }
    function iconLabel(t) { return t.replace("Synapse-", "").replace("-", " ") }
    function tierSize(t) { return hasBackend ? backend.tierSizeGb(t) : (t === "standard" ? 7.0 : 3.3) }

    // ---- Step machine ----
    readonly property var steps: isLive ? ["welcome", "appearance", "done"]
                                        : ["welcome", "appearance", "ai", "privacy", "keys", "done"]
    readonly property var stepTitles: ({ welcome: "Welcome", appearance: "Look", ai: "Assistant",
                                         privacy: "Privacy", keys: "Keys", done: "Done" })
    property int stepIndex: 0
    property int furthest: 0
    readonly property string step: steps[stepIndex]
    property bool liveInstall: false
    property bool confirmSkip: false

    readonly property bool canContinue: !(step === "ai" && aiEngine === "claude" && claudeKey === "")
    readonly property string primaryLabel: step === "welcome" ? (isLive ? (liveInstall ? "Open installer" : "Next") : "Get started")
                                         : step === "done" ? "Finish" : "Next"

    function go(i) {
        stepIndex = Math.max(0, Math.min(steps.length - 1, i))
        furthest = Math.max(furthest, stepIndex)
        confirmSkip = false
        primaryBtn.forceActiveFocus()
    }
    function next() {
        if (!canContinue) return
        if (step === "welcome" && isLive && liveInstall) { if (hasBackend) backend.startInstaller(); else root.close(); return }
        if (step === "done") { if (hasBackend) backend.finish(); else root.close(); return }
        go(stepIndex + 1)
    }
    function back() { if (stepIndex > 0) go(stepIndex - 1) }
    function skip() { if (hasBackend) backend.skip(); else root.close() }

    // ====================================================================
    // Reusable controls
    // ====================================================================

    component T: Text {
        color: root.textMain
        font.family: root.mono
        font.pixelSize: 14
        wrapMode: Text.WordWrap
    }

    component FocusRing: Rectangle {
        property real r: 8
        anchors.fill: parent
        anchors.margins: -3
        radius: r + 3
        color: "transparent"
        border.width: 2
        border.color: root.accent
    }

    component Btn: Rectangle {
        id: btn
        property string text
        property string kind: "secondary"      // primary | secondary | ghost
        signal activated()
        implicitWidth: Math.max(kind === "ghost" ? 0 : 112, label.implicitWidth + 32)
        implicitHeight: 40
        radius: 8
        activeFocusOnTab: true
        opacity: enabled ? 1 : 0.45
        color: kind === "primary" ? (mouse.pressed ? Qt.darker(root.accent, 1.15) : mouse.containsMouse ? Qt.lighter(root.accent, 1.06) : root.accent)
             : kind === "secondary" ? (mouse.pressed ? root.surface : mouse.containsMouse ? root.raised : root.surfaceContainer)
             : (mouse.containsMouse ? root.surfaceContainer : "transparent")
        border.width: kind === "secondary" ? 1 : 0
        border.color: root.border
        Behavior on color { ColorAnimation { duration: root.motion } }

        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.onPressAction: if (enabled) activated()
        Keys.onReturnPressed: if (enabled) activated()
        Keys.onEnterPressed: if (enabled) activated()
        Keys.onSpacePressed: if (enabled) activated()

        Text {
            id: label
            anchors.centerIn: parent
            text: btn.text
            color: btn.kind === "primary" ? root.accentInk : root.textMain
            font.family: root.mono; font.pixelSize: 13; font.bold: btn.kind !== "ghost"
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: { btn.forceActiveFocus(); btn.activated() }
        }
        FocusRing { r: btn.radius; visible: btn.activeFocus }
    }

    // Selectable card that behaves like a radio button
    component Choice: Rectangle {
        id: ch
        property string title
        property string desc
        property string badge
        property bool selected
        signal picked()
        implicitHeight: Math.max(64, body.implicitHeight + 26)
        radius: 10
        activeFocusOnTab: true
        color: selected ? root.withAlpha(root.accent, 0.10) : (cm.containsMouse ? root.raised : root.surfaceContainer)
        border.width: selected ? 2 : 1
        border.color: selected ? root.accent : root.border
        Behavior on color { ColorAnimation { duration: root.motion } }

        Accessible.role: Accessible.RadioButton
        Accessible.name: title
        Accessible.description: desc
        Accessible.checkable: true
        Accessible.checked: selected
        Accessible.onPressAction: picked()
        Keys.onSpacePressed: picked()

        RowLayout {
            id: body
            anchors.fill: parent
            anchors.margins: 13
            spacing: 14

            Rectangle {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 2
                width: 18; height: 18; radius: 9
                color: "transparent"
                border.width: 2
                border.color: ch.selected ? root.accent : root.textMuted
                Rectangle {
                    anchors.centerIn: parent
                    width: 8; height: 8; radius: 4
                    color: root.accent
                    visible: ch.selected
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    spacing: 10
                    T { text: ch.title; font.bold: true; color: "#ffffff"; wrapMode: Text.NoWrap }
                    Rectangle {
                        visible: ch.badge !== ""
                        implicitWidth: badgeText.implicitWidth + 14
                        implicitHeight: 20
                        radius: 4
                        color: root.withAlpha(root.accent, 0.16)
                        T { id: badgeText; anchors.centerIn: parent; text: ch.badge; color: root.accent; font.pixelSize: 11; font.bold: true }
                    }
                }
                T { Layout.fillWidth: true; text: ch.desc; color: root.textSub; font.pixelSize: 13; visible: ch.desc !== "" }
            }
        }
        MouseArea {
            id: cm
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { ch.forceActiveFocus(); ch.picked() }
        }
        FocusRing { r: ch.radius; visible: ch.activeFocus }
    }

    component Toggle: Item {
        id: tg
        property string text
        property string detail
        property bool checked
        signal toggled()
        implicitWidth: 360
        implicitHeight: Math.max(26, tgText.implicitHeight)
        activeFocusOnTab: true
        Accessible.role: Accessible.CheckBox
        Accessible.name: text
        Accessible.checkable: true
        Accessible.checked: checked
        Accessible.onToggleAction: toggled()
        Keys.onSpacePressed: toggled()

        RowLayout {
            anchors.fill: parent
            spacing: 12
            Rectangle {
                Layout.alignment: Qt.AlignTop
                width: 42; height: 24; radius: 12
                color: tg.checked ? root.withAlpha(root.accent, 0.35) : root.surface
                border.width: 1.5
                border.color: tg.checked ? root.accent : root.textMuted
                Rectangle {
                    width: 16; height: 16; radius: 8; y: 4
                    x: tg.checked ? 22 : 4
                    color: tg.checked ? root.accent : root.textMuted
                    Behavior on x { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } }
                }
                FocusRing { r: 12; visible: tg.activeFocus }
            }
            ColumnLayout {
                id: tgText
                Layout.fillWidth: true
                spacing: 2
                T { Layout.fillWidth: true; text: tg.text; font.bold: true }
                T { Layout.fillWidth: true; text: tg.detail; color: root.textMuted; font.pixelSize: 12; visible: tg.detail !== "" }
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { tg.forceActiveFocus(); tg.toggled() }
        }
    }

    component Keycap: Rectangle {
        property string label
        implicitWidth: Math.max(30, capText.implicitWidth + 16)
        implicitHeight: 28
        radius: 5
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#2a2a40" }
            GradientStop { position: 1.0; color: "#18182a" }
        }
        border.color: "#45475a"
        T { id: capText; anchors.centerIn: parent; text: parent.label; font.pixelSize: 12; font.bold: true; wrapMode: Text.NoWrap }
    }

    component PageHeader: ColumnLayout {
        property string title
        property string subtitle
        Layout.fillWidth: true
        spacing: 6
        T { text: parent.title; color: "#ffffff"; font.pixelSize: 22; font.bold: true }
        T { Layout.fillWidth: true; text: parent.subtitle; color: root.textSub; visible: text !== "" }
    }

    // Fading page container; only the current step is visible and focusable
    component Page: Item {
        property string name
        readonly property bool current: root.step === name
        anchors.fill: parent
        opacity: current ? 1 : 0
        visible: opacity > 0
        enabled: current
        transform: Translate { x: current ? 0 : 14; Behavior on x { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: root.motion } }
    }

    // ====================================================================
    // Window chrome
    // ====================================================================

    FocusScope {
        id: panel
        anchors.fill: parent
        anchors.margins: 12
        focus: true
        readonly property real c: 18

        Keys.onEscapePressed: root.confirmSkip = !root.confirmSkip
        Keys.onReturnPressed: if (!root.confirmSkip) root.next()
        Keys.onEnterPressed: if (!root.confirmSkip) root.next()
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left && (event.modifiers & Qt.AltModifier)) { root.back(); event.accepted = true }
            else if (event.key === Qt.Key_Right && (event.modifiers & Qt.AltModifier)) { root.next(); event.accepted = true }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent"
            border.color: root.accent
            border.width: 1
            opacity: 0.30
            radius: panel.c + 2
            Behavior on border.color { ColorAnimation { duration: root.motion * 2 } }
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 1.5
                strokeColor: root.border
                fillColor: root.slab
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

        // Single slow light trail, the greeter's signature; off with reduced motion
        Shape {
            id: trail
            anchors.fill: parent
            visible: !root.reduceMotion
            opacity: 0.7
            readonly property real perim: 2 * (panel.width + panel.height)
            property real offset: 0
            NumberAnimation on offset {
                running: trail.visible
                loops: Animation.Infinite
                from: trail.perim; to: 0
                duration: 12000
            }
            ShapePath {
                strokeColor: root.accent
                strokeWidth: 2
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [10, 160]
                dashOffset: trail.offset
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

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 22
            anchors.bottomMargin: 22
            spacing: 18

            // ---- Header: brand, step counter, close ----
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Image {
                    id: logo
                    Layout.preferredWidth: 30; Layout.preferredHeight: 30
                    source: root.bk("chromeLogoPath", "") ? "file://" + root.bk("chromeLogoPath", "") : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true; mipmap: true
                    visible: status === Image.Ready
                    Accessible.ignored: true
                }
                T { text: "SYNAPSEOS"; color: "#ffffff"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 1.5 }
                T { text: root.isLive ? "Live session" : "Setup"; color: root.textMuted; font.pixelSize: 13 }
                Item { Layout.fillWidth: true }
                T {
                    text: "Step " + (root.stepIndex + 1) + " of " + root.steps.length
                    color: root.textMuted; font.pixelSize: 13
                }
                Btn {
                    kind: "ghost"
                    text: "✕"
                    implicitWidth: 40
                    Accessible.name: "Close setup"
                    onActivated: root.confirmSkip = true
                }
            }

            // ---- Progress rail (completed steps are clickable) ----
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: root.steps
                    delegate: Item {
                        id: seg
                        required property string modelData
                        required property int index
                        readonly property bool done: index < root.stepIndex
                        readonly property bool here: index === root.stepIndex
                        readonly property bool reachable: index <= root.furthest && !here
                        Layout.fillWidth: true
                        implicitHeight: 34
                        activeFocusOnTab: reachable
                        Accessible.role: Accessible.PageTab
                        Accessible.name: root.stepTitles[modelData] + (here ? ", current step" : done ? ", done" : "")
                        Keys.onReturnPressed: if (reachable) root.go(index)
                        Keys.onSpacePressed: if (reachable) root.go(index)

                        Rectangle {
                            id: bar
                            width: parent.width; height: 4; radius: 2
                            color: seg.here || seg.done ? root.accent : root.border
                            opacity: seg.done ? 0.6 : 1
                            Behavior on color { ColorAnimation { duration: root.motion } }
                        }
                        T {
                            anchors.top: bar.bottom; anchors.topMargin: 8
                            text: (seg.done ? "✓ " : "") + root.stepTitles[seg.modelData]
                            color: seg.here ? "#ffffff" : seg.done ? root.textSub : root.textMuted
                            font.pixelSize: 12; font.bold: seg.here
                            wrapMode: Text.NoWrap
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: seg.reachable
                            cursorShape: seg.reachable ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.go(seg.index)
                        }
                        FocusRing { r: 4; visible: seg.activeFocus }
                    }
                }
            }

            // ====================================================================
            // Pages
            // ====================================================================
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // ---- 1. Welcome ----
                Page {
                    name: "welcome"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 22

                        RowLayout {
                            spacing: 22
                            Image {
                                Layout.preferredWidth: 88; Layout.preferredHeight: 88
                                source: logo.source
                                fillMode: Image.PreserveAspectFit
                                smooth: true; mipmap: true
                                visible: status === Image.Ready
                                Accessible.ignored: true
                            }
                            PageHeader {
                                title: "Welcome, " + root.bk("displayName", "there") + "."
                                subtitle: root.isLive
                                    ? "You're running SynapseOS from the USB stick. Nothing is installed on this computer yet."
                                    : "SynapseOS is a private, keyboard-first Arch workspace with a built-in AI assistant. Setup takes about two minutes, and you can change everything later."
                            }
                        }

                        // Live: choose between trying and installing
                        ColumnLayout {
                            visible: root.isLive
                            Layout.fillWidth: true
                            spacing: 10
                            Choice {
                                Layout.fillWidth: true
                                title: "Try SynapseOS"
                                desc: "Pick a look and explore. Changes last until you shut down. You can install any time from the bar or with Super+I."
                                selected: !root.liveInstall
                                onPicked: root.liveInstall = false
                            }
                            Choice {
                                Layout.fillWidth: true
                                title: "Install SynapseOS"
                                desc: "Open the installer now. The look you choose in this session carries over to the installed system."
                                selected: root.liveInstall
                                onPicked: root.liveInstall = true
                            }
                        }

                        // Installed: preview of what's ahead
                        Rectangle {
                            visible: !root.isLive
                            Layout.fillWidth: true
                            implicitHeight: agenda.implicitHeight + 32
                            radius: 10
                            color: root.surfaceContainer
                            border.color: root.border
                            ColumnLayout {
                                id: agenda
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12
                                T { text: "What we'll set up"; color: root.textMuted; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1 }
                                Repeater {
                                    model: [
                                        { n: "1", t: "A look", d: "Wallpaper scene, accent colour and icon style." },
                                        { n: "2", t: "Your AI assistant", d: "Local and private, Claude in the cloud, or off." },
                                        { n: "3", t: "A privacy check", d: "What's protecting you right now, read from this system." },
                                        { n: "4", t: "Five keys", d: "Enough to get around without the mouse." }
                                    ]
                                    delegate: RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 14
                                        Rectangle {
                                            width: 26; height: 26; radius: 13
                                            color: root.withAlpha(root.accent, 0.16)
                                            T { anchors.centerIn: parent; text: modelData.n; color: root.accent; font.pixelSize: 12; font.bold: true }
                                        }
                                        T { text: modelData.t; font.bold: true; Layout.preferredWidth: 190; wrapMode: Text.NoWrap }
                                        T { text: modelData.d; color: root.textSub; font.pixelSize: 13; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // ---- 2. Appearance ----
                Page {
                    name: "appearance"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        PageHeader {
                            title: "Choose a look"
                            subtitle: "The wallpaper behind this window updates as you choose."
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 24

                            // Live preview
                            ColumnLayout {
                                Layout.preferredWidth: 380
                                Layout.alignment: Qt.AlignTop
                                spacing: 10
                                Rectangle {
                                    Layout.preferredWidth: 380
                                    Layout.preferredHeight: 214
                                    radius: 10
                                    color: root.surface
                                    border.width: 2
                                    border.color: root.accent
                                    clip: true
                                    Image {
                                        id: preview
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: root.hasBackend ? backend.wallpaperUrl(root.variant) : ""
                                        sourceSize.width: 760
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        Accessible.role: Accessible.Graphic
                                        Accessible.name: "Wallpaper preview: " + root.sceneLabels[root.scene] + ", " + root.accentName
                                    }
                                    T {
                                        anchors.centerIn: parent
                                        visible: preview.status !== Image.Ready
                                        text: "Preview unavailable"
                                        color: root.textMuted
                                    }
                                }
                                T {
                                    text: root.sceneLabels[root.scene] + " · " + root.cap(root.accentName)
                                    font.bold: true
                                }
                                T {
                                    Layout.fillWidth: true
                                    text: root.iconLabel(root.iconTheme) + " icons"
                                    color: root.textMuted; font.pixelSize: 13
                                }
                            }

                            // Pickers
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                spacing: 10

                                T { text: "Scene"; color: root.textMuted; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1 }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    Repeater {
                                        model: ["monolith", "tower", "carbon"]
                                        delegate: Rectangle {
                                            id: sceneTile
                                            required property string modelData
                                            readonly property bool selected: root.scene === modelData
                                            readonly property string thumbAccent: root.hasBackend && backend.variantExists(modelData, root.accentName) ? root.accentName : "mauve"
                                            Layout.fillWidth: true
                                            implicitHeight: 92
                                            radius: 8
                                            color: root.surfaceContainer
                                            border.width: selected ? 2 : 1
                                            border.color: selected ? root.accent : root.border
                                            activeFocusOnTab: true
                                            Accessible.role: Accessible.RadioButton
                                            Accessible.name: root.sceneLabels[modelData]
                                            Accessible.checkable: true
                                            Accessible.checked: selected
                                            Accessible.onPressAction: pick()
                                            Keys.onSpacePressed: pick()
                                            function pick() { if (root.hasBackend) backend.chooseVariant(modelData, root.accentName) }

                                            Image {
                                                anchors.fill: parent
                                                anchors.margins: 3
                                                anchors.bottomMargin: 26
                                                source: root.hasBackend ? backend.wallpaperUrl(sceneTile.modelData + "-" + sceneTile.thumbAccent) : ""
                                                sourceSize.width: 260
                                                fillMode: Image.PreserveAspectCrop
                                                asynchronous: true
                                                Accessible.ignored: true
                                            }
                                            T {
                                                anchors.bottom: parent.bottom; anchors.bottomMargin: 5
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: root.sceneLabels[sceneTile.modelData]
                                                color: sceneTile.selected ? "#ffffff" : root.textSub
                                                font.pixelSize: 12; font.bold: sceneTile.selected
                                                wrapMode: Text.NoWrap
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: { sceneTile.forceActiveFocus(); sceneTile.pick() }
                                            }
                                            FocusRing { r: 8; visible: sceneTile.activeFocus }
                                        }
                                    }
                                }

                                T { Layout.topMargin: 6; text: "Accent"; color: root.textMuted; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1 }
                                RowLayout {
                                    spacing: 12
                                    Repeater {
                                        model: ["mauve", "tungsten", "crimson", "sapphire", "emerald"]
                                        delegate: Rectangle {
                                            id: sw
                                            required property string modelData
                                            readonly property bool available: !root.hasBackend || backend.variantExists(root.scene, modelData)
                                            readonly property bool selected: root.accentName === modelData
                                            width: 40; height: 40; radius: 20
                                            color: root.accents[modelData]
                                            opacity: available ? 1 : 0.25
                                            border.width: selected ? 3 : 0
                                            border.color: "#ffffff"
                                            activeFocusOnTab: available
                                            Accessible.role: Accessible.RadioButton
                                            Accessible.name: root.cap(modelData) + (available ? "" : ", not available for this scene")
                                            Accessible.checkable: true
                                            Accessible.checked: selected
                                            Accessible.onPressAction: pick()
                                            Keys.onSpacePressed: pick()
                                            function pick() { if (available && root.hasBackend) backend.chooseVariant(root.scene, modelData) }

                                            T {
                                                anchors.centerIn: parent
                                                visible: sw.selected
                                                text: "✓"; color: root.accentInk; font.bold: true; font.pixelSize: 16
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                enabled: sw.available
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: { sw.forceActiveFocus(); sw.pick() }
                                            }
                                            FocusRing { r: 20; visible: sw.activeFocus }
                                        }
                                    }
                                }
                                T {
                                    Layout.fillWidth: true
                                    visible: root.scene === "monolith"
                                    text: "Crimson isn't available for Monolith."
                                    color: root.textMuted; font.pixelSize: 12
                                }

                                T { Layout.topMargin: 6; text: "Icons"; color: root.textMuted; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1 }
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 8; columnSpacing: 8
                                    Repeater {
                                        model: root.bk("iconThemes", ["Synapse-Liquid-Chrome", "Synapse-Smoked-Obsidian", "Synapse-Radial-Tungsten", "Synapse-Aerospace-Billet"])
                                        delegate: Rectangle {
                                            id: iconTile
                                            required property string modelData
                                            readonly property bool selected: root.iconTheme === modelData
                                            Layout.fillWidth: true
                                            implicitHeight: 46
                                            radius: 8
                                            color: selected ? root.withAlpha(root.accent, 0.10) : (im.containsMouse ? root.raised : root.surfaceContainer)
                                            border.width: selected ? 2 : 1
                                            border.color: selected ? root.accent : root.border
                                            activeFocusOnTab: true
                                            Accessible.role: Accessible.RadioButton
                                            Accessible.name: root.iconLabel(modelData) + " icons"
                                            Accessible.checkable: true
                                            Accessible.checked: selected
                                            Accessible.onPressAction: pick()
                                            Keys.onSpacePressed: pick()
                                            function pick() { if (root.hasBackend) backend.iconTheme = modelData }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 6
                                                Repeater {
                                                    model: root.hasBackend ? backend.iconSamples(iconTile.modelData) : []
                                                    delegate: Image {
                                                        required property string modelData
                                                        Layout.preferredWidth: 22; Layout.preferredHeight: 22
                                                        source: modelData
                                                        sourceSize: Qt.size(44, 44)
                                                        Accessible.ignored: true
                                                    }
                                                }
                                                T {
                                                    Layout.fillWidth: true
                                                    Layout.leftMargin: 4
                                                    text: root.iconLabel(iconTile.modelData)
                                                    color: iconTile.selected ? "#ffffff" : root.textSub
                                                    font.pixelSize: 12
                                                    elide: Text.ElideRight
                                                    wrapMode: Text.NoWrap
                                                }
                                            }
                                            MouseArea {
                                                id: im
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: { iconTile.forceActiveFocus(); iconTile.pick() }
                                            }
                                            FocusRing { r: 8; visible: iconTile.activeFocus }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ---- 3. AI assistant ----
                Page {
                    name: "ai"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        PageHeader {
                            title: "Pick your AI assistant"
                            subtitle: "It answers questions in the Command HUD (Super+Space) and helps in the terminal."
                        }

                        Choice {
                            Layout.fillWidth: true
                            title: "Local, on this computer"
                            badge: "Recommended"
                            desc: "Runs with Ollama. Nothing you type leaves this device, and it works offline."
                            selected: root.aiEngine === "local"
                            onPicked: if (root.hasBackend) backend.aiEngine = "local"
                        }
                        Choice {
                            Layout.fillWidth: true
                            title: "Claude, in the cloud"
                            desc: "Anthropic's " + root.bk("claudeModel", "Claude") + ". Stronger answers, but your prompts are sent to Anthropic. Needs an API key."
                            selected: root.aiEngine === "claude"
                            onPicked: if (root.hasBackend) backend.aiEngine = "claude"
                        }
                        Choice {
                            Layout.fillWidth: true
                            title: "No assistant for now"
                            desc: "You can turn it on later in Settings."
                            selected: root.aiEngine === "none"
                            onPicked: if (root.hasBackend) backend.aiEngine = "none"
                        }

                        // Local details: model size + download consent
                        ColumnLayout {
                            visible: root.aiEngine === "local"
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            spacing: 10
                            T {
                                Layout.fillWidth: true
                                text: root.ramGb > 0 ? "This computer has " + root.ramGb.toFixed(0) + " GB of memory." : "Model size"
                                color: root.textMuted; font.pixelSize: 13
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                Choice {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    title: "Light"
                                    badge: root.ramGb > 0 && root.ramGb < 12 ? "Fits best" : ""
                                    desc: "About " + root.tierSize("light").toFixed(1) + " GB download. Good on 8 GB of memory."
                                    selected: root.modelTier === "light"
                                    onPicked: if (root.hasBackend) backend.modelTier = "light"
                                }
                                Choice {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    title: "Standard"
                                    badge: root.ramGb >= 12 ? "Fits best" : ""
                                    desc: "About " + root.tierSize("standard").toFixed(1) + " GB download. Better code help; wants 12 GB or more."
                                    selected: root.modelTier === "standard"
                                    onPicked: if (root.hasBackend) backend.modelTier = "standard"
                                }
                            }
                            Toggle {
                                Layout.fillWidth: true
                                text: "Download the models when I finish"
                                detail: root.downloadModels
                                    ? "Runs in the background at low priority. You'll get a notification when it's ready."
                                    : "Nothing will be downloaded. Run synapse-setup --pull-core whenever you're ready."
                                checked: root.downloadModels
                                onToggled: if (root.hasBackend) backend.downloadModels = !root.downloadModels
                            }
                        }

                        // Claude details: key entry + real connection test
                        ColumnLayout {
                            visible: root.aiEngine === "claude"
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            spacing: 8
                            T { text: "Anthropic API key"; font.bold: true; font.pixelSize: 13 }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 40
                                    radius: 8
                                    color: root.surface
                                    border.width: keyBox.activeFocus ? 2 : 1
                                    border.color: keyBox.activeFocus ? root.accent : root.border
                                    TextInput {
                                        id: keyBox
                                        property bool reveal: false
                                        anchors.fill: parent
                                        anchors.leftMargin: 12; anchors.rightMargin: 12
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: root.claudeKey
                                        color: "#ffffff"
                                        echoMode: reveal ? TextInput.Normal : TextInput.Password
                                        font.family: root.mono; font.pixelSize: 13
                                        selectByMouse: true
                                        selectionColor: root.accent
                                        selectedTextColor: root.accentInk
                                        clip: true
                                        activeFocusOnTab: true
                                        Accessible.role: Accessible.EditableText
                                        Accessible.name: "Anthropic API key"
                                        onTextEdited: if (root.hasBackend) backend.claudeApiKey = text
                                        onAccepted: if (root.hasBackend) backend.testClaudeKey()
                                        T {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "sk-ant-…"
                                            color: root.textMuted
                                            visible: keyBox.text === "" && !keyBox.activeFocus
                                        }
                                    }
                                }
                                Btn {
                                    text: keyBox.reveal ? "Hide" : "Show"
                                    Accessible.name: keyBox.reveal ? "Hide API key" : "Show API key"
                                    implicitWidth: 76
                                    onActivated: keyBox.reveal = !keyBox.reveal
                                }
                                Btn {
                                    text: root.keyState === "testing" ? "Testing…" : "Test key"
                                    enabled: root.claudeKey !== "" && root.keyState !== "testing"
                                    onActivated: if (root.hasBackend) backend.testClaudeKey()
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                T {
                                    visible: root.keyState === "ok" || root.keyState === "error"
                                    text: root.keyState === "ok" ? "✓" : "!"
                                    color: root.keyState === "ok" ? root.success : root.warning
                                    font.bold: true
                                }
                                T {
                                    Layout.fillWidth: true
                                    text: root.claudeKey === ""
                                        ? "Paste a key to continue, or pick another option. Get one at console.anthropic.com."
                                        : (root.bk("keyTestMessage", "") || "Saved to ~/.config/synapse/anthropic_key, readable only by you.")
                                    color: root.keyState === "ok" ? root.success : root.keyState === "error" ? root.warning : root.textMuted
                                    font.pixelSize: 13
                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: text
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // ---- 4. Privacy check (read-only, real state) ----
                Page {
                    name: "privacy"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        PageHeader {
                            title: "Privacy check"
                            subtitle: "These protections are on by default. Here's what this system reports right now."
                        }

                        Repeater {
                            id: checks
                            model: root.bk("securityChecks", [])
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: row.implicitHeight + 22
                                radius: 8
                                color: root.surfaceContainer
                                border.color: root.border
                                Accessible.role: Accessible.StaticText
                                Accessible.name: modelData.label + ": " + (modelData.ok ? "active" : "needs attention") + ". " + modelData.detail
                                RowLayout {
                                    id: row
                                    anchors.fill: parent
                                    anchors.margins: 11
                                    spacing: 14
                                    Rectangle {
                                        width: 24; height: 24; radius: 12
                                        color: root.withAlpha(modelData.ok ? root.success : root.warning, 0.18)
                                        T { anchors.centerIn: parent; text: modelData.ok ? "✓" : "!"; color: modelData.ok ? root.success : root.warning; font.bold: true; font.pixelSize: 13 }
                                    }
                                    T { text: modelData.label; font.bold: true; Layout.preferredWidth: 210; wrapMode: Text.NoWrap }
                                    T { text: modelData.detail; color: root.textSub; font.pixelSize: 13; Layout.fillWidth: true }
                                    T {
                                        text: modelData.ok ? "Active" : "Check"
                                        color: modelData.ok ? root.success : root.warning
                                        font.pixelSize: 12; font.bold: true
                                        wrapMode: Text.NoWrap
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            spacing: 14
                            Btn {
                                text: "Open full audit"
                                onActivated: if (root.hasBackend) backend.openTool("audit")
                            }
                            T {
                                Layout.fillWidth: true
                                text: "The audit lists every network interface and shows how to fix anything marked Check. Super+P opens it later."
                                color: root.textMuted; font.pixelSize: 13
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // ---- 5. Keys ----
                Page {
                    name: "keys"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        PageHeader {
                            title: "Five keys to remember"
                            subtitle: "Super is the key with the Windows or Command logo."
                        }

                        Repeater {
                            model: [
                                { k: "Space",  t: "Command HUD",     d: "Launch apps, run commands, or ask the AI." },
                                { k: "Return", t: "Terminal",        d: "Kitty, GPU-accelerated." },
                                { k: "B",      t: "Browser",         d: "Chromium with telemetry turned off." },
                                { k: "F",      t: "Files",           d: "Thunar file manager." },
                                { k: "/",      t: "All shortcuts",   d: "The full cheat sheet, any time." }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 52
                                radius: 8
                                color: root.surfaceContainer
                                border.color: root.border
                                Accessible.role: Accessible.StaticText
                                Accessible.name: "Super plus " + modelData.k + ": " + modelData.t + ". " + modelData.d
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14; anchors.rightMargin: 14
                                    spacing: 8
                                    RowLayout {
                                        Layout.preferredWidth: 170
                                        spacing: 6
                                        Keycap { label: "Super" }
                                        T { text: "+"; color: root.textMuted; wrapMode: Text.NoWrap }
                                        Keycap { label: modelData.k }
                                    }
                                    T { text: modelData.t; font.bold: true; Layout.preferredWidth: 170; wrapMode: Text.NoWrap }
                                    T { text: modelData.d; color: root.textSub; font.pixelSize: 13; Layout.fillWidth: true }
                                }
                            }
                        }
                        T {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            text: "Super+W reopens this setup whenever you want to change something."
                            color: root.textMuted; font.pixelSize: 13
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // ---- 6. Done ----
                Page {
                    name: "done"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        PageHeader {
                            title: root.isLive ? "Ready to explore" : "You're all set"
                            subtitle: root.isLive
                                ? "Install whenever you like: click INSTALL SYNAPSEOS in the bar, or press Super+I. Your look carries over."
                                : "Here's what happens when you press Finish."
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: summary.implicitHeight + 32
                            radius: 10
                            color: root.surfaceContainer
                            border.color: root.border
                            ColumnLayout {
                                id: summary
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 14
                                Repeater {
                                    model: {
                                        var rows = [{
                                            t: "Look",
                                            d: root.sceneLabels[root.scene] + " · " + root.cap(root.accentName) + ", with " + root.iconLabel(root.iconTheme) + " icons."
                                        }]
                                        if (!root.isLive) {
                                            var ai = root.aiEngine === "local"
                                                ? (root.downloadModels
                                                    ? "Local (" + root.modelTier + "). About " + root.tierSize(root.modelTier).toFixed(1) + " GB downloads in the background; you'll be notified when it's ready."
                                                    : "Local (" + root.modelTier + "). Nothing downloads until you run synapse-setup --pull-core.")
                                                : root.aiEngine === "claude"
                                                    ? (root.keyState === "ok" ? "Claude, key verified." : "Claude. The key is saved but hasn't been tested.")
                                                    : "Off. Turn it on later in Settings."
                                            rows.push({ t: "Assistant", d: ai })
                                            rows.push({ t: "Next", d: "Press Super+Space to open the Command HUD." })
                                        }
                                        return rows
                                    }
                                    delegate: RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 14
                                        T { text: modelData.t; color: root.textMuted; font.bold: true; font.pixelSize: 13; Layout.preferredWidth: 110; wrapMode: Text.NoWrap }
                                        T { text: modelData.d; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }

                        Btn {
                            visible: root.isLive
                            text: "Open installer instead"
                            onActivated: if (root.hasBackend) backend.startInstaller()
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }

            // ---- Footer: skip / back / continue, or the skip confirmation ----
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: root.border
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: !root.confirmSkip

                Btn {
                    kind: "ghost"
                    text: "Skip setup"
                    visible: root.step !== "done"
                    onActivated: root.confirmSkip = true
                }
                Item { Layout.fillWidth: true }
                T {
                    text: "Enter to continue · Esc to skip"
                    color: root.textMuted; font.pixelSize: 12
                    wrapMode: Text.NoWrap
                }
                Btn {
                    text: "Back"
                    visible: root.stepIndex > 0
                    onActivated: root.back()
                }
                Btn {
                    id: primaryBtn
                    kind: "primary"
                    text: root.primaryLabel
                    enabled: root.canContinue
                    focus: true
                    onActivated: root.next()
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: root.confirmSkip
                onVisibleChanged: if (visible) keepGoing.forceActiveFocus()

                T {
                    Layout.fillWidth: true
                    text: root.isLive
                        ? "Skip setup? The desktop stays as it is."
                        : "Skip setup? Your current look stays and the AI assistant stays off. Super+W brings this back."
                    color: root.warning
                    font.pixelSize: 13
                    Accessible.role: Accessible.AlertMessage
                    Accessible.name: text
                }
                Btn {
                    id: keepGoing
                    text: "Keep setting up"
                    onActivated: { root.confirmSkip = false; primaryBtn.forceActiveFocus() }
                }
                Btn {
                    kind: "primary"
                    text: "Skip"
                    onActivated: root.skip()
                }
            }
        }
    }

    Component.onCompleted: primaryBtn.forceActiveFocus()
}
