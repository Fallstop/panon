import QtQuick 2.0
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

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

}
