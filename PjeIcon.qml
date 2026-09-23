import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Ui

// PjeIcon.qml — Componente vetorial nativo seguindo rigorosamente o padrão dos plugins do Omarchy (TailscaleIcon)
// Dimensões compactas (Style.space(11)), círculo estilizado, marca oficial do PJe,
// suporte a estado 'crossed' (-45° slash quando offline) e badge de aviso '!' (quando sem token).
Item {
  id: root

  property real iconSize: Style.space(11)
  property color color: Color.foreground
  property color badgeColor: Color.urgent
  property bool crossed: false
  property bool warning: false

  width: iconSize
  height: iconSize
  implicitWidth: iconSize
  implicitHeight: iconSize

  // Círculo externo no padrão estético nativo dos plugins do Omarchy
  Rectangle {
    id: circle
    anchors.fill: parent
    radius: width / 2
    color: "transparent"
    border.width: 1.0
    border.color: root.color
    antialiasing: true
  }

  // Letras oficiais do PJe (P, J, e) harmonizadas e centralizadas no interior do círculo
  Item {
    id: glyphsContainer
    anchors.centerIn: parent
    readonly property real markWidth: Math.round(root.width * 0.62)
    readonly property real markHeight: markWidth * (42.1 / 74.96)
    width: markWidth
    height: markHeight

    Shape {
      anchors.centerIn: parent
      width: 74.96
      height: 42.1
      scale: Math.min(parent.width / 74.96, parent.height / 42.1)
      antialiasing: true
      layer.enabled: true
      layer.samples: 4

      // Letra P oficial PJe
      ShapePath {
        fillColor: root.color
        strokeWidth: 0
        PathSvg {
          path: "m 30.25,13.45 c 0,6.84 -4,13.49 -13.24,13.49 H 7.43 v 8.41 A 6.68,6.68 0 0 1 0.77,42.06 H 0 V 2.88 A 2.88,2.88 0 0 1 2.88,0 h 14.13 c 9.28,0 13.24,6.77 13.24,13.49 m -7.48,-0.04 c 0,-3.3 -1.71,-6.84 -6,-6.84 h -9.4 v 13.65 h 9.21 c 4.4,0 6.17,-3.35 6.17,-6.77"
        }
      }

      // Letra J oficial PJe
      ShapePath {
        fillColor: root.color
        strokeWidth: 0
        PathSvg {
          path: "m 22.77,39.64 v 0 a 5.27,5.27 0 0 1 5.26,-4.7 v 0 c 4.34,0 6,-3.11 6,-6.84 V 7.45 A 7.45,7.45 0 0 1 41.48,0 v 28.1 c 0,7.51 -3.6,14 -13.43,14 a 21.7,21.7 0 0 1 -3.87,-0.52 1.79,1.79 0 0 1 -1.41,-1.94"
        }
      }

      // Letra e oficial PJe
      ShapePath {
        fillColor: root.color
        strokeWidth: 0
        PathSvg {
          path: "m 74.68,21.57 h -22 c 0.8,4 3.85,6 8.06,6 a 10.15,10.15 0 0 0 6.25,-2 2.84,2.84 0 0 1 3.48,0 3.21,3.21 0 0 1 0.08,5 16.17,16.17 0 0 1 -10.18,3.39 c -8.54,0 -15,-6 -15,-14.9 0,-9.09 6.83,-14.83 15,-14.83 8.17,0 14.59,5.68 14.59,14.59 a 24.38,24.38 0 0 1 -0.18,2.75 m -7.01,-4.95 c -0.43,-3.9 -3.42,-6.16 -7.38,-6.16 -3.96,0 -6.9,1.83 -7.76,6.16 z"
        }
      }
    }
  }

  // Linha diagonal cortando o ícone quando desconectado / offline (seguindo o padrão Tailscale)
  Rectangle {
    visible: root.crossed
    anchors.centerIn: parent
    width: parent.width * 1.25
    height: Math.max(1.5, parent.height * 0.14)
    radius: height / 2
    color: root.color
    rotation: -45
    antialiasing: true
  }

  // Badge de alerta quando online mas sem token criptográfico
  BorderSurface {
    visible: root.warning
    width: Math.max(7, parent.width * 0.42)
    height: width
    radius: width / 2
    color: root.badgeColor
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    borderSpec: Border.flat(Color.popups.background, 1)

    Text {
      anchors.centerIn: parent
      text: "!"
      color: Color.background
      font.family: Style.font.family
      font.pixelSize: Math.max(5, parent.height * 0.72)
      font.bold: true
    }
  }
}
