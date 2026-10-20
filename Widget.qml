import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.andrecards.pjeoffice"

  property bool isOnline: false
  property bool hasToken: false
  property string tokenName: ""
  property bool popupOpen: false
  property bool popupWasOpen: false
  property string windowState: "ausente"
  readonly property string windowControlScript: {
    var home = Quickshell.env("HOME") || "/home/admin"
    return home + "/.config/omarchy/plugins/io.github.andrecards.pjeoffice/pje-window-control.sh"
  }

  // Dados dos Tribunais e Estados carregados do PJe Navegador
  property var estadosList: []
  property var tribunaisData: ({})
  property string selectedEstado: "MA"
  property var estadoOptions: []
  property string selectedTribunalUrl: ""
  property string tribunalSearchText: ""

  // Lista reativa e filtrada de tribunais do estado selecionado
  readonly property var filteredTribunais: {
    var uf = root.selectedEstado || "MA"
    var list = root.tribunaisData && root.tribunaisData[uf] ? root.tribunaisData[uf] : []
    var q = root.tribunalSearchText.toLowerCase().trim()
    if (!q) return list
    var out = []
    for (var i = 0; i < list.length; i++) {
      var item = list[i]
      var apelido = String(item.Apelido || "").toLowerCase()
      var nome = String(item.Nome || "").toLowerCase()
      if (apelido.indexOf(q) !== -1 || nome.indexOf(q) !== -1) {
        out.push(item)
      }
    }
    return out
  }

  visible: root.isOnline
  implicitWidth: root.isOnline ? button.implicitWidth : 0
  implicitHeight: root.isOnline ? button.implicitHeight : 0

  function close() {
    popupOpen = false
  }

  IpcHandler {
    target: "io.github.andrecards.pjeoffice"
    function toggle(): void {
      root.popupOpen = !root.popupOpen
    }
  }

  // Diretório de dados resiliente (Qt.resolvedUrl com fallback para o diretório padrão de plugins)
  readonly property string dataDir: {
    var raw = Qt.resolvedUrl("data").toString()
    if (raw.indexOf("file://") === 0) return raw.substring(7)
    var home = Quickshell.env("HOME") || "/home/admin"
    return home + "/.config/omarchy/plugins/" + root.moduleName + "/data"
  }

  // Carregamento dos dados JSON sincronizados com pje.jus.br/navegador
  FileView {
    id: estadosFile
    path: root.dataDir + "/estados.json"
    watchChanges: false
    printErrors: false
    onLoaded: {
      try {
        var raw = JSON.parse(text())
        if (Array.isArray(raw)) {
          root.estadosList = raw
          var opts = []
          for (var i = 0; i < raw.length; i++) {
            opts.push({
              value: String(raw[i].Sigla),
              label: String(raw[i].Sigla + " - " + raw[i].Nome)
            })
          }
          root.estadoOptions = opts
        }
      } catch (e) {
        console.error("Erro ao carregar estados.json:", e)
      }
    }
  }

  FileView {
    id: tribunaisFile
    path: root.dataDir + "/tribunais.json"
    watchChanges: false
    printErrors: false
    onLoaded: {
      try {
        var raw = JSON.parse(text())
        root.tribunaisData = raw
      } catch (e) {
        console.error("Erro ao carregar tribunais.json:", e)
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: false
    onTriggered: {
      if (!root.estadosList || root.estadosList.length === 0) estadosFile.reload()
      if (!root.tribunaisData || Object.keys(root.tribunaisData).length === 0) tribunaisFile.reload()
    }
  }

  onFilteredTribunaisChanged: {
    if (filteredTribunais.length > 0) {
      var found = false
      for (var i = 0; i < filteredTribunais.length; i++) {
        if (filteredTribunais[i].Link === selectedTribunalUrl) {
          found = true
          break
        }
      }
      if (!found) {
        selectedTribunalUrl = filteredTribunais[0].Link || ""
      }
    } else {
      selectedTribunalUrl = ""
    }
  }

  // Verifica se o PJeOffice Pro está ativo na porta 8800.
  // curl descarta o corpo da resposta HTTP no próprio producer (--output /dev/null),
  // eliminando qualquer risco de acumulação de memória por resposta grande.
  // Somente o código de saída é usado para determinar o estado online.
  Process {
    id: statusProc
    command: ["curl", "-s", "-k", "--max-time", "1", "--output", "/dev/null", "http://127.0.0.1:8800/"]
    onExited: function(exitCode, exitStatus) {
      root.isOnline = exitCode === 0
    }
  }

  Process {
    id: windowProc
    command: [root.windowControlScript, "auto-hide"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var nextState = text.trim()
        if (nextState.length > 0) root.windowState = nextState
      }
    }
    stderr: StdioCollector { waitForEnd: true }
  }

  Process {
    id: tokenProc
    command: ["opensc-tool", "-l"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = text.split("\n")
        var found = ""
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].toLowerCase().indexOf("yes") !== -1) { found = lines[i]; break }
        }
        var t = found.trim()
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
    stderr: StdioCollector { waitForEnd: true }
  }

  // Timer sempre ativo para detectar o estado tanto na inicialização
  // quanto durante o uso. Polling de 3 s garante responsividade sem overhead.
  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!statusProc.running) statusProc.running = true
      if (!tokenProc.running) tokenProc.running = true
      if (root.isOnline && !windowProc.running) windowProc.running = true
    }
  }

  Process {
    id: minimizeProc
    command: [root.windowControlScript, "minimize"]
    onExited: { if (!windowProc.running) windowProc.running = true }
  }

  Process {
    id: restoreProc
    command: [root.windowControlScript, "restore"]
    onExited: { if (!windowProc.running) windowProc.running = true }
  }

  Process {
    id: quitProc
    command: [root.windowControlScript, "quit"]
    onExited: {
      root.isOnline = false
      root.windowState = "encerrado"
      root.popupOpen = false
    }
  }

  function minimizePje() {
    if (!minimizeProc.running) minimizeProc.running = true
  }

  function restorePje() {
    if (!restoreProc.running) restoreProc.running = true
  }

  function quitPje() {
    if (!quitProc.running) quitProc.running = true
  }

  function openTokenAdmin() {
    if (root.bar) {
      root.bar.run("tokenadmin")
    }
  }

  function openTribunalUrl(targetUrl) {
    var url = targetUrl || root.selectedTribunalUrl
    if (url && root.bar) {
      root.bar.run("omarchy-launch-browser '" + url + "' || xdg-open '" + url + "'")
    }
  }

  readonly property color barForeground: bar ? bar.barForeground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color barIconColor: root.isOnline ? barForeground : Qt.darker(barForeground, 1.55)
  readonly property color statusColor: root.windowState === "minimizado" ? "#7dd3fc" : (root.windowState === "visivel" ? "#86efac" : "#fca5a5")

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "PJE"
    labelVisible: false
    horizontalMargin: 3
    fixedWidth: pjeIcon.implicitWidth + Style.spaceReal(button.horizontalMargin * 2)
    tooltipText: root.isOnline 
      ? ("PJeOffice Pro: Online" + (root.hasToken ? " (" + root.tokenName + ")" : " (Sem Token)"))
      : "PJeOffice Pro: Parado"
    active: root.popupOpen
    onPressed: function(btn) {
      root.popupOpen = !root.popupOpen
    }

    PjeIcon {
      id: pjeIcon
      anchors.centerIn: parent
      foreground: button.bar ? button.bar.barForeground : button.foreground
      fontFamily: button.fontFamily
      // Mantém a altura discreta dos ícones vizinhos e respeita o espaço disponível.
      iconHeight: Math.max(0, Math.min(Style.spaceReal(12), button.height - Style.spaceReal(2)))
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(340))
    contentHeight: popup.fittedContentHeight(cardCol.implicitHeight)
    onOpenChanged: {
      if (!open && root.popupWasOpen && root.isOnline) {
        Qt.callLater(function() { root.minimizePje() })
      }
      root.popupWasOpen = open
    }

    Column {
      id: cardCol
      anchors.fill: parent
      spacing: Style.space(8)

      // Header com título e status de conexão
      Column {
        width: parent.width
        spacing: Style.space(2)

        RowLayout {
          width: parent.width

          Text {
            Layout.fillWidth: true
            textFormat: Text.PlainText
            text: "PJe Office Pro"
            color: root.bar ? root.bar.foreground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            textFormat: Text.PlainText
          text: root.isOnline ? "ATIVO" : "PARADO"
          color: root.isOnline ? "#86efac" : "#fca5a5"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }

        Text {
          textFormat: Text.PlainText
          text: root.isOnline ? (root.hasToken ? "SERVIÇO ATIVO · TOKEN CONECTADO" : "SERVIÇO ATIVO · SEM TOKEN") : "SERVIÇO DESCONECTADO"
          color: root.isOnline ? (root.hasToken ? "#86efac" : "#facc15") : "#fca5a5"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          font.letterSpacing: 1.0
        }
      }

      // Detalhes do Token Físico Criptográfico
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

      Column {
        width: parent.width
        spacing: 0

        Button {
          width: parent.width
          height: Style.space(28)
          text: root.windowState === "minimizado" ? "Exibir PJe" : "Ocultar PJe"
          bordered: true
          accent: root.windowState === "minimizado" ? Color.accent : root.statusColor
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.isOnline
          onClicked: {
            if (root.windowState === "minimizado") root.restorePje()
            else root.minimizePje()
          }
        }
      }

      PanelSeparator {
        width: parent.width
      }

      // Seção de Seleção e Filtro Nacional do PJe (estilo PJe Navegador)
      Column {
        width: parent.width
        spacing: Style.space(6)

        PanelSectionHeader {
          width: parent.width
          text: "SELEÇÃO DE TRIBUNAL (PJe BRASIL)"
          foreground: root.bar ? root.bar.foreground : Color.foreground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        }

        // Seletor de Estado (UF)
        Dropdown {
          id: estadoDropdown
          width: parent.width
          label: "Estado / UF"
          options: root.estadoOptions
          value: root.selectedEstado
          foreground: root.bar ? root.bar.foreground : Color.foreground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          onChanged: function(newVal) {
            root.selectedEstado = newVal
            root.tribunalSearchText = ""
          }
        }

        // Campo de busca em tempo real para os tribunais daquele estado
        TextField {
          id: searchField
          width: parent.width
          placeholderText: "Buscar tribunal..."
          text: root.tribunalSearchText
          foreground: root.bar ? root.bar.foreground : Color.foreground
          accent: Color.accent
          onTextChanged: {
            root.tribunalSearchText = text
          }
        }

        // Lista rolável e integrada de Tribunais com rolagem dinâmica e scrollbar nativa
        BorderSurface {
          width: parent.width
          height: Style.space(130)
          radius: Style.cornerRadius
          color: Color.background
          borderSpec: Border.controlSpec("normal", root.bar ? root.bar.foreground : Color.foreground, Color.accent)

          ListView {
            id: tribunalList
            anchors.fill: parent
            anchors.margins: Style.space(2)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: Style.space(2)
            model: root.filteredTribunais

            QQC.ScrollBar.vertical: QQC.ScrollBar {
              policy: QQC.ScrollBar.AsNeeded
              width: Style.space(6)
            }

            Text {
              anchors.centerIn: parent
              visible: root.filteredTribunais.length === 0
              text: "Nenhum tribunal encontrado"
              color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.6)
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.bodySmall
            }

            delegate: CursorSurface {
              id: itemRoot
              required property var modelData
              required property int index

              width: tribunalList.width - (tribunalList.contentHeight > tribunalList.height ? Style.space(8) : 0)
              implicitHeight: itemCol.implicitHeight + Style.space(8)
              hasCursor: itemMouse.containsMouse
              current: modelData.Link === root.selectedTribunalUrl

              MouseArea {
                id: itemMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.selectedTribunalUrl = itemRoot.modelData.Link || ""
                }
                onDoubleClicked: {
                  root.selectedTribunalUrl = itemRoot.modelData.Link || ""
                  root.popupOpen = false
                  root.openTribunalUrl(root.selectedTribunalUrl)
                }
              }

              Column {
                id: itemCol
                anchors.left: parent.left
                anchors.right: selectIndicator.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Style.space(8)
                anchors.rightMargin: Style.space(4)
                spacing: Style.space(1)

                Text {
                  width: parent.width
                  textFormat: Text.PlainText
                  text: String(itemRoot.modelData.Apelido || itemRoot.modelData.Nome || "Tribunal")
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.bold: itemRoot.current
                  color: itemRoot.current 
                    ? Style.hoverStateColor(root.bar ? root.bar.foreground : Color.foreground, Color.accent) 
                    : (root.bar ? root.bar.foreground : Color.foreground)
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width
                  textFormat: Text.PlainText
                  visible: text !== "" && text !== itemRoot.modelData.Apelido
                  text: String(itemRoot.modelData.Nome || "")
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: Style.font.caption
                  color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.5)
                  elide: Text.ElideRight
                }
              }

              Text {
                id: selectIndicator
                anchors.right: parent.right
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                text: "󰄬"
                visible: itemRoot.current
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.bodySmall
                color: Color.accent
              }
            }
          }
        }

        // Botão para Abrir Tribunal Selecionado
        Button {
          width: parent.width
          text: "Ir ao Site do PJe"
          iconText: "󰌹"
          bordered: true
          accent: Color.accent
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.selectedTribunalUrl !== ""
          onClicked: {
            root.popupOpen = false
            root.openTribunalUrl(root.selectedTribunalUrl)
          }
        }
      }

      PanelSeparator {
        width: parent.width
      }

      // Ações do Sistema e PJeOffice
      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          text: "TokenAdmin"
          iconText: "󱐋"
          bordered: true
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          onClicked: {
            root.popupOpen = false
            root.openTokenAdmin()
          }
        }

        Button {
          Layout.fillWidth: true
          text: "Sair"
          iconText: "󰗼"
          bordered: true
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          onClicked: {
            root.quitPje()
          }
        }
      }
    }
  }
}
