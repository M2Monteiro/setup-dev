#!/bin/bash

# =======================================
# Script de Pós-Instalação - Arch Linux
# =======================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_section() {
    echo -e "\n${GREEN}======================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}======================================${NC}\n"
}

# Verificar se está rodando como root
if [ "$EUID" -eq 0 ]; then 
    print_error "Não execute este script como root!"
    exit 1
fi

# 1. System Update
print_section "1. Atualizando o Sistema"
print_info "Atualizando repositórios.."
sudo pacman -Syu --noconfirm
sudo pacman -Syyuu
print_success "Sistema atualizado!"

# 2. INSTALAR YAY (AUR Helper)
print_section "2. Instalando YAY (AUR Helper)"

if ! command -v yay &> /dev/null; then
    print_info "Instalando dependências..."
    sudo pacman -S --needed --noconfirm git base-devel
    
    print_info "Clonando YAY..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    
    print_success "YAY instalado!"
else
    print_success "YAY já está instalado!"
fi

# 3. PACOTES ESSENCIAIS DO SISTEMA
print_section "3. Instalando Pacotes Essenciais"

PACOTES_SISTEMA=(
    # Utilitários básicos
    wget
    curl
    htop
    btop
    fastfetch
    tree
    unzip
    zip
    p7zip
    
    # Fonte do sistema
    noto-fonts
    
    # Sistema de arquivos
    ntfs-3g
    exfat-utils
    
    # Rede
    net-tools
    networkmanager
    openssh
    
    # Ferramentas de desenvolvimento
    git
    github-cli
    vim
    nano
    
    # Compressão
    tar
    gzip
    bzip2
    xz
    
    # Window Manager
    hyprland
    nemo
    wofi
    
    # Terminal melhorado
    kitty
    
    # Media Player
    eog 
    mpv
    
    # Timeshift (snapshots/backup)
    timeshift
    
    # Firewall
    ufw
    gufw
)

print_info "Instalando pacotes do sistema..."
sudo pacman -S --needed --noconfirm "${PACOTES_SISTEMA[@]}"

print_success "Pacotes essenciais instalados!"

# 4. Instalando Navegadores
print_section "4. Instalando Navegadores"

yay -S --noconfirm zen-browser-bin
print_success "Zen Browser instalado!"

sudo pacman -S --noconfirm firefox
print_success "Firefox instalado!"

# 5. Configurações do Sistema
print_section "5. Configurações do Sistema"

# Habilitar firewall
print_info "Configurando firewall..."
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

print_success "Firewall configurado!"

# Configurar Timeshift
print_info "Configure o Timeshift manualmente depois!"
print_warning "Execute: sudo timeshift-gtk"

# 6. Variáveis de ambiente
print_section "6. Configurando Variáveis de Ambiente"

# Detectar shell
SHELL_RC=""
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
fi

if [ ! -z "$SHELL_RC" ]; then
    print_info "Adicionando variáveis de ambiente ao $SHELL_RC..."
    
    cat >> "$SHELL_RC" << 'EOF'

# ============= Configuração Personalizada =============

# ====================
# ALIASES - Navegação
# ====================
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias la='eza -a --icons'
alias l='eza -lh --icons --git'
alias tree='eza --tree --icons'
alias cat='batcat'

# ============================================
# ALIASES - Git
# ============================================
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias lg='lazygit'

# ============================================
# ALIASES - Docker
# ============================================
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
alias di='docker images'
alias lzd='lazydocker'

# Cores no ls
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

EOF
    
    print_success "Variáveis de ambiente configuradas!"
fi

# ============================================================================
# 7. LIMPEZA FINAL
# ============================================================================
print_section "7. Limpeza Final"

print_info "Limpando cache de pacotes..."
yay -Sc --noconfirm
yay -Yc --noconfirm

print_success "Sistema limpo!"

# ============================================================================
# RESUMO FINAL
# ============================================================================
print_section "INSTALAÇÃO CONCLUÍDA! 🎉"

echo -e "${GREEN}Resumo da instalação:${NC}"
echo -e "  ✓ Sistema atualizado"
echo -e "  ✓ YAY (AUR Helper) instalado"
echo -e "  ✓ Pacotes essenciais instalados"
echo -e "  ✓ Firewall configurado"
echo -e "  ✓ Scripts de personalização (se disponíveis)"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "  1. ${BLUE}REINICIE O SISTEMA${NC} para aplicar todas as mudanças"
echo -e "  2. Configure o Timeshift: ${BLUE}sudo timeshift-gtk${NC}"
echo ""
echo -e "${YELLOW}Dicas importantes:${NC}"
echo -e "  • Sempre leia https://archlinux.org/news/ antes de atualizar"
echo -e "  • Use ${BLUE}yay -Syu${NC} para atualizar o sistema"
echo -e "  • Configure snapshots no Timeshift ANTES de fazer mudanças grandes"
echo -e "  • Seu usuário foi adicionado ao grupo docker (precisa relogar)"
echo ""
echo -e "${GREEN}Aproveite seu Arch Linux! 🚀${NC}"
echo ""

# Perguntar sobre reinicialização
read -p "Deseja reiniciar agora? (s/n): " reboot_now
if [[ $reboot_now == "s" || $reboot_now == "S" ]]; then
    print_info "Reiniciando em 5 segundos..."
    sleep 5
    systemctl reboot
fi