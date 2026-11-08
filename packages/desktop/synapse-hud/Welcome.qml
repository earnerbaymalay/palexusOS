// SynapseOS — First-run setup (Qt6 / QtQuick)
//   First boot (--oobe): Welcome -> Account -> Look -> Assistant -> Ready -> login screen
//   Live ISO           : Welcome (Try / Install) -> Look -> Ready
//   In session         : Welcome -> Look -> Assistant -> Ready
// The chosen wallpaper fills the screen and doubles as the live preview; one calm panel
// holds the step. Keys: Enter continue · Alt+Left back · Esc skip (not on first boot) · Tab focus.

import QtQuick
import QtQuick.Layouts

Window {
    id: root
    width: 1100
    height: 720
    visibility: (isOobe || isLive) ? Window.FullScreen : Window.Windowed
    title: "SynapseOS Setup"
    flags: (isOobe || isLive) ? Qt.Window : (Qt.FramelessWindowHint | Qt.Dialog)
    color: "#09090d"

    // ---- Backend access (defaults let the file load without one) ----
    readonly property bool hasBackend: typeof backend !== "undefined" && backend !== null
    function bk(name, fallback) { return (hasBackend && backend[name] !== undefined) ? backend[name] : fallback }

    readonly property bool isOobe: bk("isOobe", false)
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
    readonly property var accountErrors: bk("accountErrors", ({}))
    readonly property string applyState: bk("applyState", "idle")

    // ---- Design tokens ----
    readonly property var accents: ({
        mauve: "#cba6f7", tungsten: "#fab387", crimson: "#f38ba8",
        sapphire: "#74c7ec", emerald: "#a6e3a1"
    })
    readonly property var sceneLabels: ({ monolith: "Monolith", tower: "Basalt Tower", carbon: "Forged Carbon" })
    readonly property color accent: accents[accentName] || accents.mauve
    readonly property color accentInk: "#11111b"
    readonly property color panelFill: Qt.rgba(14 / 255, 14 / 255, 22 / 255, 0.90)
    readonly property color field: "#161624"
    readonly property color fieldHover: "#1e1e30"
    readonly property color hairline: "#2c2c40"
    readonly property color textMain: "#e6e9f5"
    readonly property color textSub: "#bac2de"
    readonly property color textMuted: "#9399b2"   // >= 6:1 on the panel
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property string sans: "Noto Sans"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property int motion: reduceMotion ? 0 : 220

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
    function cap(s) { return s.charAt(0).toUpperCase() + s.slice(1) }
    function iconLabel(t) { return t.replace("Synapse-", "").replace("-", " ") }
    function tierSize(t) { return hasBackend ? backend.tierSizeGb(t) : (t === "standard" ? 7.0 : 3.3) }
    function wallpaper(v) { return hasBackend ? backend.wallpaperUrl(v) : "" }

    // ---- Step machine ----
    readonly property var steps: isOobe ? ["welcome", "account", "appearance", "ai", "done"]
                               : isLive ? ["welcome", "appearance", "done"]
                                        : ["welcome", "appearance", "ai", "done"]
    property int stepIndex: 0
    readonly property string step: steps[Math.min(stepIndex, steps.length - 1)] || "welcome"
    property bool liveInstall: false
    property bool confirmSkip: false
    property bool accountTried: false

    readonly property bool accountValid: Object.keys(accountErrors).length === 0
    readonly property bool canContinue: applyState !== "working" && applyState !== "done"
                                        && !(step === "ai" && aiEngine === "claude" && claudeKey === "")
    readonly property string primaryLabel: step === "welcome" ? (isLive && liveInstall ? "Open the installer" : "Get started")
                                         : step === "done" ? (isOobe ? "Create account" : "Start using SynapseOS")
                                         : "Continue"

    function go(i) {
        stepIndex = Math.max(0, Math.min(steps.length - 1, i))
        confirmSkip = false
        primaryBtn.forceActiveFocus()
    }
    function next() {
        if (!canContinue) return
        if (step === "welcome" && isLive && liveInstall) { if (hasBackend) backend.startInstaller(); return }
        if (step === "account" && !accountValid) { accountTried = true; return }
        if (step === "done") { if (hasBackend) backend.finish(); else root.close(); return }
        go(stepIndex + 1)
    }
    function back() { if (stepIndex > 0 && applyState !== "working" && applyState !== "done") go(stepIndex - 1) }
    function skip() { if (hasBackend) backend.skip(); else root.close() }

    // ====================================================================
    // Controls
    // ====================================================================

    component T: Text {
        color: root.textMain
        font.family: root.sans
        font.pixelSize: 15
        wrapMode: Text.WordWrap
        lineHeight: wrapMode === Text.NoWrap ? 1.0 : 1.25
    }

    component Caption: T {
        color: root.textMuted
        font.pixelSize: 12
        font.family: root.mono
        font.letterSpacing: 1.2
        font.capitalization: Font.AllUppercase
        wrapMode: Text.NoWrap
    }

    component FocusRing: Rectangle {
        property real r: 10
        anchors.fill: parent
        anchors.margins: -4
        radius: r + 4
        color: "transparent"
        border.width: 2
        border.color: root.accent
    }

    component Btn: Rectangle {
        id: btn
        property string text
        property string kind: "secondary"      // primary | secondary | quiet
        property bool busy: false
        signal activated()
        implicitWidth: Math.max(kind === "quiet" ? 0 : 120, row.implicitWidth + 40)
        implicitHeight: 46
        radius: 23
        activeFocusOnTab: visible
        opacity: enabled ? 1 : 0.45
        color: kind === "primary" ? (bm.pressed ? Qt.darker(root.accent, 1.12) : bm.containsMouse ? Qt.lighter(root.accent, 1.06) : root.accent)
             : kind === "secondary" ? (bm.containsMouse ? root.fieldHover : root.field)
             : (bm.containsMouse ? root.withAlpha(root.textMain, 0.06) : "transparent")
        border.width: kind === "secondary" ? 1 : 0
        border.color: root.hairline
        Behavior on color { ColorAnimation { duration: root.motion } }

        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.onPressAction: if (enabled) activated()
        Keys.onReturnPressed: if (enabled) activated()
        Keys.onEnterPressed: if (enabled) activated()
        Keys.onSpacePressed: if (enabled) activated()

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 10
            Item {
                visible: btn.busy
                width: 16; height: 16
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent; radius: 8
                    color: "transparent"; border.width: 2
                    border.color: root.withAlpha(btn.kind === "primary" ? root.accentInk : root.textMain, 0.35)
                }
                Rectangle {
                    width: 6; height: 6; radius: 3; x: 5; y: -1
                    color: btn.kind === "primary" ? root.accentInk : root.textMain
                }
                RotationAnimation on rotation { running: btn.busy && !root.reduceMotion; loops: Animation.Infinite; from: 0; to: 360; duration: 900 }
            }
            T {
                text: btn.text
                color: btn.kind === "primary" ? root.accentInk : root.textMain
                font.pixelSize: 15
                font.weight: btn.kind === "quiet" ? Font.Normal : Font.DemiBold
                wrapMode: Text.NoWrap
            }
        }
        MouseArea {
            id: bm
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: { btn.forceActiveFocus(); btn.activated() }
        }
        FocusRing { r: btn.radius - 4; visible: btn.activeFocus }
    }

    // Radio-style option row; Space selects, Enter continues
    component Option: Rectangle {
        id: opt
        property string title
        property string desc
        property string badge
        property bool selected
        signal picked()
        implicitHeight: Math.max(68, body.implicitHeight + 28)
        radius: 14
        activeFocusOnTab: true
        color: selected ? root.withAlpha(root.accent, 0.12) : (om.containsMouse ? root.fieldHover : root.field)
        border.width: selected ? 2 : 1
        border.color: selected ? root.accent : root.hairline
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
            anchors.margins: 14
            anchors.leftMargin: 18
            spacing: 16
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 20; height: 20; radius: 10
                color: "transparent"
                border.width: 2
                border.color: opt.selected ? root.accent : root.textMuted
                Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: root.accent; visible: opt.selected }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                RowLayout {
                    spacing: 10
                    T { text: opt.title; font.weight: Font.DemiBold; wrapMode: Text.NoWrap }
                    Rectangle {
                        visible: opt.badge !== ""
                        implicitWidth: bt.implicitWidth + 14; implicitHeight: 22; radius: 11
                        color: root.withAlpha(root.accent, 0.18)
                        T { id: bt; anchors.centerIn: parent; text: opt.badge; color: root.accent; font.pixelSize: 12; font.weight: Font.DemiBold; wrapMode: Text.NoWrap }
                    }
                }
                T { Layout.fillWidth: true; text: opt.desc; color: root.textSub; font.pixelSize: 14; visible: opt.desc !== "" }
            }
        }
        MouseArea {
            id: om
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { opt.forceActiveFocus(); opt.picked() }
        }
        FocusRing { r: opt.radius; visible: opt.activeFocus }
    }

    // Labelled text field with inline error (shown once touched or after a Continue attempt)
    component Field: ColumnLayout {
        id: fld
        property string label
        property string helper
        property string error
        property alias text: input.text
        property bool secret: false
        property bool showError: false
        property alias input: input
        signal edited(string value)
        spacing: 6
        Layout.fillWidth: true

        T { text: fld.label; font.pixelSize: 14; font.weight: Font.DemiBold; color: root.textSub }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 46
            radius: 10
            color: root.field
            border.width: input.activeFocus ? 2 : 1
            border.color: fld.showError && fld.error ? root.warning : input.activeFocus ? root.accent : root.hairline
            TextInput {
                id: input
                property bool reveal: false
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: fld.secret ? 64 : 14
                verticalAlignment: TextInput.AlignVCenter
                color: root.textMain
                font.family: root.sans; font.pixelSize: 15
                echoMode: fld.secret && !reveal ? TextInput.Password : TextInput.Normal
                selectByMouse: true
                selectionColor: root.accent
                selectedTextColor: root.accentInk
                clip: true
                activeFocusOnTab: true
                Accessible.role: Accessible.EditableText
                Accessible.name: fld.label
                Accessible.description: fld.showError && fld.error ? fld.error : fld.helper
                onTextEdited: fld.edited(text)
                onActiveFocusChanged: if (!activeFocus && text !== "") fld.showError = true
            }
            T {
                visible: fld.secret
                anchors.right: parent.right; anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: input.reveal ? "Hide" : "Show"
                color: root.accent; font.pixelSize: 13; font.weight: Font.DemiBold
                wrapMode: Text.NoWrap
                Accessible.role: Accessible.Button
                Accessible.name: input.reveal ? "Hide " + fld.label : "Show " + fld.label
                MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: input.reveal = !input.reveal }
            }
        }
        T {
            Layout.fillWidth: true
            visible: text !== ""
            text: fld.showError && fld.error ? fld.error : fld.helper
            color: fld.showError && fld.error ? root.warning : root.textMuted
            font.pixelSize: 13
        }
    }

    component Toggle: Item {
        id: tg
        property string text
        property string detail
        property bool checked
        signal toggled()
        implicitHeight: Math.max(28, tgText.implicitHeight)
        activeFocusOnTab: true
        Accessible.role: Accessible.CheckBox
        Accessible.name: text
        Accessible.checkable: true
        Accessible.checked: checked
        Accessible.onToggleAction: toggled()
        Keys.onSpacePressed: toggled()

        RowLayout {
            anchors.fill: parent
            spacing: 14
            Rectangle {
                Layout.alignment: Qt.AlignTop
                width: 46; height: 26; radius: 13
                color: tg.checked ? root.accent : root.field
                border.width: tg.checked ? 0 : 1.5
                border.color: root.textMuted
                Behavior on color { ColorAnimation { duration: root.motion } }
                Rectangle {
                    width: 20; height: 20; radius: 10; y: 3
                    x: tg.checked ? 23 : 3
                    color: tg.checked ? root.accentInk : root.textMuted
                    Behavior on x { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } }
                }
                FocusRing { r: 13; visible: tg.activeFocus }
            }
            ColumnLayout {
                id: tgText
                Layout.fillWidth: true
                spacing: 2
                T { Layout.fillWidth: true; text: tg.text; font.weight: Font.DemiBold }
                T { Layout.fillWidth: true; text: tg.detail; color: root.textMuted; font.pixelSize: 13; visible: tg.detail !== "" }
            }
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { tg.forceActiveFocus(); tg.toggled() } }
    }

    component Keycap: Rectangle {
        property string label
        implicitWidth: Math.max(32, kt.implicitWidth + 18)
        implicitHeight: 30
        radius: 6
        color: root.field
        border.color: root.hairline
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; radius: 1; color: root.hairline }
        T { id: kt; anchors.centerIn: parent; text: parent.label; font.family: root.mono; font.pixelSize: 13; font.weight: Font.DemiBold; wrapMode: Text.NoWrap }
    }

    component Heading: ColumnLayout {
        property string title
        property string subtitle
        Layout.fillWidth: true
        spacing: 8
        T { Layout.fillWidth: true; text: parent.title; font.pixelSize: 30; font.weight: Font.DemiBold; color: "#ffffff" }
        T { Layout.fillWidth: true; text: parent.subtitle; color: root.textSub; font.pixelSize: 16; visible: text !== "" }
    }

    // Only the current step is visible and focusable; it fades and rises in
    component Page: Item {
        property string name
        readonly property bool current: root.step === name
        anchors.fill: parent
        opacity: current ? 1 : 0
        visible: opacity > 0
        enabled: current
        transform: Translate { y: current ? 0 : 12; Behavior on y { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: root.motion } }
    }

    // ====================================================================
    // Full-bleed wallpaper (cross-fades on change) + scrim
    // ====================================================================

    property bool frontIsA: true
    property string wallSource: wallpaper(variant)
    onWallSourceChanged: (frontIsA ? wallB : wallA).source = wallSource
    Image {
        id: wallA
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 1920
        opacity: root.frontIsA ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: root.motion * 2 } }
        onStatusChanged: if (status === Image.Ready && source == root.wallSource) root.frontIsA = true
        Component.onCompleted: source = root.wallSource
        Accessible.ignored: true
    }
    Image {
        id: wallB
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 1920
        opacity: root.frontIsA ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: root.motion * 2 } }
        onStatusChanged: if (status === Image.Ready && source == root.wallSource) root.frontIsA = false
        Accessible.ignored: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(9 / 255, 9 / 255, 13 / 255, 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(9 / 255, 9 / 255, 13 / 255, 0.75) }
        }
    }

    // ====================================================================
    // Panel
    // ====================================================================

    FocusScope {
        id: scope
        anchors.fill: parent
        focus: true
        // Fade in from the boot splash's black
        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity { NumberAnimation { duration: root.reduceMotion ? 0 : 600; easing.type: Easing.OutCubic } }

        Keys.onEscapePressed: if (!root.isOobe) root.confirmSkip = !root.confirmSkip
        Keys.onReturnPressed: if (!root.confirmSkip) root.next()
        Keys.onEnterPressed: if (!root.confirmSkip) root.next()
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left && (event.modifiers & Qt.AltModifier)) { root.back(); event.accepted = true }
        }

        Rectangle {
            id: panel
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 820)
            height: Math.min(parent.height - 48, 660)
            radius: 22
            color: root.panelFill
            border.color: root.withAlpha(root.accent, 0.35)
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: root.motion * 2 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                anchors.topMargin: 30
                anchors.bottomMargin: 28
                spacing: 24

                // ---- Top bar: brand · progress dots · step counter ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    T { text: "SYNAPSEOS"; font.family: root.mono; font.pixelSize: 13; font.weight: Font.Bold; font.letterSpacing: 2; color: root.textSub; wrapMode: Text.NoWrap }
                    Item { Layout.fillWidth: true }
                    Row {
                        spacing: 8
                        Accessible.role: Accessible.ProgressBar
                        Accessible.name: "Step " + (root.stepIndex + 1) + " of " + root.steps.length
                        Repeater {
                            model: root.steps.length
                            delegate: Rectangle {
                                required property int index
                                width: index === root.stepIndex ? 26 : 8
                                height: 8; radius: 4
                                color: index <= root.stepIndex ? root.accent : root.hairline
                                Behavior on width { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                    T {
                        text: (root.stepIndex + 1) + " / " + root.steps.length
                        font.family: root.mono; font.pixelSize: 13; color: root.textMuted; wrapMode: Text.NoWrap
                    }
                }

                // ---- Pages ----
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // 1. Welcome
                    Page {
                        name: "welcome"
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 22
                            Item { Layout.fillHeight: true }
                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 112; Layout.preferredHeight: 112
                                source: root.bk("chromeLogoPath", "") ? "file://" + root.bk("chromeLogoPath", "") : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true; mipmap: true
                                visible: status === Image.Ready
                                Accessible.ignored: true
                            }
                            T {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: root.isOobe || root.isLive ? "Welcome to SynapseOS" : "Welcome, " + root.bk("displayName", "there")
                                font.pixelSize: 36; font.weight: Font.DemiBold; color: "#ffffff"
                            }
                            T {
                                Layout.fillWidth: true
                                Layout.leftMargin: 40; Layout.rightMargin: 40
                                horizontalAlignment: Text.AlignHCenter
                                color: root.textSub; font.pixelSize: 17
                                text: root.isOobe ? "A private, keyboard-first workspace with an AI assistant that can run entirely on this computer. Let's create your account. It takes about two minutes."
                                    : root.isLive ? "You're running from the USB stick. Nothing is installed yet. Try it out, or install it now."
                                    : "Let's pick a look and set up your AI assistant. You can change all of it later."
                            }
                            RowLayout {
                                visible: root.isLive
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                spacing: 14
                                Option {
                                    Layout.fillWidth: true; Layout.preferredWidth: 1
                                    title: "Try SynapseOS"
                                    desc: "Explore first. Install any time from the bar or with Super+I."
                                    selected: !root.liveInstall
                                    onPicked: root.liveInstall = false
                                }
                                Option {
                                    Layout.fillWidth: true; Layout.preferredWidth: 1
                                    title: "Install SynapseOS"
                                    desc: "Open the installer. You'll create your account on first boot."
                                    selected: root.liveInstall
                                    onPicked: root.liveInstall = true
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // 2. Account (first boot only)
                    Page {
                        name: "account"
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18
                            Heading {
                                title: "Create your account"
                                subtitle: "You'll use this to sign in. The password also unlocks admin tasks."
                            }
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 20
                                rowSpacing: 14
                                Field {
                                    id: nameField
                                    Layout.columnSpan: 2
                                    label: "Your name"
                                    error: root.accountErrors.fullName || ""
                                    showError: root.accountTried
                                    text: root.bk("fullName", "")
                                    onEdited: (v) => { if (root.hasBackend) backend.fullName = v }
                                }
                                Field {
                                    label: "Username"
                                    helper: "Lowercase, no spaces."
                                    error: root.accountErrors.username || ""
                                    showError: root.accountTried
                                    text: root.bk("username", "")
                                    onEdited: (v) => { if (root.hasBackend) backend.username = v }
                                }
                                Field {
                                    label: "Computer name"
                                    helper: "How this computer appears on networks."
                                    error: root.accountErrors.hostname || ""
                                    showError: root.accountTried
                                    text: root.bk("newHostname", "")
                                    onEdited: (v) => { if (root.hasBackend) backend.newHostname = v }
                                }
                                Field {
                                    label: "Password"
                                    secret: true
                                    helper: "At least 6 characters."
                                    error: root.accountErrors.password || ""
                                    showError: root.accountTried
                                    onEdited: (v) => { if (root.hasBackend) backend.password = v }
                                }
                                Field {
                                    label: "Confirm password"
                                    secret: true
                                    error: root.accountErrors.confirm || ""
                                    showError: root.accountTried
                                    onEdited: (v) => { if (root.hasBackend) backend.passwordConfirm = v }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // 3. Look — the background is the preview
                    Page {
                        name: "appearance"
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18
                            Heading {
                                title: "Choose a look"
                                subtitle: root.sceneLabels[root.scene] + " · " + root.cap(root.accentName) + ". The background shows your choice."
                            }

                            Caption { text: "Scene" }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Repeater {
                                    model: ["monolith", "tower", "carbon"]
                                    delegate: Rectangle {
                                        id: tile
                                        required property string modelData
                                        readonly property bool selected: root.scene === modelData
                                        readonly property string thumbAccent: root.hasBackend && backend.variantExists(modelData, root.accentName) ? root.accentName : "mauve"
                                        function pick() { if (root.hasBackend) backend.chooseVariant(modelData, root.accentName) }
                                        Layout.fillWidth: true
                                        implicitHeight: 112
                                        radius: 12
                                        color: root.field
                                        border.width: selected ? 2 : 1
                                        border.color: selected ? root.accent : root.hairline
                                        clip: true
                                        activeFocusOnTab: true
                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name: root.sceneLabels[modelData]
                                        Accessible.checkable: true
                                        Accessible.checked: selected
                                        Accessible.onPressAction: pick()
                                        Keys.onSpacePressed: pick()
                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 3
                                            anchors.bottomMargin: 34
                                            source: root.wallpaper(tile.modelData + "-" + tile.thumbAccent)
                                            sourceSize.width: 320
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            Accessible.ignored: true
                                        }
                                        T {
                                            anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: root.sceneLabels[tile.modelData]
                                            color: tile.selected ? "#ffffff" : root.textSub
                                            font.pixelSize: 14; font.weight: tile.selected ? Font.DemiBold : Font.Normal
                                            wrapMode: Text.NoWrap
                                        }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { tile.forceActiveFocus(); tile.pick() } }
                                        FocusRing { r: 12; visible: tile.activeFocus }
                                    }
                                }
                            }

                            Caption { text: "Accent" }
                            RowLayout {
                                spacing: 14
                                Repeater {
                                    model: ["mauve", "tungsten", "crimson", "sapphire", "emerald"]
                                    delegate: Rectangle {
                                        id: sw
                                        required property string modelData
                                        readonly property bool available: !root.hasBackend || backend.variantExists(root.scene, modelData)
                                        readonly property bool selected: root.accentName === modelData
                                        function pick() { if (available && root.hasBackend) backend.chooseVariant(root.scene, modelData) }
                                        width: 44; height: 44; radius: 22
                                        color: root.accents[modelData]
                                        opacity: available ? 1 : 0.22
                                        activeFocusOnTab: available
                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name: root.cap(modelData) + (available ? "" : ", not available for this scene")
                                        Accessible.checkable: true
                                        Accessible.checked: selected
                                        Accessible.onPressAction: pick()
                                        Keys.onSpacePressed: pick()
                                        Rectangle {
                                            anchors.fill: parent; anchors.margins: -5
                                            radius: 27; color: "transparent"
                                            border.width: 2; border.color: "#ffffff"
                                            visible: sw.selected
                                        }
                                        MouseArea { anchors.fill: parent; enabled: sw.available; cursorShape: Qt.PointingHandCursor; onClicked: { sw.forceActiveFocus(); sw.pick() } }
                                        FocusRing { r: 22; anchors.margins: -8; visible: sw.activeFocus }
                                    }
                                }
                                T {
                                    Layout.leftMargin: 8
                                    visible: root.scene === "monolith"
                                    text: "Crimson isn't made for Monolith."
                                    color: root.textMuted; font.pixelSize: 13
                                    wrapMode: Text.NoWrap
                                }
                            }

                            Caption { text: "Icons" }
                            Flow {
                                Layout.fillWidth: true
                                spacing: 10
                                Repeater {
                                    model: root.bk("iconThemes", ["Synapse-Liquid-Chrome", "Synapse-Smoked-Obsidian", "Synapse-Radial-Tungsten", "Synapse-Aerospace-Billet"])
                                    delegate: Rectangle {
                                        id: chip
                                        required property string modelData
                                        readonly property bool selected: root.iconTheme === modelData
                                        function pick() { if (root.hasBackend) backend.iconTheme = modelData }
                                        width: chipRow.implicitWidth + 28
                                        height: 44
                                        radius: 22
                                        color: selected ? root.withAlpha(root.accent, 0.12) : (cm.containsMouse ? root.fieldHover : root.field)
                                        border.width: selected ? 2 : 1
                                        border.color: selected ? root.accent : root.hairline
                                        activeFocusOnTab: true
                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name: root.iconLabel(modelData) + " icons"
                                        Accessible.checkable: true
                                        Accessible.checked: selected
                                        Accessible.onPressAction: pick()
                                        Keys.onSpacePressed: pick()
                                        Row {
                                            id: chipRow
                                            anchors.centerIn: parent
                                            spacing: 6
                                            Repeater {
                                                model: root.hasBackend ? backend.iconSamples(chip.modelData).slice(0, 3) : []
                                                delegate: Image {
                                                    required property string modelData
                                                    width: 20; height: 20
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    source: modelData
                                                    sourceSize: Qt.size(40, 40)
                                                    Accessible.ignored: true
                                                }
                                            }
                                            T {
                                                anchors.verticalCenter: parent.verticalCenter
                                                leftPadding: 4
                                                text: root.iconLabel(chip.modelData)
                                                color: chip.selected ? "#ffffff" : root.textSub
                                                font.pixelSize: 14
                                                wrapMode: Text.NoWrap
                                            }
                                        }
                                        MouseArea { id: cm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { chip.forceActiveFocus(); chip.pick() } }
                                        FocusRing { r: 22; visible: chip.activeFocus }
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // 4. AI assistant
                    Page {
                        name: "ai"
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 12
                            Heading {
                                title: "Your AI assistant"
                                subtitle: "Ask it anything from the Command HUD (Super+Space)."
                            }
                            Option {
                                Layout.fillWidth: true
                                Layout.topMargin: 6
                                title: "Private, on this computer"
                                badge: "Recommended"
                                desc: "Runs locally with Ollama. Nothing you type leaves the device, and it works offline."
                                selected: root.aiEngine === "local"
                                onPicked: if (root.hasBackend) backend.aiEngine = "local"
                            }
                            Option {
                                Layout.fillWidth: true
                                title: "Claude, in the cloud"
                                desc: "Anthropic's Claude. Stronger answers; your prompts go to Anthropic. Needs an API key."
                                selected: root.aiEngine === "claude"
                                onPicked: if (root.hasBackend) backend.aiEngine = "claude"
                            }
                            Option {
                                Layout.fillWidth: true
                                title: "Not now"
                                desc: "Turn it on later in Settings."
                                selected: root.aiEngine === "none"
                                onPicked: if (root.hasBackend) backend.aiEngine = "none"
                            }

                            // Local details
                            ColumnLayout {
                                visible: root.aiEngine === "local" && !root.isLive
                                Layout.fillWidth: true
                                Layout.topMargin: 6
                                spacing: 12
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    T {
                                        text: root.ramGb > 0 ? "Model size  ·  " + root.ramGb.toFixed(0) + " GB memory" : "Model size"
                                        color: root.textMuted; font.pixelSize: 13; wrapMode: Text.NoWrap
                                    }
                                    Item { Layout.fillWidth: true }
                                    Repeater {
                                        model: [
                                            { id: "light", t: "Light", d: "~" + root.tierSize("light").toFixed(1) + " GB" },
                                            { id: "standard", t: "Standard", d: "~" + root.tierSize("standard").toFixed(1) + " GB" }
                                        ]
                                        delegate: Rectangle {
                                            id: seg
                                            required property var modelData
                                            readonly property bool selected: root.modelTier === modelData.id
                                            function pick() { if (root.hasBackend) backend.modelTier = modelData.id }
                                            implicitWidth: segText.implicitWidth + 30
                                            implicitHeight: 38
                                            radius: 19
                                            color: selected ? root.withAlpha(root.accent, 0.14) : root.field
                                            border.width: selected ? 2 : 1
                                            border.color: selected ? root.accent : root.hairline
                                            activeFocusOnTab: true
                                            Accessible.role: Accessible.RadioButton
                                            Accessible.name: modelData.t + " models, " + modelData.d + " download"
                                            Accessible.checkable: true
                                            Accessible.checked: selected
                                            Accessible.onPressAction: pick()
                                            Keys.onSpacePressed: pick()
                                            T { id: segText; anchors.centerIn: parent; text: seg.modelData.t + "  " + seg.modelData.d; font.pixelSize: 14; wrapMode: Text.NoWrap; color: seg.selected ? "#ffffff" : root.textSub }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { seg.forceActiveFocus(); seg.pick() } }
                                            FocusRing { r: 19; visible: seg.activeFocus }
                                        }
                                    }
                                }
                                Toggle {
                                    Layout.fillWidth: true
                                    text: "Download the models after setup"
                                    detail: root.downloadModels
                                        ? "Runs in the background at low priority; you'll get a notification when it's ready." + (root.modelTier === "standard" && root.ramGb > 0 && root.ramGb < 12 ? " Standard may be slow with this much memory." : "")
                                        : "Nothing is downloaded. Run synapse-setup --pull-core whenever you like."
                                    checked: root.downloadModels
                                    onToggled: if (root.hasBackend) backend.downloadModels = !root.downloadModels
                                }
                            }

                            // Claude details
                            ColumnLayout {
                                visible: root.aiEngine === "claude"
                                Layout.fillWidth: true
                                Layout.topMargin: 6
                                spacing: 8
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    Field {
                                        id: keyField
                                        label: "Anthropic API key"
                                        secret: true
                                        text: root.claudeKey
                                        onEdited: (v) => { if (root.hasBackend) backend.claudeApiKey = v }
                                    }
                                    Btn {
                                        Layout.alignment: Qt.AlignBottom
                                        text: root.keyState === "testing" ? "Checking" : "Test key"
                                        busy: root.keyState === "testing"
                                        enabled: root.claudeKey !== "" && root.keyState !== "testing"
                                        onActivated: if (root.hasBackend) backend.testClaudeKey()
                                    }
                                }
                                T {
                                    Layout.fillWidth: true
                                    text: root.claudeKey === ""
                                        ? "Paste a key to continue, or choose another option. Keys come from console.anthropic.com."
                                        : (root.keyState === "ok" ? "✓  " : root.keyState === "error" ? "!  " : "")
                                          + (root.bk("keyTestMessage", "") || "Stored so only your account can read it.")
                                    color: root.keyState === "ok" ? root.success : root.keyState === "error" ? root.warning : root.textMuted
                                    font.pixelSize: 13
                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: text
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // 5. Ready — summary, privacy at a glance, three keys
                    Page {
                        name: "done"
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18
                            Heading {
                                title: root.applyState === "done" ? "All set" : root.isLive ? "Ready to explore" : "Ready when you are"
                                subtitle: root.applyState === "done" ? root.bk("applyMessage", "")
                                        : root.isOobe ? "Check the details, then create your account. You'll sign in on the next screen."
                                        : root.isLive ? "Install whenever you like from the bar or with Super+I."
                                        : "Here's what will be set up."
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 24
                                rowSpacing: 10
                                Repeater {
                                    model: {
                                        var rows = []
                                        if (root.isOobe)
                                            rows.push({ t: "Account", d: root.bk("username", "") + " on " + root.bk("newHostname", "") })
                                        rows.push({ t: "Look", d: root.sceneLabels[root.scene] + " · " + root.cap(root.accentName) + ", " + root.iconLabel(root.iconTheme) + " icons" })
                                        if (!root.isLive)
                                            rows.push({ t: "Assistant", d: root.aiEngine === "local"
                                                ? "Local, " + root.modelTier + " models" + (root.downloadModels ? " (~" + root.tierSize(root.modelTier).toFixed(1) + " GB downloads in the background)" : " (not downloaded yet)")
                                                : root.aiEngine === "claude" ? (root.keyState === "ok" ? "Claude, key verified" : "Claude, key not tested")
                                                : "Off" })
                                        return rows
                                    }
                                    delegate: Item {
                                        required property var modelData
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        implicitHeight: srow.implicitHeight
                                        RowLayout {
                                            id: srow
                                            anchors.left: parent.left; anchors.right: parent.right
                                            spacing: 16
                                            Caption { text: modelData.t; Layout.preferredWidth: 110 }
                                            T { text: modelData.d; Layout.fillWidth: true }
                                        }
                                    }
                                }
                            }

                            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: root.hairline }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 32
                                // Privacy, read from the system
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.alignment: Qt.AlignTop
                                    spacing: 8
                                    Caption { text: "Privacy, right now" }
                                    Repeater {
                                        model: root.bk("securityChecks", [])
                                        delegate: RowLayout {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            spacing: 10
                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: modelData.label + ": " + (modelData.ok ? "on" : "needs attention") + ". " + modelData.detail
                                            T { text: modelData.ok ? "✓" : "!"; color: modelData.ok ? root.success : root.warning; font.weight: Font.Bold; font.pixelSize: 14; wrapMode: Text.NoWrap }
                                            T { text: modelData.label + (modelData.ok ? "" : ", needs attention"); font.pixelSize: 14; Layout.fillWidth: true; color: modelData.ok ? root.textMain : root.warning }
                                        }
                                    }
                                }
                                // Three keys
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.alignment: Qt.AlignTop
                                    spacing: 8
                                    Caption { text: "Three keys" }
                                    Repeater {
                                        model: [
                                            { k: "Space", t: "Command HUD & AI" },
                                            { k: "Return", t: "Terminal" },
                                            { k: "/", t: "Every shortcut" }
                                        ]
                                        delegate: RowLayout {
                                            required property var modelData
                                            spacing: 8
                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: "Super plus " + modelData.k + ": " + modelData.t
                                            Keycap { label: "Super" }
                                            Keycap { label: modelData.k }
                                            T { Layout.leftMargin: 6; text: modelData.t; font.pixelSize: 14; wrapMode: Text.NoWrap }
                                        }
                                    }
                                }
                            }

                            T {
                                Layout.fillWidth: true
                                visible: root.applyState === "error"
                                text: "!  " + root.bk("applyMessage", "")
                                color: root.warning
                                font.pixelSize: 14
                                Accessible.role: Accessible.AlertMessage
                                Accessible.name: text
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }
                }

                // ---- Footer ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: !root.confirmSkip

                    Btn {
                        kind: "quiet"
                        text: "Back"
                        visible: root.stepIndex > 0 && root.applyState !== "done"
                        enabled: root.applyState !== "working"
                        onActivated: root.back()
                    }
                    Btn {
                        kind: "quiet"
                        text: "Skip setup"
                        visible: root.stepIndex === 0 && !root.isOobe
                        onActivated: root.confirmSkip = true
                    }
                    Item { Layout.fillWidth: true }
                    Btn {
                        visible: root.isLive && root.step === "done"
                        text: "Open the installer"
                        onActivated: if (root.hasBackend) backend.startInstaller()
                    }
                    Btn {
                        id: primaryBtn
                        kind: "primary"
                        text: root.applyState === "working" ? "Setting up" : root.applyState === "done" ? "Opening login" : root.primaryLabel
                        busy: root.applyState === "working" || root.applyState === "done"
                        enabled: root.canContinue
                        focus: true
                        onActivated: root.next()
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: root.confirmSkip
                    onVisibleChanged: if (visible) keepGoing.forceActiveFocus()
                    T {
                        Layout.fillWidth: true
                        text: root.isLive ? "Skip setup? The desktop stays as it is."
                                          : "Skip setup? Nothing changes and the AI assistant stays off. Super+W brings this back."
                        color: root.warning
                        font.pixelSize: 14
                        Accessible.role: Accessible.AlertMessage
                        Accessible.name: text
                    }
                    Btn { id: keepGoing; text: "Keep going"; onActivated: { root.confirmSkip = false; primaryBtn.forceActiveFocus() } }
                    Btn { kind: "primary"; text: "Skip"; onActivated: root.skip() }
                }
            }
        }
    }

    onStepChanged: if (step === "account") nameField.input.forceActiveFocus()
    Component.onCompleted: primaryBtn.forceActiveFocus()
}
