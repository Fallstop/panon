import QtQuick 2.15
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "." as AppUi

PlasmoidItem {

    readonly property var cfg:plasmoid.configuration

    preferredRepresentation: Plasmoid.compactRepresentation

    compactRepresentation: Component {
        Spectrum{}
    }

    fullRepresentation: Component {
        Spectrum{}
    }

    toolTipItem: cfg.hideTooltip?tooltipitem:null

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    Item{id:tooltipitem}

    Shortcut {
        sequences: [ StandardKey.Preferences, "Ctrl+Alt+C" ]
        context: Qt.ApplicationShortcut
        onActivated: {
            var configureAction = plasmoid.action ? plasmoid.action("configure") : null
            if(configureAction)
                configureAction.trigger()
            else {
                console.warn("[Panon] Configure action missing; opening inline settings dialog for testing")
                devConfigDialog.open()
            }
        }
    }

    AppUi.DevConfigDialog {
        id: devConfigDialog
    }

}
