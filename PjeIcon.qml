import QtQuick

// Somente o texto PJE: a cor acompanha a paleta ativa da barra.
Item {
  id: root

  required property color foreground
  property string fontFamily: "sans-serif"
  property real iconHeight: 12
  implicitWidth: iconHeight * 1.85
  implicitHeight: iconHeight

  Text {
    id: label
    text: "PJE"
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Math.max(1, root.iconHeight)
    font.bold: true
    scale: Math.min(root.width / Math.max(1, metrics.tightBoundingRect.width),
                    root.height / Math.max(1, metrics.tightBoundingRect.height))
    transformOrigin: Item.TopLeft
    x: (root.width - metrics.tightBoundingRect.width * scale) / 2 - metrics.tightBoundingRect.x * scale
    y: (root.height - metrics.tightBoundingRect.height * scale) / 2 - (metrics.tightBoundingRect.y + baselineOffset) * scale
    renderType: Text.QtRendering
  }

  TextMetrics {
    id: metrics
    font: label.font
    text: label.text
  }
}
