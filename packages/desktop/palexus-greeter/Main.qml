// PalexusOS -- SDDM greeter (Qt6)
// Exquisite luxury cyber-organic theme with deep purple illumination,
// living biometric aura trails, crystalline chamfered login module,
// and synchronized hardware telemetry readout.
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root
    width: 1920
    height: 1080

    // Layout is authored at 1376x768 (the wallpaper size) and scaled by height.
    readonly property real s: height / 768

    readonly property var accents: ({
        mauve: "#cba6f7", tungsten: "#fab387", crimson: "#f38ba8",
        sapphire: "#74c7ec", emerald: "#a6e3a1"
    })
    readonly property string variant: (typeof config !== "undefined" && config && config.stringValue && config.stringValue("variant") !== "") ? config.stringValue("variant") : "monolith-mauve"
    readonly property color accent: accents[variant.split("-").pop()] || accents.mauve
    readonly property color deepPurpleAura: "#4d1d75"
    readonly property color voidDark: "#07070b"
    readonly property color surfacePanel: Qt.rgba(12 / 255, 11 / 255, 18 / 255, 0.88)
    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#bac2de"
    readonly property color muted: "#7f849c"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property string sans: "Noto Sans"
    readonly property bool animate: (typeof config !== "undefined" && config && config.stringValue) ? (config.stringValue("animations") !== "false") : true
    readonly property string wallDir: (typeof config !== "undefined" && config && config.stringValue && config.stringValue("backgrounds") !== "") ? config.stringValue("backgrounds") : "/usr/share/backgrounds/palexusos"

    property string userName: (typeof config !== "undefined" && config && config.stringValue && config.stringValue("user") !== "") ? config.stringValue("user") : ((typeof userModel !== "undefined" && userModel && userModel.lastUser) ? userModel.lastUser : "")
    property int sessionIndex: (typeof sessionModel !== "undefined" && sessionModel && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
    property bool busy: false
    property date now: new Date()

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    function doLogin() {
        if (busy)
            return
        busy = true
        status.show("VERIFYING BIOMETRICS & CREDENTIALS…", accent)
        if (typeof sddm !== "undefined" && sddm && sddm.login)
            sddm.login(userName, password.text, sessionIndex)
    }

    // Account names for Up/Down cycling on the login field
    property var userNames: []
    // Typing breaks the field's binding, so push programmatic changes (cycling) back into it
    onUserNameChanged: if (loginField.text !== userName) loginField.text = userName

    function cycleUser(step) {
        if (userNames.length === 0)
            return
        var i = userNames.indexOf(userName)
        i = i < 0 ? 0 : (i + step + userNames.length) % userNames.length
        userName = userNames[i]
    }

    // No remembered user (fresh install): fall back to the first account.
    Repeater {
        model: userModel
        delegate: Item {
            required property int index
            required property string name
            Component.onCompleted: {
                root.userNames = root.userNames.concat([name])
                if (root.userName === "" && index === 0)
                    root.userName = name
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            password.text = ""
            status.show("AUTHENTICATION FAILED — ACCESS DENIED", "#f38ba8")
            shake.restart()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            status.show("ACCESS GRANTED — WELCOME TO PALEXUSOS", root.accent)
            outro.start()
        }
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    focus: true
    Keys.onPressed: function(event) {
        var n = event.key - Qt.Key_F2
        if (n >= 0 && (typeof sessionModel !== "undefined" && sessionModel && typeof sessionModel.rowCount === "function" && n < sessionModel.rowCount())) {
            root.sessionIndex = n
            event.accepted = true
        }
    }

    // --- Base background and Deep Purple Aura Lighting ---
    Rectangle { anchors.fill: parent; color: root.voidDark }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + root.wallDir + "/palexus-" + root.variant + ".jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        onStatusChanged: if (status === Image.Error) source = "file://" + root.wallDir + "/palexus-monolith-mauve.jpg"
    }

    // Ambient Deep Purple Cyber-Organic Radial Glow behind center and corners
    Rectangle {
        id: ambientGlow
        anchors.fill: parent
        opacity: root.animate ? 0.75 : 0.55
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: root.withAlpha(root.deepPurpleAura, 0.35) }
            GradientStop { position: 0.5; color: root.withAlpha(root.deepPurpleAura, 0.15) }
            GradientStop { position: 1.0; color: root.withAlpha(root.deepPurpleAura, 0.45) }
        }
        SequentialAnimation on opacity {
            running: root.animate
            loops: Animation.Infinite
            NumberAnimation { to: 0.9; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.6; duration: 4000; easing.type: Easing.InOutSine }
        }
    }

    // Top-left organic neural node & OS status
    Row {
        anchors { top: parent.top; left: parent.left; topMargin: 36 * root.s; leftMargin: 40 * root.s }
        spacing: 12 * root.s
        Rectangle {
            width: 8 * root.s; height: 8 * root.s; radius: 4 * root.s
            color: root.accent
            anchors.verticalCenter: parent.verticalCenter
            SequentialAnimation on opacity {
                running: root.animate; loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 1200; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
            }
        }
        Text {
            text: "PALEXUS // NEURAL INTERFACE ONLINE"
            color: root.subtext
            font { family: root.mono; pixelSize: 10 * root.s; letterSpacing: 2 * root.s; bold: true }
        }
    }

    // --- Clock + readout (right aligned cyberdeck telemetry) ---------------------------------
    Item {
        anchors { top: parent.top; right: parent.right; topMargin: 36 * root.s; rightMargin: 44 * root.s }
        width: 330 * root.s
        height: 280 * root.s

        // Subtle glass backing for readout
        Rectangle {
            anchors.fill: parent
            anchors.margins: -12 * root.s
            radius: 12 * root.s
            color: Qt.rgba(12 / 255, 10 / 255, 20 / 255, 0.42)
            border { width: 1; color: root.withAlpha(root.accent, 0.18) }
        }

        Column {
            anchors.fill: parent
            spacing: 8 * root.s

            Row {
                anchors.right: parent.right
                spacing: 8 * root.s
                Rectangle {
                    width: 6 * root.s; height: 6 * root.s; radius: 3 * root.s
                    color: root.accent
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "PALEXUS OS · LINUX-CACHYOS"
                    color: root.accent
                    font { family: root.mono; pixelSize: 10.5 * root.s; letterSpacing: 3 * root.s; bold: true }
                }
            }

            Text {
                anchors.right: parent.right
                text: Qt.formatTime(root.now, "hh:mm")
                color: root.text
                font { family: root.mono; pixelSize: 64 * root.s; weight: Font.Light }
            }

            Text {
                anchors.right: parent.right
                text: Qt.formatDate(root.now, "ddd · dd MMM yyyy").toUpperCase()
                color: root.subtext
                font { family: root.mono; pixelSize: 11.5 * root.s; letterSpacing: 1.5 * root.s }
            }

            Rectangle {
                width: parent.width
                height: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: root.withAlpha(root.accent, 0.4) }
                    GradientStop { position: 1.0; color: root.withAlpha(root.accent, 0.7) }
                }
            }

            Column {
                width: parent.width
                spacing: 6 * root.s
                Repeater {
                    model: [
                        ["NODE", (typeof sddm !== "undefined" && sddm && sddm.hostName) ? sddm.hostName : "palexus", false],
                        ["KERNEL", "linux-cachyos · BORE", false],
                        ["CRYPTO-DNS", "Quad9 · DoT TLS", false],
                        ["INTERFACE", "stealth randomized", true],
                        ["SECURITY", "drop inbound active", false],
                        ["LOCAL AI", "ollama · ready", true]
                    ]
                    delegate: Item {
                        required property var modelData
                        width: 330 * root.s
                        height: 15 * root.s
                        Text { text: modelData[0]; color: root.muted; font { family: root.mono; pixelSize: 10.5 * root.s; letterSpacing: 0.5 * root.s } }
                        Text {
                            anchors.right: parent.right
                            text: modelData[1]
                            color: modelData[2] ? root.accent : root.subtext
                            font { family: root.mono; pixelSize: 10.5 * root.s }
                        }
                    }
                }
            }
        }
    }

    // --- Cyber-Organic Circuit Leads (Dynamic Purple Stream) ---------------------------
    Repeater {
        model: [ { x: 250, dir: -1 }, { x: 976, dir: 1 } ]
        delegate: Item {
            required property var modelData
            x: (root.width - 1376 * root.s) / 2 + modelData.x * root.s
            y: panel.y + 144 * root.s
            width: 170 * root.s
            height: 2 * root.s

            // Faint neural circuit baseline
            Rectangle {
                anchors.fill: parent
                color: root.withAlpha(root.deepPurpleAura, 0.5)
            }

            // High-luminance pulse travelling into/out of the terminal
            Rectangle {
                id: pulse
                width: 56 * root.s; height: parent.height
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.4; color: root.deepPurpleAura }
                    GradientStop { position: 0.5; color: root.accent }
                    GradientStop { position: 0.52; color: "#ffffff" }
                    GradientStop { position: 0.6; color: root.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on x {
                    running: root.animate
                    loops: Animation.Infinite
                    duration: 2800
                    from: modelData.dir > 0 ? -56 * root.s : 170 * root.s
                    to: modelData.dir > 0 ? 170 * root.s : -56 * root.s
                }
            }

            // Organic terminal node
            Rectangle {
                width: 12 * root.s; height: 12 * root.s; radius: 6 * root.s
                x: modelData.dir > 0 ? parent.width - 3 * root.s : -9 * root.s
                y: -5 * root.s
                color: root.voidDark
                border { color: root.accent; width: 2 * root.s }
                SequentialAnimation on opacity {
                    running: root.animate
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 1400; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1400; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // --- Login panel ------------------------------------------------------
    Item {
        id: panel
        readonly property real c: 20 * root.s          // chamfer corner cut
        readonly property real pad: 28 * root.s        // room for the aura bloom
        width: 550 * root.s
        height: 278 * root.s
        x: (root.width - width) / 2 + shakeX
        y: root.height * 448 / 768
        property real shakeX: 0

        SequentialAnimation {
            id: shake
            NumberAnimation { target: panel; property: "shakeX"; to: -14 * root.s; duration: 50 }
            NumberAnimation { target: panel; property: "shakeX"; to: 14 * root.s; duration: 80 }
            NumberAnimation { target: panel; property: "shakeX"; to: -7 * root.s; duration: 70 }
            NumberAnimation { target: panel; property: "shakeX"; to: 0; duration: 60 }
        }

        // Body with organic glass depth
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: -1
                fillColor: root.surfacePanel
                startX: panel.c; startY: 0
                PathLine { x: panel.width; y: 0 }
                PathLine { x: panel.width; y: panel.height - panel.c }
                PathLine { x: panel.width - panel.c; y: panel.height }
                PathLine { x: 0; y: panel.height }
                PathLine { x: 0; y: panel.c }
                PathLine { x: panel.c; y: 0 }
            }
        }

        // Border trails: dual photon trails travelling round the chamfered outline.
        Shape {
            id: trails
            x: -panel.pad; y: -panel.pad
            width: panel.width + 2 * panel.pad
            height: panel.height + 2 * panel.pad
            readonly property real sw: 2.5 * root.s
            readonly property real perim: (2 * (panel.width + panel.height) - 4 * panel.c + 2 * Math.SQRT2 * panel.c) / sw
            property real offset: 0
            NumberAnimation on offset {
                running: root.animate
                loops: Animation.Infinite
                from: trails.perim; to: 0
                duration: 6500
            }
            ShapePath {   // Resting ambient purple edge
                strokeColor: root.withAlpha(root.deepPurpleAura, 0.45)
                strokeWidth: trails.sw
                fillColor: "transparent"
                joinStyle: ShapePath.MiterJoin
                startX: panel.pad + panel.c; startY: panel.pad
                PathLine { x: panel.pad + panel.width; y: panel.pad }
                PathLine { x: panel.pad + panel.width; y: panel.pad + panel.height - panel.c }
                PathLine { x: panel.pad + panel.width - panel.c; y: panel.pad + panel.height }
                PathLine { x: panel.pad; y: panel.pad + panel.height }
                PathLine { x: panel.pad; y: panel.pad + panel.c }
                PathLine { x: panel.pad + panel.c; y: panel.pad }
            }
            ShapePath {   // Luminescent accent trails
                strokeColor: root.accent
                strokeWidth: trails.sw
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.DashLine
                dashPattern: [trails.perim * 0.16, trails.perim * 0.34]
                dashOffset: trails.offset
                startX: panel.pad + panel.c; startY: panel.pad
                PathLine { x: panel.pad + panel.width; y: panel.pad }
                PathLine { x: panel.pad + panel.width; y: panel.pad + panel.height - panel.c }
                PathLine { x: panel.pad + panel.width - panel.c; y: panel.pad + panel.height }
                PathLine { x: panel.pad; y: panel.pad + panel.height }
                PathLine { x: panel.pad; y: panel.pad + panel.c }
                PathLine { x: panel.pad + panel.c; y: panel.pad }
            }
            ShapePath {   // White crystalline photon tip
                strokeColor: "#ffffff"
                strokeWidth: trails.sw * 1.2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.DashLine
                dashPattern: [trails.perim * 0.028, trails.perim * 0.472]
                dashOffset: trails.offset - trails.perim * 0.132
                startX: panel.pad + panel.c; startY: panel.pad
                PathLine { x: panel.pad + panel.width; y: panel.pad }
                PathLine { x: panel.pad + panel.width; y: panel.pad + panel.height - panel.c }
                PathLine { x: panel.pad + panel.width - panel.c; y: panel.pad + panel.height }
                PathLine { x: panel.pad; y: panel.pad + panel.height }
                PathLine { x: panel.pad; y: panel.pad + panel.c }
                PathLine { x: panel.pad + panel.c; y: panel.pad }
            }
        }
        MultiEffect {   // Deep purple bloom around the trails
            source: trails
            anchors.fill: trails
            blurEnabled: true
            blurMax: 36
            blur: 0.85
            brightness: 0.5
            z: -1
            SequentialAnimation on opacity {
                running: root.animate
                loops: Animation.Infinite
                NumberAnimation { from: 0.6; to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.6; duration: 2000; easing.type: Easing.InOutSine }
            }
        }

        Column {
            anchors { fill: parent; topMargin: 0; leftMargin: 24 * root.s; rightMargin: 22 * root.s }
            spacing: 4 * root.s

            // Top status strip
            Item {
                width: parent.width; height: 32 * root.s
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8 * root.s
                    Rectangle {
                        width: 6 * root.s; height: 6 * root.s; radius: 3 * root.s
                        color: root.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "PALEXUS SECURITY SUBSYSTEM // TTY7"
                        color: root.subtext
                        font { family: root.mono; pixelSize: 10.5 * root.s; letterSpacing: 1 * root.s }
                    }
                }
                Row {
                    anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                    spacing: 6 * root.s
                    Rectangle {
                        width: 6 * root.s; height: 6 * root.s; radius: 3 * root.s
                        color: root.accent
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            running: root.animate; loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 900 }
                            NumberAnimation { to: 1.0; duration: 900 }
                        }
                    }
                    Text {
                        text: "AUTH GATE"
                        color: root.accent
                        font { family: root.mono; pixelSize: 10.5 * root.s; letterSpacing: 1 * root.s; bold: true }
                    }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    x: -24 * root.s
                    width: panel.width
                    height: 1
                    color: root.withAlpha(root.accent, 0.3)
                }
            }

            Item { width: 1; height: 6 * root.s }

            Repeater {
                model: [
                    ["", "PalexusOS 0.1.0-alpha · linux-cachyos BORE (tty7)"],
                    ["[&nbsp;&nbsp;OK&nbsp;&nbsp;]&nbsp;", "Reached target Graphical Interface & Neural Cockpit."],
                    ["[&nbsp;&nbsp;OK&nbsp;&nbsp;]&nbsp;", "Started Palexus AI gateway on 127.0.0.1:8000."],
                    ["[&nbsp;&nbsp;OK&nbsp;&nbsp;]&nbsp;", "Resolver: Quad9 over TLS · MAC randomized."]
                ]
                delegate: Text {
                    required property var modelData
                    required property int index
                    textFormat: Text.StyledText
                    text: "<font color='" + root.accent + "'>" + modelData[0] + "</font>" + modelData[1]
                    color: index === 0 ? root.subtext : root.text
                    font { family: root.mono; pixelSize: 12 * root.s }
                    opacity: root.animate ? 0 : 1
                    SequentialAnimation on opacity {
                        running: root.animate
                        PauseAnimation { duration: 180 + 400 * index }
                        NumberAnimation { to: 1; duration: 400; easing.type: Easing.OutCubic }
                    }
                }
            }

            Item { width: 1; height: 6 * root.s }

            // Username Field: cleanly stylized
            Row {
                width: parent.width
                height: 28 * root.s
                spacing: 8 * root.s
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "palexusos login:"
                    color: root.subtext
                    font { family: root.mono; pixelSize: 12.5 * root.s }
                }
                TextField {
                    id: loginField
                    objectName: "loginField"
                    width: parent.width - 160 * root.s
                    height: parent.height
                    text: root.userName
                    placeholderText: "operator username (↑/↓ to cycle)"
                    placeholderTextColor: root.muted
                    color: root.accent
                    selectionColor: root.withAlpha(root.accent, 0.4)
                    font { family: root.mono; pixelSize: 12.5 * root.s; bold: true }
                    enabled: !root.busy
                    Accessible.name: "Username"
                    KeyNavigation.tab: password
                    background: Item {}
                    onTextEdited: root.userName = text.trim()
                    onAccepted: password.forceActiveFocus()
                    Keys.onUpPressed: root.cycleUser(-1)
                    Keys.onDownPressed: root.cycleUser(1)
                }
            }

            // Password Field & Enter Button
            Row {
                width: parent.width
                height: 44 * root.s
                spacing: 10 * root.s
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "password:"
                    color: root.subtext
                    font { family: root.mono; pixelSize: 12.5 * root.s }
                }
                TextField {
                    id: password
                    objectName: "password"
                    width: parent.width - 10 * root.s * 2 - enter.width - 80 * root.s
                    height: parent.height
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    placeholderText: "(not required - press enter)"
                    placeholderTextColor: root.muted
                    color: root.text
                    selectionColor: root.withAlpha(root.accent, 0.4)
                    font { family: root.mono; pixelSize: 15 * root.s }
                    enabled: !root.busy
                    focus: true
                    KeyNavigation.backtab: loginField
                    Accessible.name: "Password for " + root.userName
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1.5
                            color: password.activeFocus ? root.accent : root.withAlpha(root.accent, 0.45)
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    onAccepted: root.doLogin()
                    onTextEdited: status.show((typeof keyboard !== "undefined" && keyboard && keyboard.capsLock) ? "CAPS LOCK IS ON" : "", root.subtext)
                }
                Button {
                    id: enter
                    width: 104 * root.s
                    height: 38 * root.s
                    anchors.verticalCenter: parent.verticalCenter
                    text: "AUTHENTICATE ↵"
                    enabled: !root.busy
                    onClicked: root.doLogin()
                    contentItem: Text {
                        text: enter.text
                        color: enter.down ? "#ffffff" : root.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font { family: root.mono; pixelSize: 10 * root.s; letterSpacing: 0.8 * root.s; bold: true }
                    }
                    background: Rectangle {
                        radius: 4 * root.s
                        color: root.withAlpha(root.accent, enter.down ? 0.35 : enter.hovered ? 0.22 : 0.12)
                        border { color: enter.hovered ? root.accent : root.withAlpha(root.accent, 0.6); width: 1 }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            Text {
                id: status
                function show(msg, col) { text = msg; color = col }
                height: 16 * root.s
                text: (typeof keyboard !== "undefined" && keyboard && keyboard.capsLock) ? "CAPS LOCK IS ON" : ""
                color: root.subtext
                font { family: root.mono; pixelSize: 10.5 * root.s; letterSpacing: 0.5 * root.s }
            }

            // Session & Power Control Bar
            Item {
                width: parent.width
                height: 42 * root.s
                Row {
                    spacing: 8 * root.s
                    Repeater {
                        model: sessionModel
                        delegate: Button {
                            id: sessionButton
                            required property int index
                            required property string name
                            visible: index < 4
                            height: 34 * root.s
                            text: "[F" + (index + 2) + "] " + name.toLowerCase().replace(/ \(.*\)$/, "")
                            onClicked: root.sessionIndex = index
                            Accessible.name: "Session " + name
                            contentItem: Text {
                                text: sessionButton.text
                                color: index === root.sessionIndex ? root.text : root.muted
                                verticalAlignment: Text.AlignVCenter
                                font { family: root.mono; pixelSize: 10.5 * root.s; bold: index === root.sessionIndex }
                            }
                            background: Rectangle {
                                radius: 4 * root.s
                                color: index === root.sessionIndex ? root.withAlpha(root.accent, 0.16) : "transparent"
                                border { width: 1; color: index === root.sessionIndex ? root.accent : root.withAlpha(root.subtext, 0.25) }
                            }
                            leftPadding: 10 * root.s; rightPadding: 10 * root.s
                        }
                    }
                }
                Row {
                    anchors.right: parent.right
                    spacing: 6 * root.s
                    Repeater {
                        model: [
                            { label: "RESTART", can: (typeof sddm !== "undefined" && sddm && sddm.canReboot), act: function() { if (typeof sddm !== "undefined" && sddm && sddm.reboot) sddm.reboot() } },
                            { label: "SHUTDOWN", can: (typeof sddm !== "undefined" && sddm && sddm.canPowerOff), act: function() { if (typeof sddm !== "undefined" && sddm && sddm.powerOff) sddm.powerOff() } }
                        ]
                        delegate: Button {
                            id: powerButton
                            required property var modelData
                            visible: modelData.can
                            height: 34 * root.s
                            text: modelData.label
                            onClicked: modelData.act()
                            contentItem: Text {
                                text: powerButton.text
                                color: powerButton.hovered ? root.accent : root.muted
                                verticalAlignment: Text.AlignVCenter
                                font { family: root.mono; pixelSize: 10.5 * root.s; letterSpacing: 0.8 * root.s }
                            }
                            background: Rectangle {
                                radius: 4 * root.s
                                color: powerButton.hovered ? root.withAlpha(root.accent, 0.1) : "transparent"
                                border { width: 1; color: powerButton.hovered ? root.withAlpha(root.accent, 0.4) : "transparent" }
                            }
                            leftPadding: 10 * root.s; rightPadding: 10 * root.s
                        }
                    }
                }
            }
        }
    }

    // Bottom-left Keyboard layout indicator
    Text {
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 36 * root.s; bottomMargin: 30 * root.s }
        text: "KEYBOARD // " + ((typeof keyboard !== "undefined" && keyboard && keyboard.layouts && keyboard.layouts.length > 0 && keyboard.currentLayout !== undefined && keyboard.layouts[keyboard.currentLayout] && keyboard.layouts[keyboard.currentLayout].shortName) ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : "US")
        color: root.muted
        font { family: root.mono; pixelSize: 11 * root.s; letterSpacing: 1 * root.s }
    }

    // Fade to black on success so the session start is a clean cut.
    Rectangle {
        id: veil
        anchors.fill: parent
        color: root.voidDark
        opacity: 0
        NumberAnimation on opacity { id: outro; running: false; to: 1; duration: 400 }
    }

    Component.onCompleted: password.forceActiveFocus()
}
