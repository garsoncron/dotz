#!/bin/bash

# Define the base directories
CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor"
DOTFILES_DIR="$HOME/.dotfiles/cursor"

# Define shell config paths
SHELL_CONFIG_FILE="$DOTFILES_DIR/shell/cursor.sh"
ZSH_RC="$HOME/.zshrc"
BASH_RC="$HOME/.bashrc"

# Create necessary directories
mkdir -p "$DOTFILES_DIR"

# Function to backup existing cursor config
backup_cursor_config() {
    if [ -d "$CURSOR_CONFIG_DIR" ]; then
        echo "Creating backup of existing Cursor configuration..."
        cp -r "$CURSOR_CONFIG_DIR" "${CURSOR_CONFIG_DIR}.backup"
    fi
}

# Function to setup shell configuration
setup_shell_config() {
    echo "Setting up shell configuration..."
    
    # Create shell config directory
    mkdir -p "$DOTFILES_DIR/shell"
    
    # Create cursor.sh if it doesn't exist
    if [ ! -f "$SHELL_CONFIG_FILE" ]; then
        cat > "$SHELL_CONFIG_FILE" << 'EOL'
# Cursor Editor Configuration
export EDITOR="cursor"

# Alias for VSCode compatibility
alias code="cursor"

# Add Cursor to PATH if it exists
if [ -d "/Applications/Cursor.app/Contents/MacOS" ]; then
    export PATH="/Applications/Cursor.app/Contents/MacOS:$PATH"
fi
EOL
    fi
    
    # Function to add source line to shell config
    add_to_shell_config() {
        local config_file="$1"
        local source_line="source $SHELL_CONFIG_FILE"
        
        if [ -f "$config_file" ]; then
            if ! grep -q "source.*cursor.sh" "$config_file"; then
                echo "" >> "$config_file"
                echo "# Cursor configuration" >> "$config_file"
                echo "$source_line" >> "$config_file"
                echo "Added Cursor configuration to $config_file"
            fi
        fi
    }
    
    # Add to both .zshrc and .bashrc
    add_to_shell_config "$ZSH_RC"
    add_to_shell_config "$BASH_RC"
}

# Function to create symbolic links
create_symlinks() {
    echo "Creating symbolic links..."
    
    # Create symbolic link for User directory
    if [ -d "$CURSOR_CONFIG_DIR/User" ]; then
        mv "$CURSOR_CONFIG_DIR/User" "$DOTFILES_DIR/"
        ln -s "$DOTFILES_DIR/User" "$CURSOR_CONFIG_DIR/User"
    fi
    
    # Create symbolic link for extensions directory
    if [ -d "$CURSOR_CONFIG_DIR/extensions" ]; then
        mv "$CURSOR_CONFIG_DIR/extensions" "$DOTFILES_DIR/"
        ln -s "$DOTFILES_DIR/extensions" "$CURSOR_CONFIG_DIR/extensions"
    fi
}

# Function to initialize dotfiles repository
init_repo() {
    cd "$DOTFILES_DIR" || exit
    if [ ! -d .git ]; then
        git init
        echo "# Cursor Configuration" > README.md
        echo ".DS_Store" > .gitignore
        echo "*.backup" >> .gitignore
        git add .
        git commit -m "Initial cursor configuration"
    fi
}

# Main setup function
setup() {
    echo "Setting up Cursor dotfiles..."
    
    # Check if Cursor is installed
    if [ ! -d "$CURSOR_CONFIG_DIR" ]; then
        echo "Error: Cursor configuration directory not found."
        echo "Please install and run Cursor at least once before running this script."
        exit 1
    fi
    
    backup_cursor_config
    create_symlinks
    setup_shell_config
    init_repo
    
    echo "Setup complete! Your Cursor configuration is now managed by dotfiles."
    echo "To use on another machine:"
    echo "1. Clone your dotfiles repository"
    echo "2. Run this script on the new machine"
}

# Function to restore from dotfiles
restore() {
    echo "Restoring Cursor configuration from dotfiles..."
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "Error: Dotfiles directory not found."
        echo "Please clone your dotfiles repository first."
        exit 1
    fi
    
    backup_cursor_config
    create_symlinks
    setup_shell_config  # Added this line to ensure shell config is restored
    
    echo "Restore complete!"
    echo "Please run 'source ~/.zshrc' (or ~/.bashrc) to load the shell configuration"
}

# Parse command line arguments
case "$1" in
    "setup")
        setup
        ;;
    "restore")
        restore
        ;;
    *)
        echo "Usage: $0 {setup|restore}"
        echo "  setup   - Set up dotfiles for the first time"
        echo "  restore - Restore configuration from existing dotfiles"
        exit 1
        ;;
esac
