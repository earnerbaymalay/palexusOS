"""SDDM login screen (palexus-greeter): any account can sign in, not just the last one."""

import os
from pathlib import Path

import pytest

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PyQt6.QtCore import QAbstractListModel, QMetaObject, QModelIndex, QObject, Qt, QUrl, pyqtProperty, pyqtSignal, pyqtSlot  # noqa: E402
from PyQt6.QtGui import QGuiApplication  # noqa: E402
from PyQt6.QtQuick import QQuickView  # noqa: E402
from PyQt6.QtTest import QTest  # noqa: E402

GREETER = Path(__file__).resolve().parent.parent / "packages" / "desktop" / "palexus-greeter" / "Main.qml"
NAME_ROLE = Qt.ItemDataRole.UserRole + 1


class UserModel(QAbstractListModel):
    def __init__(self, names, last):
        super().__init__()
        self._names, self._last = names, last

    def rowCount(self, parent=QModelIndex()):
        return len(self._names)

    def data(self, index, role):
        return self._names[index.row()] if role == NAME_ROLE else None

    def roleNames(self):
        return {NAME_ROLE: b"name"}

    @pyqtProperty(str, constant=True)
    def lastUser(self):
        return self._last


class SessionModel(QAbstractListModel):
    def rowCount(self, parent=QModelIndex()):
        return 1

    def data(self, index, role):
        return "Sway" if role == NAME_ROLE else None

    def roleNames(self):
        return {NAME_ROLE: b"name"}

    @pyqtProperty(int, constant=True)
    def lastIndex(self):
        return 0


class Sddm(QObject):
    loginFailed = pyqtSignal()
    loginSucceeded = pyqtSignal()

    def __init__(self):
        super().__init__()
        self.calls = []

    @pyqtSlot(str, str, int)
    def login(self, user, password, session):
        self.calls.append((user, password, session))

    @pyqtProperty(str, constant=True)
    def hostName(self):
        return "testbox"

    @pyqtProperty(bool, constant=True)
    def canReboot(self):
        return False

    @pyqtProperty(bool, constant=True)
    def canPowerOff(self):
        return False


class Config(QObject):
    @pyqtSlot(str, result=str)
    def stringValue(self, key):
        return {"animations": "false"}.get(key, "")


@pytest.fixture(scope="module")
def app():
    return QGuiApplication.instance() or QGuiApplication([])


@pytest.fixture
def greeter(app):
    users = UserModel(["ada", "bob", "cy"], "ada")
    sessions, sddm, config = SessionModel(), Sddm(), Config()
    view = QQuickView()
    ctx = view.rootContext()
    for name, obj in {"userModel": users, "sessionModel": sessions, "sddm": sddm, "config": config}.items():
        ctx.setContextProperty(name, obj)
    view.setSource(QUrl.fromLocalFile(str(GREETER)))
    assert view.status() == QQuickView.Status.Ready, [e.toString() for e in view.errors()]
    view.show()
    QTest.qWait(50)
    root = view.rootObject()
    yield view, root, sddm, (users, sessions, config)
    view.close()


def type_text(view, text):
    for ch in text:
        QTest.keyClick(view, ch)


def field(root, name):
    return root.findChild(QObject, name)


def test_defaults_to_the_last_user_with_password_focused(greeter):
    view, root, _, _ = greeter
    assert root.property("userName") == "ada"
    assert field(root, "loginField").property("text") == "ada"
    assert field(root, "password").property("activeFocus")


def test_a_typed_username_is_the_one_that_logs_in(greeter):
    view, root, sddm, _ = greeter
    root.setProperty("userName", "")
    QMetaObject.invokeMethod(field(root, "loginField"), "forceActiveFocus")
    type_text(view, "bob")
    assert root.property("userName") == "bob"
    QTest.keyClick(view, Qt.Key.Key_Return)  # moves to the password field
    type_text(view, "hunter22")
    QTest.keyClick(view, Qt.Key.Key_Return)
    assert sddm.calls == [("bob", "hunter22", 0)]


def test_up_and_down_cycle_through_accounts(greeter):
    view, root, _, _ = greeter
    QMetaObject.invokeMethod(field(root, "loginField"), "forceActiveFocus")
    QTest.keyClick(view, Qt.Key.Key_Down)
    assert root.property("userName") == "bob"
    assert field(root, "loginField").property("text") == "bob"
    QTest.keyClick(view, Qt.Key.Key_Up)
    QTest.keyClick(view, Qt.Key.Key_Up)
    assert root.property("userName") == "cy"
