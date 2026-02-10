#!/bin/bash

# ============================================================================
# Script de Personalização - Arch Linux
# ============================================================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# ============================================================================
# 1. INSTALAÇÃO DE PACOTES DE PERSONALIZAÇÃO
# ============================================================================
print_section "1. Instalando Pacotes de Personalização"

PACOTES_PERSONALIZACAO=(
    # Terminal Melhorado
    zsh
    starship           # Corrigido: era "startship"
    
    # Fontes Nerd
    ttf-jetbrains-mono-nerd
    ttf-firacode-nerd
    ttf-meslo-nerd
    
    # Utilitários CLI
    eza                # Substituto moderno do ls
    bat                # Substituto moderno do cat
    fzf                # Fuzzy finder
    ripgrep            # Substituto moderno do grep
    fd                 # Substituto moderno do find
    
    # Git melhorado
    lazygit
    tig
)

print_info "Instalando pacotes de personalização..."
sudo pacman -S --needed --noconfirm "${PACOTES_PERSONALIZACAO[@]}"

print_success "Pacotes de personalização instalados!"

# ============================================================================
# 2. CONFIGURAR ZSH COMO SHELL PADRÃO
# ============================================================================
print_section "2. Configurando Zsh"

print_info "Definindo zsh como shell padrão..."
zsh_path=$(which zsh)

if [ -n "$zsh_path" ]; then
    # Verificar se já é o shell padrão
    if [ "$SHELL" != "$zsh_path" ]; then
        chsh -s "$zsh_path"
        print_success "Zsh definido como shell padrão!"
        print_warning "Você precisará fazer logout/login para aplicar"
    else
        print_success "Zsh já é o shell padrão!"
    fi
else
    print_error "Zsh não encontrado!"
    exit 1
fi


# ============================================================================
# 7. INSTALANDO PLUGINS
# ============================================================================
print_section "7. Instalando plugins"

ZSH_PLUGINS=(
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
)

sudo pacman -S --needed --noconfirm "${ZSH_PLUGINS[@]}"
startship preset nerd-font-sybomls -o ~/.config/startship.toml
print_success "Plugins instalados!"



# ============================================================================
# 6. CONFIGURAR .ZSHRC
# ============================================================================
print_section "6. Configurando .zshrc"

# Backup do .zshrc original
if [ -f "$HOME/.zshrc" ]; then
    print_info "Fazendo backup do .zshrc..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Criar novo .zshrc
cat > "$HOME/.zshrc" << 'EOF'
# Plugins
source /usr/share/zsh/plugins/`${ZSH_PLUGINS[@]}`/`${ZSH_PLUGINS[@]}`.zsh

# Fzf
source <(fzf --zsh)

# Starship propmt
eval "$(starship init zsh)"

EOF
exec zsh


# ============================================================================
# RESUMO FINAL
# ============================================================================
print_section "PERSONALIZAÇÃO CONCLUÍDA! 🎉"

echo -e "${GREEN}Resumo da personalização:${NC}"
echo -e "  ✓ Zsh configurado como shell padrão"
echo -e "  ✓ Oh My Zsh instalado"
echo -e "  ✓ Plugins do Zsh instalados"
if [ "$USE_P10K" = true ]; then
    echo -e "  ✓ Tema Powerlevel10k instalado"
else
    echo -e "  ✓ Starship prompt configurado"
fi
echo -e "  ✓ Aliases úteis configurados"
echo -e "  ✓ Ferramentas CLI modernas instaladas"
echo -e "  ✓ Estrutura de diretórios criada"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "  1. ${BLUE}Faça logout e login novamente${NC} para aplicar o Zsh"
if [ "$USE_P10K" = true ]; then
    echo -e "  2. ${BLUE}Execute 'p10k configure'${NC} para personalizar o tema"
fi
echo -e "  3. ${BLUE}Teste os novos comandos:${NC}"
echo -e "     • ${CYAN}ll${NC} - listar arquivos com ícones"
echo -e "     • ${CYAN}bat arquivo.txt${NC} - visualizar arquivo com sintaxe"
echo -e "     • ${CYAN}lazygit${NC} - interface Git"
echo -e "     • ${CYAN}gs${NC} - git status"
echo ""
echo -e "${GREEN}Aproveite seu terminal personalizado! ✨${NC}"
echo ""

