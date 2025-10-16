#!/bin/bash
# YOLOv8p2 System - Quick Setup Script
# This script sets up the YOLOv8p2 system with all dependencies

set -e  # Exit on any error

echo "🚀 YOLOv8p2 Smart Detection System Setup"
echo "======================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Check Python version
print_info "Checking Python version..."
python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
required_version="3.8"

if python3 -c "import sys; exit(0 if sys.version_info >= (3,8) else 1)" 2>/dev/null; then
    print_success "Python $python_version detected (✓ >= 3.8)"
else
    print_error "Python 3.8+ required. Found: $python_version"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "requirements.txt" ] || [ ! -d "tools" ]; then
    print_error "Please run this script from the yolov8p2_system directory"
    print_info "Expected structure: yolov8p2_system/setup.sh"
    exit 1
fi

# Check for CUDA
print_info "Checking CUDA availability..."
if command -v nvidia-smi &> /dev/null; then
    cuda_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
    print_success "NVIDIA GPU detected (Driver: $cuda_version)"
    use_cuda=true
else
    print_warning "No NVIDIA GPU detected. Will install CPU version."
    use_cuda=false
fi

# Create virtual environment (optional but recommended)
read -p "🤖 Create virtual environment? (y/n): " create_venv
if [[ $create_venv =~ ^[Yy]$ ]]; then
    print_info "Creating virtual environment..."
    python3 -m venv yolov8p2_env
    source yolov8p2_env/bin/activate
    print_success "Virtual environment created and activated"
    print_info "To activate later: source yolov8p2_env/bin/activate"
fi

# Upgrade pip
print_info "Upgrading pip..."
python3 -m pip install --upgrade pip

# Install PyTorch with appropriate CUDA support
if [ "$use_cuda" = true ]; then
    print_info "Installing PyTorch with CUDA support..."
    
    # Detect CUDA version and install appropriate PyTorch
    if command -v nvcc &> /dev/null; then
        cuda_ver=$(nvcc --version | grep "release" | sed -n 's/.*release \([0-9]\+\.[0-9]\+\).*/\1/p')
        print_info "CUDA $cuda_ver detected"
        
        if [[ $cuda_ver =~ ^12\. ]]; then
            pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu121
        else
            pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu118
        fi
    else
        # Default to CUDA 11.8 if nvcc not available
        print_info "Installing with CUDA 11.8 support (default)..."
        pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu118
    fi
else
    print_info "Installing PyTorch (CPU version)..."
    pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cpu
fi

# Install other requirements
print_info "Installing other dependencies..."
pip3 install -r requirements.txt

# Verify installation
print_info "Verifying installation..."
python3 -c "
import torch
from ultralytics import YOLO
import cv2
import numpy as np

print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA devices: {torch.cuda.device_count()}')
    print(f'Current device: {torch.cuda.current_device()}')

print('✅ All core packages imported successfully!')
" || {
    print_error "Installation verification failed!"
    exit 1
}

# Check if base model exists
print_info "Checking base model..."
if [ -f "models/base/yolov8p2_base_trained.pt" ]; then
    model_size=$(du -h models/base/yolov8p2_base_trained.pt | cut -f1)
    print_success "Base model found (Size: $model_size)"
else
    print_warning "Base model not found at models/base/yolov8p2_base_trained.pt"
    print_info "Please ensure the base model is in the correct location"
fi

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p models/finetuned
mkdir -p training_data
print_success "Directories created"

# Test run (optional)
read -p "🧪 Run quick test? (y/n): " run_test
if [[ $run_test =~ ^[Yy]$ ]]; then
    print_info "Running quick system test..."
    
    # Create a simple test
    python3 -c "
from tools.smart_inference import setup_system
import sys

try:
    base_dir, models_dir, base_models_dir, finetuned_models_dir = setup_system()
    print(f'✅ System setup successful')
    print(f'📁 Base directory: {base_dir}')
    print(f'📁 Models directory: {models_dir}')
    sys.exit(0)
except Exception as e:
    print(f'❌ System test failed: {e}')
    sys.exit(1)
" || {
        print_error "System test failed!"
        exit 1
    }
fi

# Success message
echo ""
print_success "🎉 YOLOv8p2 System Setup Complete!"
echo ""
print_info "Next steps:"
echo "  1️⃣  Place your base model at: models/base/yolov8p2_base_trained.pt"
echo "  2️⃣  Test with: python tools/smart_inference.py your_image.jpg"
echo "  3️⃣  Read the README.md for detailed usage instructions"
echo ""

if [ "$create_venv" = true ]; then
    print_info "💡 Remember to activate your environment: source yolov8p2_env/bin/activate"
fi

print_success "Happy detecting! 🔍"