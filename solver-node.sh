#!/bin/bash

set -e  # Exit immediately if a command exits with non-zero status

# -------------------------------
# CONFIG
# -------------------------------
REPO_URL="https://github.com/ashu1211/solver-node.git"
INSTALL_DIR="/data"
PROJECT_DIR="$INSTALL_DIR/solver-node"
LIBSSL_PACKAGE="libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb"

# -------------------------------
# CHECK ROOT
# -------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "❌ Please run this script as root (use sudo)"
   exit 1
fi

echo "🚀 Starting Solver Node Setup..."

# -------------------------------
# CREATE DATA DIRECTORY
# -------------------------------
echo "📁 Creating $INSTALL_DIR directory..."
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# -------------------------------
# CLONE REPOSITORY
# -------------------------------
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  Project directory already exists. Pulling latest changes..."
    cd $PROJECT_DIR
    git pull
else
    echo "📦 Cloning repository..."
    git clone $REPO_URL
    cd $PROJECT_DIR
fi

# -------------------------------
# CREATE .env FILE
# -------------------------------
if [ -f "env.example" ]; then
    echo "🔧 Creating .env file..."
    cp env.example .env
else
    echo "⚠️ env.example not found. Skipping .env creation."
fi

# -------------------------------
# INSTALL LIBSSL
# -------------------------------
if [ -f "$INSTALL_DIR/$LIBSSL_PACKAGE" ]; then
    echo "📦 Installing libssl1.1..."
    dpkg -i $INSTALL_DIR/$LIBSSL_PACKAGE || apt-get install -f -y
else
    echo "⚠️ $LIBSSL_PACKAGE not found in $INSTALL_DIR"
fi

# -------------------------------
# RUN SETUP SCRIPT
# -------------------------------
if [ -f "setup_mpc_node.sh" ]; then
    echo "⚙️ Running MPC node setup..."
    chmod +x setup_mpc_node.sh
    bash ./setup_mpc_node.sh
else
    echo "❌ setup_mpc_node.sh not found!"
    exit 1
fi

echo "✅ Solver Node setup completed successfully!"
