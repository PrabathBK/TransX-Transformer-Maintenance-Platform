#!/bin/bash
# Quick test of the YOLOv8p2 system

echo "🚀 YOLOv8p2 System Quick Test"
echo "==============================="

# Activate environment
source /home/jaliya/miniconda3/envs/YOLO/bin/activate

# Change to system directory
cd /home/jaliya/model/yolov8p2_system

echo "📦 Available models:"
python tools/inference.py

echo ""
echo "🧪 Testing base model with sample image..."
python tools/inference.py "/home/jaliya/model/T1_faulty_001 (1).jpg"

echo ""
echo "✅ Test completed!"
echo "💡 Usage: python tools/inference.py <your_image.jpg>"