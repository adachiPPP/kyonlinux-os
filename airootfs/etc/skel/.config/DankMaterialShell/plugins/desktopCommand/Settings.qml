import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import QtQuick.Controls.Material


PluginSettings {
    id: root
    pluginId: "desktopCommand"

    property string defaultCommand: "fastfetch --logo-type builtin"
    property int defaultFontSize: Theme.fontSizeSmall
    property string command: root.loadValue("command", defaultCommand)
    property bool autoRefresh: root.loadValue("autoRefresh", false)
    property bool useDank16: root.loadValue("useDank16", true)
    property string commandTimeout: String(root.loadValue("commandTimeout", "1"))
    property string refreshInterval: String(root.loadValue("refreshInterval", "5"))
    property int fontSize: String(root.loadValue("fontSize", defaultFontSize))
    property int backgroundOpacity: root.loadValue("backgroundOpacity", 50)
    property bool enableBorder: root.loadValue("enableBorder", false)
    property int borderThickness: root.loadValue("borderThickness", 1)
    property int borderOpacity: root.loadValue("borderOpacity", 100)
    property string borderColor: {
        let setting = root.loadValue("borderColor", "primary")
        if(["primary", "secondary", "surface"].includes(setting)) {
            return setting
        } else {
            return "primary"
        }
    }

    function sanitizeIntInput(textValue, fallback) {
        const cleaned = String(textValue ?? "").replace(/[^0-9]/g, "")
        return cleaned.length > 0 ? cleaned : String(fallback)
    }

    function sanitizeDecimalInput(textValue, fallback) {
        let cleaned = String(textValue ?? "").replace(/[^0-9.]/g, "")
        const dot = cleaned.indexOf(".")
        if (dot !== -1) {
            cleaned = cleaned.slice(0, dot + 1) + cleaned.slice(dot + 1).replace(/\./g, "")
        }
        return cleaned.length > 0 ? cleaned : String(fallback)
    }

    StyledText {
        text: I18n.tr("Command Settings")
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    Column {
        id: content
        spacing: Theme.spacingM
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            spacing: Theme.spacingXS
            width: parent.width

            StyledText {
                text: I18n.tr("Shell command")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                text: I18n.tr("Shell command to run and display.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
            }

            DankTextField {
                id: commandField
                width: parent.width
                height: 40
                text: command
                placeholderText: defaultCommand
                backgroundColor: Theme.surfaceContainer
                textColor: Theme.surfaceText
            }
        }

        Column {
            spacing: Theme.spacingXS
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right

            StyledText {
                text: I18n.tr("Command Timeout (seconds)")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                text: I18n.tr("Maximum amount of time to run the command.<br />Important when running commands taht never exit, like TUI apps.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
            }

            DankTextField {
                id: timeoutField
                width: parent.width
                height: 40
                text: commandTimeout
                placeholderText: "1"
                backgroundColor: Theme.surfaceContainer
                textColor: Theme.surfaceText

                onEditingFinished: {
                    commandTimeout = sanitizeDecimalInput(text, "1")
                    text = commandTimeout
                }
            }
        }

        Column {
            spacing: Theme.spacingS
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: autoRefreshToggle
                checked: autoRefresh
                anchors.left: parent.left
                leftPadding: Theme.spacingS
                Material.accent: Theme.primary

                Component.onCompleted: {
                    this.indicator.anchors.left = this.left
                    this.indicator.anchors.leftMargin = Theme.spacingM
                }

                contentItem: StyledText {
                    text: I18n.tr("Auto Refresh")
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    leftPadding: autoRefreshToggle.indicator.width + Theme.spacingM + Theme.spacingS
                    verticalAlignment: Text.AlignVCenter
                }
            }

            StyledText {
                text: I18n.tr("Automatically rerun the command on the chosen interval.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width - autoRefreshToggle.width - Theme.spacingS
            }
        }

        Column {
            spacing: Theme.spacingXS
            width: parent.width

            StyledText {
                text: I18n.tr("Refresh Interval (seconds)")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
                opacity: autoRefreshToggle.checked ? 1.0 : 0.2
            }

            StyledText {
                text: I18n.tr("How often to rerun the command (supports decimals).")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                opacity: autoRefreshToggle.checked ? 1.0 : 0.2
            }

            DankTextField {
                id: intervalField
                width: parent.width
                height: 40
                text: refreshInterval
                placeholderText: "5"
                backgroundColor: Theme.surfaceContainer
                textColor: Theme.surfaceText
                enabled: autoRefreshToggle.checked
                opacity: autoRefreshToggle.checked ? 1.0 : 0.2

                onEditingFinished: {
                    refreshInterval = sanitizeDecimalInput(text, "5")
                    text = refreshInterval
                }
            }
        }

        DankButton {
            text: I18n.tr("Save command settings")
            width: parent.width
            onClicked: {
                command = commandField.text.trim()
                root.saveValue("command", command)

                root.saveValue("autoRefresh", autoRefreshToggle.checked)

                commandTimeout = sanitizeDecimalInput(timeoutField.text, "1")
                root.saveValue("commandTimeout", commandTimeout)

                refreshInterval = sanitizeDecimalInput(intervalField.text, "5")
                root.saveValue("refreshInterval", refreshInterval)

                commandField.text = command
                timeoutField.text = commandTimeout
                intervalField.text = refreshInterval
            }
        }

        Column {
            topPadding: Theme.spacingL*2
            spacing: Theme.spacingXS
            width: parent.width

            StyledText {
                text: I18n.tr("Appearance Settings")
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            Item {
                width: parent.width
                height: Theme.spacingM
            }

            SliderSetting {
                settingKey: "fontSize"
                label: I18n.tr("Font size (px)")
                description: I18n.tr("Default monospace font is being used,<br />but you can set a custom size.")
                defaultValue: fontSize
                minimum: 8
                maximum: 100
                unit: "px"
            }

            Item {
                width: parent.width
                height: Theme.spacingM
            }

            SliderSetting {
                settingKey: "backgroundOpacity"
                label: I18n.tr("Background Opacity")
                defaultValue: backgroundOpacity
                minimum: 0
                maximum: 100
                unit: "%"
            }

            Item {
                width: parent.width
                height: Theme.spacingM
            }

            ToggleSetting {
                id: borderToggle
                settingKey: "enableBorder"
                label: I18n.tr("Enable border")
                defaultValue: enableBorder
            }

            SliderSetting {
                opacity: enableBorder ? 1.0 : 0.2
                enabled: enableBorder
                settingKey: "borderThickness"
                label: I18n.tr("Border Thickness")
                defaultValue: borderThickness
                minimum: 1
                maximum: 10
                unit: "px"
            }

            SliderSetting {
                opacity: enableBorder ? 1.0 : 0.2
                enabled: enableBorder
                settingKey: "borderOpacity"
                label: I18n.tr("Border Opacity")
                defaultValue: borderOpacity
                minimum: 0
                maximum: 100
                unit: "%"
            }

            SelectionSetting {
                opacity: enableBorder ? 1.0 : 0.2
                enabled: enableBorder
                settingKey: "borderColor"
                label: I18n.tr("Border Color")
                options: [
                    { label: I18n.tr("Primary"), value: "primary" },
                    { label: I18n.tr("Secondary"), value: "secondary" },
                    { label: I18n.tr("Surface"), value: "surface" },
                ]
                defaultValue: borderColor
            }

            Item {
                width: parent.width
                height: Theme.spacingM
            }

            ToggleSetting {
                settingKey: "useDank16"
                label: I18n.tr("Use Dank16 Colorscheme")
                description: I18n.tr("Will be applied after the next refresh.")
                defaultValue: useDank16
            }
        }
    }
}
