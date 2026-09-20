# Omarchy PJeOffice Pro & Token Monitor

[![Omarchy Plugin](https://img.shields.io/badge/Omarchy-Quattro%20Plugin-blue?style=flat-square)](https://plugins.omarchy.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

BarWidget e monitor em segundo plano do **PJeOffice Pro**, autenticadores de certificados digitais A3 (SafeSign, StarSign CUT, etc.) e acesso rápido unificado aos tribunais brasileiros com suporte a PJe para o ambiente [Omarchy](https://omarchy.org).

Projetado para operar tanto diretamente na barra principal do Omarchy quanto de forma integrada e retrátil dentro da gaveta do **Tray** (`io.github.tyrichards.tray`), atrás do chevron `<`.

---

## Recursos

- **Monitoramento em Segundo Plano:** Detecta automaticamente se o serviço local do PJeOffice Pro (`http://127.0.0.1:8800/`) está online.
- **Detecção de Token Criptográfico A3:** Monitora via `opensc-tool` a inserção e presença de cartões inteligentes e tokens USB (ex: StarSign CUT S).
- **Acesso Rápido a Tribunais (PJe Brasil):** Filtro e pesquisa em tempo real por Estado (UF) e nome/apelido de dezenas de tribunais (TJ, TRF, TRT, etc.) sincronizados com a base nacional do PJe.
- **Controle do Ciclo de Vida:** Botões integrados para abrir o **TokenAdmin** ou **Sair** (encerrar o processo do autenticador de forma segura).
- **Ocultação Inteligente:** Quando o serviço está offline, o widget se retrai e desocupa espaço na barra ou gaveta.

---

## Pré-requisitos

- **Omarchy Quattro** (com `omarchy-shell` / Quickshell).
- **PJeOffice Pro** instalado no sistema.
- **OpenSC** (`opensc`) para leitura de tokens criptográficos via linha de comando (`opensc-tool`).

---

## Instalação

### Via Omarchy CLI (Recomendado)
```bash
omarchy plugin add https://github.com/andrecards12/omarchy-pjeoffice.git --enable
```

### Hospedagem na Gaveta Tray (Segundo Plano)
Para colocar o PJeOffice operando atrás da setinha `<` do Tray, adicione o identificador do plugin à lista `widgets` do `io.github.tyrichards.tray` em `~/.config/omarchy/shell.json`:

```json
{
  "id": "io.github.tyrichards.tray",
  "showTrayIcons": true,
  "widgets": [
    {
      "entry": {
        "id": "io.github.andrecards12.pjeoffice"
      }
    }
  ]
}
```

---

## Remoção

Para desinstalar e desativar o plugin do seu sistema:
```bash
omarchy plugin remove io.github.andrecards12.pjeoffice --yes
```

---

## Licença

Distribuído sob a licença [MIT](LICENSE).
