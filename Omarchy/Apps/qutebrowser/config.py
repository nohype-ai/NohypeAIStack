# qutebrowser config for this Omarchy machine.
# Copy to ~/.config/qutebrowser/config.py
#
# Ctrl+Super+F is Hyprland tiled fullscreen: the window stays in its tile and
# the client is marked fullscreen. Qt reports that on QWindow.windowStateChanged,
# not via QWidget.changeEvent. tabs.show and statusbar.show are process-wide, so
# a config.bind cycle would change every window. An exception here must not
# escape: qutebrowser closes every window on an uncaught exception.

config.load_autoconfig()

from qutebrowser.keyinput import modeman
from qutebrowser.mainwindow.mainwindow import MainWindow
from qutebrowser.mainwindow.statusbar.bar import StatusBar
from qutebrowser.mainwindow.tabwidget import TabBar
from qutebrowser.qt.core import QEvent, QTimer, Qt
from qutebrowser.utils import usertypes


def _client_fullscreen(window):
    return bool(getattr(window, "_omarchy_fullscreen", False))


def _sync_chrome(window, fullscreen=None):
    try:
        if fullscreen is None:
            fullscreen = _client_fullscreen(window)
        window._omarchy_fullscreen = bool(fullscreen)
        window.tabbed_browser.widget.tab_bar().maybe_hide()
        window.status.maybe_hide()
    except RuntimeError:
        return


def _schedule_sync(window, fullscreen):
    def run(window=window, fullscreen=fullscreen):
        _sync_chrome(window, fullscreen)

    QTimer.singleShot(0, run)


def _status_maybe_hide(self):
    StatusBar._omarchy_orig_maybe_hide(self)
    window = self.window()
    if not _client_fullscreen(window):
        return
    try:
        mode = modeman.instance(self._win_id).mode
    except modeman.UnavailableError:
        mode = usertypes.KeyMode.normal
    if mode == usertypes.KeyMode.normal:
        self.hide()
    else:
        self.show()


def _tab_maybe_hide(self):
    TabBar._omarchy_orig_maybe_hide(self)
    if _client_fullscreen(self.window()):
        self.hide()


def _change_event(self, event):
    MainWindow._omarchy_orig_change_event(self, event)
    if event.type() == QEvent.Type.WindowStateChange and hasattr(self, "status"):
        _schedule_sync(self, self.isFullScreen())


def _show_event(self, event):
    MainWindow._omarchy_orig_show_event(self, event)
    _connect_handle(self)


def _on_mode(*_args, window):
    _sync_chrome(window)


def _connect_modes(window):
    if getattr(window, "_omarchy_modes_connected", False):
        return
    window._omarchy_modes_connected = True
    sync = lambda *args, window=window: _on_mode(*args, window=window)
    mode_manager = modeman.instance(window.win_id)
    mode_manager.entered.connect(sync)
    mode_manager.left.connect(sync)


def _connect_handle(window):
    if getattr(window, "_omarchy_handle_connected", False):
        return
    handle = window.windowHandle()
    if handle is None:
        return
    window._omarchy_handle_connected = True
    handle.windowStateChanged.connect(
        lambda state, window=window: _schedule_sync(
            window, bool(state & Qt.WindowState.WindowFullScreen)
        )
    )


def _attach(window):
    _connect_modes(window)
    _connect_handle(window)
    _sync_chrome(window, window.isFullScreen())


def _init(self, *args, **kwargs):
    MainWindow._omarchy_orig_init(self, *args, **kwargs)
    _attach(self)


if not hasattr(TabBar, "_omarchy_orig_maybe_hide"):
    TabBar._omarchy_orig_maybe_hide = TabBar.maybe_hide
if not hasattr(StatusBar, "_omarchy_orig_maybe_hide"):
    StatusBar._omarchy_orig_maybe_hide = StatusBar.maybe_hide
if not hasattr(MainWindow, "_omarchy_orig_change_event"):
    MainWindow._omarchy_orig_change_event = MainWindow.changeEvent
if not hasattr(MainWindow, "_omarchy_orig_show_event"):
    MainWindow._omarchy_orig_show_event = MainWindow.showEvent
if not hasattr(MainWindow, "_omarchy_orig_init"):
    MainWindow._omarchy_orig_init = MainWindow.__init__

TabBar.maybe_hide = _tab_maybe_hide
StatusBar.maybe_hide = _status_maybe_hide
MainWindow.changeEvent = _change_event
MainWindow.showEvent = _show_event
MainWindow.__init__ = _init

try:
    from qutebrowser.misc import objects
except ImportError:
    objects = None

if objects is not None and objects.qapp is not None:
    for widget in objects.qapp.topLevelWidgets():
        if isinstance(widget, MainWindow):
            _attach(widget)
