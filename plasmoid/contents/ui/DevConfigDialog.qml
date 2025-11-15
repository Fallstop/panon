import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasmoid 2.0

Kirigami.Dialog {
    id: root
    objectName: "devConfigDialog"
    modal: true
    padding: Kirigami.Units.largeSpacing
    title: i18nc("@title:window", "Panon Settings (Inline)")
    preferredWidth: Kirigami.Units.gridUnit * 60
    preferredHeight: Kirigami.Units.gridUnit * 40
    standardButtons: Kirigami.Dialog.NoButton

    readonly property var categories: [
        ({
            name: i18nc("@title", "General"),
            icon: "applications-multimedia",
            source: Qt.resolvedUrl("config/ConfigGeneral.qml"),
            configKeys: [
                "fps",
                "showFps",
                "hideTooltip",
                "preferredWidth",
                "autoExtend",
                "autoHide",
                "animateAutoHiding",
                "gravity",
                "inversion"
            ]
        }),
        ({
            name: i18nc("@title", "Visual Effects"),
            icon: "applications-graphics",
            source: Qt.resolvedUrl("config/ConfigEffect.qml"),
            configKeys: [
                "visualEffect",
                "effectArgValues",
                "effectArgTrigger"
            ]
        }),
        ({
            name: i18nc("@title", "Back-end"),
            icon: "preferences-desktop-sound",
            source: Qt.resolvedUrl("config/ConfigBackend.qml"),
            configKeys: [
                "reduceBass",
                "glDFT",
                "debugBackend",
                "bassResolutionLevel",
                "backendIndex",
                "fifoPath",
                "deviceIndex",
                "pulseaudioDevice"
            ]
        }),
        ({
            name: i18nc("@title", "Colors"),
            icon: "preferences-desktop-color",
            source: Qt.resolvedUrl("config/ConfigColors.qml"),
            configKeys: [
                "colorSpaceHSL",
                "colorSpaceHSLuv",
                "hslHueFrom",
                "hslHueTo",
                "hsluvHueFrom",
                "hsluvHueTo",
                "hslSaturation",
                "hslLightness",
                "hsluvSaturation",
                "hsluvLightness"
            ]
        })
    ]

    property var categoryPages: categories.map(() => null)
    property var categoryLoadedFlags: categories.map(() => false)

    function configPropertyName(key) {
        return "cfg_" + key
    }

    function loadCategoryConfig(index) {
        var page = categoryPages[index]
        if (!page) {
            return
        }
        var keys = categories[index].configKeys || []
        keys.forEach(function(key) {
            var prop = configPropertyName(key)
            if (!(prop in page)) {
                return
            }
            var value = plasmoid.configuration[key]
            if (value === undefined) {
                return
            }
            page[prop] = value
        })
    }

    function saveCategoryConfig(index) {
        var page = categoryPages[index]
        if (!page) {
            return
        }
        var keys = categories[index].configKeys || []
        keys.forEach(function(key) {
            var prop = configPropertyName(key)
            if (!(prop in page)) {
                return
            }
            plasmoid.configuration[key] = page[prop]
        })
    }

    function applyAll() {
        for (var i = 0; i < categoryPages.length; ++i) {
            saveCategoryConfig(i)
            var page = categoryPages[i]
            if (page && page.save) {
                page.save()
            }
        }
        if (plasmoid.configuration.sync) {
            plasmoid.configuration.sync()
        }
    }

    function registerCategoryPage(index, page) {
        var updatedPages = categoryPages.slice()
        updatedPages[index] = page
        categoryPages = updatedPages

        var updatedFlags = categoryLoadedFlags.slice()
        updatedFlags[index] = page !== null
        categoryLoadedFlags = updatedFlags
    }

    onVisibleChanged: if (visible) {
        for (var i = 0; i < categoryPages.length; ++i) {
            loadCategoryConfig(i)
        }
    }

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.TabBar {
            id: tabBar
            Layout.fillWidth: true
            Repeater {
                model: root.categories
                QQC2.TabButton {
                    text: modelData.name
                    icon.name: modelData.icon
                }
            }
        }

        StackLayout {
            id: pageStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            Repeater {
                model: root.categories

                delegate: QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Loader {
                        id: pageLoader
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        source: modelData.source
                        onLoaded: {
                            root.registerCategoryPage(index, item)
                            root.loadCategoryConfig(index)
                        }
                    }
                }
            }
        }
    }

    footer: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Item {
            Layout.fillWidth: true
        }

        QQC2.Button {
            text: i18nc("@action:button", "Apply")
            icon.name: "dialog-ok-apply"
            enabled: root.categoryLoadedFlags.some(function(flag) {
                return flag
            })
            onClicked: root.applyAll()
        }

        QQC2.Button {
            text: i18nc("@action:button", "Close")
            icon.name: "dialog-close"
            onClicked: root.close()
        }
    }
}
