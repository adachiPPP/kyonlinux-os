import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    property string command: pluginData.command ?? ""
    property real refreshInterval: normalizeRefreshInterval(pluginData.refreshInterval)
    property bool autoRefresh: pluginData.autoRefresh ?? false
    property real commandTimeout: normalizeCommandTimeout(pluginData.commandTimeout) // seconds
    property bool hasRunInitial: false
    property string output: ""
    property int rows: 0
    property int cols: 0
    property var windowRef: null
    property int fontSizePx: normalizeFontSize(pluginData.fontSize)
    property bool useDank16: (pluginData.useDank16 ?? true) && Theme.dank16 !== null
    property real backgroundOpacity: (pluginData.backgroundOpacity ?? 50) / 100
    property bool enableBorder: pluginData.enableBorder ?? false
    property int borderThickness: pluginData.borderThickness ?? 1
    property real borderOpacity: (pluginData.borderOpacity ?? 100) / 100
    property string borderColor: pluginData.borderColor ?? "primary"
    property color resolvedBorderColor: {
        if (root.borderColor === "primary") {
            return Theme.primary
        } else if (root.borderColor === "secondary") {
            return Theme.secondary
        } else if (root.borderColor === "surface") {
            return Theme.surfaceText
        } else {
            return Theme.primary
        }
    }
    property string pluginUrl: ""
    property string pluginDir: ""
    property string wrapCommandPath: ""
    property var dank16: Theme.isLightMode ? Theme.dank16.light : Theme.dank16.dark

    FontMetrics {
        id: fontMetrics
        font.pixelSize: root.fontSizePx
        font.family: Theme.monoFontFamily
    }

    Timer {
        id: timer
        interval: root.refreshInterval
        repeat: true
        running: false
        onTriggered: runCommand()
    }

    // workaround for widget being spawned with weird size initially
    Timer {
        id: initialRunTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: root.handleVisibilityChange("timer")
    }

    Component.onCompleted: {
        root.windowRef = Window.window ?? null
        root.handleVisibilityChange("completed")
        const url = Qt.resolvedUrl("Widget.qml") || (typeof __qmlfile__ !== "undefined" ? __qmlfile__ : "")
        const cleanedUrl = String(url ?? "")
        const cleanedPath = cleanedUrl.startsWith("file://") ? cleanedUrl.slice("file://".length) : cleanedUrl
        const lastSlash = cleanedPath.lastIndexOf("/")
        root.pluginUrl = cleanedUrl
        root.pluginDir = lastSlash !== -1 ? cleanedPath.slice(0, lastSlash) : ""
        const resolvedWrapUrl = Qt.resolvedUrl("wrapCommand")
        const resolvedWrap = String(resolvedWrapUrl ?? "")
        root.wrapCommandPath = resolvedWrap
            ? resolvedWrap.replace(/^file:\/\//, "")
            : (root.pluginDir ? `${root.pluginDir}/wrapCommand` : "wrapCommand")
    }

    onVisibleChanged: {
        root.handleVisibilityChange("root.visible")
    }

    onWidgetWidthChanged: root.handleVisibilityChange("sizeChanged")
    onWidgetHeightChanged: root.handleVisibilityChange("sizeChanged")

    Component.onDestruction: {
        root.stopAllActivity("destruction")
    }

    onCommandChanged: {
        handleVisibilityChange("commandChanged")
    }

    onAutoRefreshChanged: {
        timer.running = root.autoRefresh && root.isRunnable()
        if (root.autoRefresh && root.hasRunInitial && root.isRunnable()) {
            timer.restart()
        }
    }

    onRefreshIntervalChanged: {
        if (timer.running) {
            timer.restart()
        }
    }

    function normalizeRefreshInterval(value) {
        const parsed = Number(value)
        if (!isFinite(parsed) || parsed <= 0) {
            return 60000
        }
        return parsed * 1000
    }

    function normalizeCommandTimeout(value) {
        const parsed = Number(value)
        if (!isFinite(parsed) || parsed <= 0) {
            return 5
        }
        return parsed
    }

    function normalizeFontSize(value) {
        const parsed = parseInt(value, 10)
        if (!isFinite(parsed) || parsed <= 0) {
            return Theme.fontSizeSmall
        }
        return parsed
    }

    function isRunnable() {
        const win = root.windowRef
        const winVisible = win === null ? true : !!win.visible

        // in other weird cases, it will just start on timer with 2s delay

        return root.visible && winVisible && root.widgetWidth > 0 && root.widgetHeight > 0
    }

    function isStartingEdgeCase(){
        if (root.widgetWidth == 500 || root.widgetWidth == 200) {
            initialRunTimer.start()
            return true
        }

        if (root.widgetHeight == 500 || root.widgetHeight == 200) {
            initialRunTimer.start()
            return true
        }

        return false
    }

    function handleVisibilityChange(source) {
        if(source == "commandChanged" || source == "root.visible"){
            root.hasRunInitial = false
        }
        if (!root.isRunnable()) {
            root.stopAllActivity(source)
            return
        }
        if (!root.hasRunInitial) {
            if(root.isStartingEdgeCase() && source != "timer"){
                return
            }
            root.hasRunInitial = true
            initialRunTimer.stop()
            runCommand()
        }
        if (root.autoRefresh) {
            timer.start()
        }
    }

    function runCommand() {
        if (!root.isRunnable()) {
            console.warn(`[desktopCommand] runCommand skipped; not runnable (visible=${root.visible} winVisible=${root.windowRef ? root.windowRef.visible : "n/a"}`)
            return
        }
        if (process.running) {
            console.warn(`[desktopCommand] runCommand skipped; process already running; command="${root.command}"`)
            return
        }
        root.updateTerminalSize()

        let command = `"${root.wrapCommandPath}" --width=${root.cols} --height=${root.rows} --timeout=${root.commandTimeout} `
        if (root.useDank16) {
            command += `--colors='${JSON.stringify(root.dank16)}' `
        }
        command += `-- ${JSON.stringify(root.command)}`

        process.command = ["sh", "-c", command]
        process.running = true
    }

    function updateTerminalSize() {
        const horizontalMargin = 0
        const verticalMargin = 8
        const availableWidth = Math.max(200, (root.widgetWidth ?? root.width) - horizontalMargin)
        const availableHeight = Math.max(200, (root.widgetHeight ?? root.height) - verticalMargin)

        root.cols = Math.max(1, Math.floor(availableWidth / Math.max(1, fontMetrics.averageCharacterWidth)))
        root.rows = Math.max(1, Math.floor(availableHeight / Math.max(1, fontMetrics.lineSpacing)))
    }

    function stopAllActivity(reason) {
        timer.stop()
        process.running = false
        root.output = ""
    }

    Process {
        id: process

        stdout: StdioCollector {
            onStreamFinished: {
                root.output = this.text
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainer, root.backgroundOpacity)
        visible: root.visible
        border.width: root.enableBorder ? root.borderThickness : 0
        border.color: Theme.withAlpha(root.resolvedBorderColor, root.borderOpacity)

        Text {
            anchors.fill: parent
            anchors.margins: 8
            text: root.output
            textFormat: Text.RichText
            wrapMode: Text.NoWrap
            color: useDank16? Theme.surfaceText : "#c0c0c0"
            font.pixelSize: root.fontSizePx
            font.family: Theme.monoFontFamily
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
        }
    }
}
