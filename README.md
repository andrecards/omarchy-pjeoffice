# Omarchy PJeOffice Pro Widget

Plugin e widget de barra para o ambiente [Omarchy](https://omarchy.org), desenvolvido para monitoramento em tempo real do status do **PJeOffice Pro** e detecção de tokens criptográficos A3 (StarSign, SafeSign, etc.) utilizados por advogados e operadores do direito.

---

## 🎯 Funcionalidades

- **Status do PJeOffice Pro:** Verifica se o serviço local do PJeOffice Pro está ativo e respondendo na porta local (`http://127.0.0.1:8800/`).
- **Detecção de Token A3:** Monitora via `opensc-tool` se o token criptográfico USB está inserido e reconhecido pelo sistema.
- **Painel Interativo:** Clique no widget para abrir um painel com detalhes de conexão, nome do token e atalhos rápidos.
- **Integração com o System Tray / OMAT:** Pode ser utilizado solto na barra ou aninhado dentro da gaveta retrátil de segundo plano do Omarchy Tray (`io.github.tyrichards.tray`).

---

## 📦 Estrutura do Plugin

```text
omarchy-pjeoffice/
├── manifest.json   # Metadados e contrato do widget para o Quickshell
├── Widget.qml      # Interface gráfica (BarWidget) e lógica de monitoramento
├── README.md       # Documentação do projeto
└── LICENSE         # Licença de uso
```

---

## 🚀 Instalação Manual

1. Copie ou clone este repositório para a pasta de plugins do usuário:
   ```bash
   cp -r omarchy-pjeoffice ~/.config/omarchy/plugins/admin.pjeoffice
   ```
2. Adicione ou posicione o widget na barra via comando do Omarchy:
   ```bash
   omarchy bar put admin.pjeoffice --section right
   ```
3. O shell recarregará automaticamente com as novas configurações.

---

## ⚖️ Licença

Distribuído sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
