import QtQuick
import QtQuick.Shapes
import qs.Commons

// Componente oficial do Símbolo Vetorial do PJe para Omarchy
// Bicolor Dinâmico: 'P' e 'J' acompanham a cor do texto da barra, e 'e' adota a cor de destaque (Color.accent)
Item {
  id: root

  property var bar: null
  property real iconHeight: Style.bar.iconCanvas
  property real iconWidth: Math.round(iconHeight * (74.96 / 42.1))
  
  property color pjColor: root.bar ? root.bar.foreground : Color.foreground
  property color eColor: Color.accent

  implicitWidth: iconWidth
  implicitHeight: iconHeight
  width: implicitWidth
  height: implicitHeight

  Shape {
    id: shape
    anchors.centerIn: parent
    width: 74.96
    height: 42.1
    scale: Math.min(root.width / 74.96, root.height / 42.1)
    antialiasing: true
    layer.enabled: true
    layer.samples: 4

    // Letra P oficial PJe
    ShapePath {
      fillColor: root.pjColor
      strokeWidth: 0
      PathSvg {
        path: "m 30.25,13.45 c 0,6.84 -4,13.49 -13.24,13.49 H 7.43 v 8.41 A 6.68,6.68 0 0 1 0.77,42.06 H 0 V 2.88 A 2.88,2.88 0 0 1 2.88,0 h 14.13 c 9.28,0 13.24,6.77 13.24,13.49 m -7.48,-0.04 c 0,-3.3 -1.71,-6.84 -6,-6.84 h -9.4 v 13.65 h 9.21 c 4.4,0 6.17,-3.35 6.17,-6.77"
      }
    }

    // Letra J oficial PJe
    ShapePath {
      fillColor: root.pjColor
      strokeWidth: 0
      PathSvg {
        path: "m 22.77,39.64 v 0 a 5.27,5.27 0 0 1 5.26,-4.7 v 0 c 4.34,0 6,-3.11 6,-6.84 V 7.45 A 7.45,7.45 0 0 1 41.48,0 v 28.1 c 0,7.51 -3.6,14 -13.43,14 a 21.7,21.7 0 0 1 -3.87,-0.52 1.79,1.79 0 0 1 -1.41,-1.94"
      }
    }

    // Letra e oficial PJe
    ShapePath {
      fillColor: root.eColor
      strokeWidth: 0
      PathSvg {
        path: "m 74.68,21.57 h -22 c 0.8,4 3.85,6 8.06,6 a 10.15,10.15 0 0 0 6.25,-2 2.84,2.84 0 0 1 3.48,0 3.21,3.21 0 0 1 0.08,5 16.17,16.17 0 0 1 -10.18,3.39 c -8.54,0 -15,-6 -15,-14.9 0,-9.09 6.83,-14.83 15,-14.83 8.17,0 14.59,5.68 14.59,14.59 a 24.38,24.38 0 0 1 -0.18,2.75 m -7.01,-4.95 c -0.43,-3.9 -3.42,-6.16 -7.38,-6.16 -3.96,0 -6.9,1.83 -7.76,6.16 z"
      }
    }
  }
}
