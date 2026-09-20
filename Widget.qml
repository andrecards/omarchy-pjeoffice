import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "admin.pjeoffice"

  property bool isOnline: false
  property bool hasToken: false
  property string tokenName: ""
  property bool popupOpen: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function close() {
    popupOpen = false
  }

  IpcHandler {
    target: "admin.pjeoffice"
    function toggle(): void {
      root.popupOpen = !root.popupOpen
    }
  }

  Process {
    id: statusProc
    command: ["bash", "-c", "curl -s -k --max-time 1 http://127.0.0.1:8800/ >/dev/null 2>&1 && echo 'ONLINE' || echo 'OFFLINE'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.isOnline = text.trim() === "ONLINE"
      }
    }
  }

  Process {
    id: tokenProc
    command: ["bash", "-c", "opensc-tool -l 2>/dev/null | grep -i 'yes' | head -n 1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var t = text.trim()
        if (t.length > 0) {
          root.hasToken = true
          if (t.indexOf("StarSign") !== -1) {
            root.tokenName = "StarSign CUT S"
          } else {
            root.tokenName = "Token Conectado"
          }
        } else {
          root.hasToken = false
          root.tokenName = "Nenhum token detectado"
        }
      }
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!statusProc.running) statusProc.running = true
      if (!tokenProc.running) tokenProc.running = true
    }
  }

  function launchPje() {
    if (root.bar) {
      root.bar.run("/home/admin/.local/share/pjeoffice-pro/pjeoffice-pro/pjeoffice-pro.sh")
    }
  }

  function restartPje() {
    if (root.bar) {
      root.bar.run("pkill -f 'pjeoffice-pro.jar' 2>/dev/null; sleep 1; /home/admin/.local/share/pjeoffice-pro/pjeoffice-pro/pjeoffice-pro.sh")
    }
  }

  function openTokenAdmin() {
    if (root.bar) {
      root.bar.run("tokenadmin")
    }
  }

  function openTJMA() {
    if (root.bar) {
      root.bar.run("omarchy-launch-browser 'https://pje.tjma.jus.br/' || xdg-open 'https://pje.tjma.jus.br/'")
    }
  }

  function openTRF1() {
    if (root.bar) {
      root.bar.run("omarchy-launch-browser 'https://pje1g.trf1.jus.br/' || xdg-open 'https://pje1g.trf1.jus.br/'")
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "PJE"
    fontSize: Style.font.bodySmall
    fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    horizontalMargin: 6
    labelVisible: false
    tooltipText: root.isOnline 
      ? ("PJeOffice Pro: Online" + (root.hasToken ? " (" + root.tokenName + ")" : " (Sem Token)"))
      : "PJeOffice Pro: Parado"
    onPressed: function(btn) {
      root.popupOpen = !root.popupOpen
    }

    Text {
      anchors.centerIn: parent
      text: "PJE"
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      font.weight: Font.ExtraBold
      color: button.active && button.useActiveColor ? button.activeColor : button.foreground
      renderType: Text.NativeRendering
    }

    Rectangle {
      width: 5
      height: 5
      radius: 2.5
      anchors.right: parent.right
      anchors.rightMargin: 1
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 4
      color: root.isOnline ? (root.hasToken ? "#2ecc71" : "#f39c12") : "#e74c3c"
      border.width: 1
      border.color: "#000000"
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(260))
    contentHeight: popup.fittedContentHeight(cardCol.implicitHeight)

    Column {
      id: cardCol
      anchors.fill: parent
      spacing: Style.space(8)

      Column {
        width: parent.width
        spacing: Style.space(2)

        Text {
          textFormat: Text.PlainText
          text: "PJE"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.title
          font.bold: true
        }

        Text {
          textFormat: Text.PlainText
          text: root.isOnline ? (root.hasToken ? "ONLINE • TOKEN PRONTO" : "ONLINE • SEM TOKEN") : "DESCONECTADO"
          color: root.isOnline ? (root.hasToken ? "#2ecc71" : "#f39c12") : "#e74c3c"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          font.letterSpacing: 1.2
        }
      }

      PanelSeparator {
        width: parent.width
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Rectangle {
          width: 8
          height: 8
          radius: 4
          color: root.hasToken ? "#2ecc71" : "#e74c3c"
        }

        Text {
          Layout.fillWidth: true
          text: root.hasToken ? root.tokenName : "Nenhum token inserido"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          color: root.bar ? root.bar.foreground : Color.foreground
          elide: Text.ElideRight
        }
      }

      PanelSeparator {
        width: parent.width
      }

      Button {
        width: parent.width
        text: "Abrir TJMA PJe"
        bordered: true
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: {
          root.popupOpen = false
          root.openTJMA()
        }
      }

      Button {
        width: parent.width
        text: "Abrir TRF1 PJe"
        bordered: true
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: {
          root.popupOpen = false
          root.openTRF1()
        }
      }

      Button {
        width: parent.width
        text: "Gerenciador TokenAdmin"
        bordered: true
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: {
          root.popupOpen = false
          root.openTokenAdmin()
        }
      }

      Button {
        width: parent.width
        text: root.isOnline ? "Reiniciar PJeOffice" : "Iniciar PJeOffice"
        bordered: true
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: {
          root.popupOpen = false
          if (root.isOnline) {
            root.restartPje()
          } else {
            root.launchPje()
          }
        }
      }
    }
  }
}
