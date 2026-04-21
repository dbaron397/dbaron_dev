# 1. Configurar WSL2 + Ubuntu 24.04 no Windows 11

## 1.1 Instalar WSL2

Abra o **PowerShell como Administrador** e rode:

```powershell
wsl --install -d Ubuntu-24.04
```

Isto:
- Habilita a feature `Virtual Machine Platform` e `Windows Subsystem for Linux`.
- Baixa o kernel WSL2 mais recente.
- Instala Ubuntu 24.04 LTS como distro padrão.

Reinicie o Windows quando ele pedir. Na primeira abertura do Ubuntu, defina um
nome de usuário e senha Linux (pode ser diferente do usuário do Windows).

Confirme que o WSL está na versão 2:

```powershell
wsl -l -v
```

Deve mostrar `Ubuntu-24.04` com `VERSION 2`. Se estiver em 1, converta:

```powershell
wsl --set-version Ubuntu-24.04 2
wsl --set-default-version 2
```

## 1.2 GUI (WSLg) — já vem pronta no Windows 11

No Windows 11 com WSL2 atualizado, aplicativos gráficos Linux abrem janela
nativa no Windows sem configuração extra. Você pode testar depois da instalação
com:

```bash
xeyes
```

Se der erro "cannot open display", atualize o WSL:

```powershell
wsl --update
wsl --shutdown
```

## 1.3 Ajustes recomendados

### Aumentar limite de memória e CPUs

Crie/edite `C:\Users\<seu-usuario>\.wslconfig` no Windows:

```ini
[wsl2]
memory=12GB
processors=8
swap=8GB
localhostForwarding=true
```

Ajuste `memory` e `processors` para ~75% do que sua máquina tem. OpenROAD e
compilações paralelas se beneficiam. Depois:

```powershell
wsl --shutdown
```

E reabra o Ubuntu.

### Desabilitar o monte automático do Windows no PATH (opcional)

O PATH do Windows herdado pelo WSL é enorme e às vezes quebra algumas
ferramentas (espaços em paths). Edite `/etc/wsl.conf` no Ubuntu:

```bash
sudo tee /etc/wsl.conf > /dev/null <<'EOF'
[interop]
appendWindowsPath = false

[automount]
options = "metadata,umask=22,fmask=11"
EOF
```

Depois `wsl --shutdown` no PowerShell e reabrir.

### Filesystem — TRABALHE DENTRO DE `~` (e NÃO em `/mnt/c/`)

O filesystem Linux nativo (`~`, `/home/...`) é **ordens de grandeza mais
rápido** que `/mnt/c/` (filesystem do Windows montado). Builds que levam 10
minutos em `~` podem levar 2 horas em `/mnt/c/`. Sempre clone repositórios e
rode builds dentro do home Linux.

Para acessar os arquivos pelo Windows Explorer, use: `\\wsl$\Ubuntu-24.04\home\<user>\ic`.

## 1.4 Atualizar o Ubuntu

Dentro do Ubuntu:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git curl wget build-essential
```

## 1.5 Editor (opcional mas recomendado)

### VS Code com extensão Remote - WSL

Instale o **VS Code no Windows**, abra o Ubuntu e rode:

```bash
code .
```

Na primeira vez ele instala o servidor de WSL. Depois você edita arquivos
Linux com a interface do VS Code rodando no Windows.

---

Próximo passo: **[docs/02-installation.md](02-installation.md)** para instalar
as ferramentas e PDKs.
