import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as QQC2

import org.kde.kcmutils as KCM
import org.kde.kirigami 2.3 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.newstuff 1.1 as NewStuff

import "utils.js" as Utils

KCM.SimpleKCM {
    id: root

    property string cfg_visualEffect
    property var cfg_effectArgValues: []
    property bool cfg_effectArgTrigger: false

    readonly property string sh_get_visual_effects: Utils.chdir_scripts_root() + "python3 -m panon.effect.get_effect_list"
    readonly property string sh_read_effect_hint: Utils.chdir_scripts_root() + "python3 -m panon.effect.read_file \"" + root.cfg_visualEffect + "\" hint.html"
    readonly property string sh_read_effect_args: Utils.chdir_scripts_root() + "python3 -m panon.effect.read_file \"" + root.cfg_visualEffect + "\" meta.json"

    Kirigami.FormLayout {
        id: formLayout

        anchors.left: parent.left
        anchors.right: parent.right

        NewStuff.Button {
            downloadNewWhat: i18n("Effects")
            configFile: Utils.get_root() + "/config/panon.knsrc"
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Effect:")
            Layout.fillWidth: true

            QQC2.ComboBox {
                id: visualeffect
                model: ListModel {
                    id: shaderOptions
                }
                textRole: "name"
                onCurrentIndexChanged: root.cfg_visualEffect = shaderOptions.get(currentIndex).id
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Hint:")
            Layout.fillWidth: true
            visible: hint.text.length > 0

            QQC2.Label {
                id: hint
                text: ""
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }

        property bool firstTimeLoadArgs: true
        property var effect_arguments: []

        Plasma5Support.DataSource {
            engine: "executable"
            connectedSources: {
                if (shaderOptions.count < 1) {
                    return [root.sh_get_visual_effects]
                }
                return [root.sh_read_effect_hint, root.sh_read_effect_args]
            }

            // Text field components used to represent the arguments of the visual effect.
            property var textfieldlst: []

            onNewData: function (sourceName, data) {
                if (sourceName === root.sh_read_effect_hint) {
                    hint.text = data.stdout
                } else if (sourceName === root.sh_read_effect_args) {
                    if (data.stdout.length > 0) {
                        effect_arguments = JSON.parse(data.stdout).arguments
                        textfieldlst.map(function (o) { o.visible = false })
                        for (var index = 0; index < effect_arguments.length; ++index) {
                            var arg = effect_arguments[index]
                            if (!firstTimeLoadArgs) {
                                root.cfg_effectArgValues[index] = arg.default
                            }

                            var component = Qt.createComponent({
                                "int": "EffectArgumentInt.qml",
                                "double": "EffectArgumentDouble.qml",
                                "float": "EffectArgumentDouble.qml",
                                "bool": "EffectArgumentBool.qml",
                                "color": "EffectArgumentColor.qml",
                            }[arg.type] || "EffectArgument.qml")

                            var obj = component.createObject(formLayout, {
                                index: index,
                                root: formLayout,
                            })
                            textfieldlst.push(obj)
                        }
                    }
                    firstTimeLoadArgs = false
                } else if (sourceName === root.sh_get_visual_effects) {
                    var lst = JSON.parse(data.stdout)
                    for (var i in lst) {
                        shaderOptions.append(lst[i])
                    }
                    var ci = 0
                    for (var j = 0; j < lst.length; ++j) {
                        if (shaderOptions.get(j).name === "default") {
                            ci = j
                        }
                        if (shaderOptions.get(j).id === root.cfg_visualEffect) {
                            ci = j
                        }
                    }
                    visualeffect.currentIndex = ci
                }
            }
        }
    }

    onCfg_visualEffectChanged: {
        hint.text = ""
        formLayout.effect_arguments = []
    }
}

