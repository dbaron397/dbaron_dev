# tmp/ — pasta de compartilhamento com o Claude

Use esta pasta para me passar arquivos (logs de erro, screenshots, netlists,
esquemáticos, etc.) durante a conversa.

## Fluxo

No seu WSL:

```bash
cd ~/ic/setup

# Copie ou salve o arquivo que quer compartilhar
cp /caminho/do/arquivo.log tmp/

# Commit e push
git add tmp/
git commit -m "share: arquivo.log"
git push
```

Depois me avise no chat: *"coloquei o arquivo X em tmp/"*.

Eu puxo (`git pull`) no meu lado e leio o conteúdo direto.

## Exemplos típicos de uso

| O que compartilhar                                | Nome sugerido                  |
|---------------------------------------------------|--------------------------------|
| Log completo de build que falhou                  | `tmp/ngspice-build.log`        |
| Screenshot de erro (pode colar direto no chat)    | `tmp/erro-magic.png`           |
| Netlist que precisa de debug                      | `tmp/inverter.spice`           |
| Output de `ic-info`                               | `tmp/ic-info.txt`              |
| Trecho de `/etc/wsl.conf` ou `.bashrc`            | `tmp/wsl.conf`                 |

## Limpeza

Os arquivos aqui são tratados como temporários. Depois de resolver o problema,
dá pra limpar:

```bash
git rm tmp/*.log tmp/*.png
git commit -m "cleanup: tmp/"
git push
```

## Notas

- **Não coloque arquivos grandes** (> 5 MB). Git não é CDN — use o chat para
  screenshots e cole trechos relevantes de logs longos.
- **Nada sensível**: este repositório é público (ou pode ser). Não suba
  chaves privadas, `.env`, credenciais, etc.
- Logs normalmente têm extensão `.log` — o `.gitignore` principal **ignora**
  `*.log`, mas aqui em `tmp/` eles são forçados a serem rastreados (ver o
  `tmp/.gitignore` local).
