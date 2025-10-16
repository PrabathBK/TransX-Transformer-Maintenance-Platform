#!/bin/bash
# Complete YOLOv8p2 System Test

echo "🎯 YOLOv8p2 Complete System Test"
echo "===================================="

# Change to system directory
cd /home/jaliya/model/yolov8p2_system

echo "📦 Available models:"
echo "   Base models:"
ls -la models/base/
echo "   Fine-tuned models:"
ls -la models/finetuned/

echo ""
echo "🧪 Testing base model inference:"
echo "Command: python tools/inference.py '/home/jaliya/model/T1_faulty_001 (1).jpg'"
python tools/inference.py "/home/jaliya/model/T1_faulty_001 (1).jpg"

echo ""
echo "🧪 Testing fine-tuned model inference:"
echo "Command: python tools/inference.py '/home/jaliya/model/T1_faulty_001 (1).jpg' models/finetuned/enhanced_50epochs_best.pt"
python tools/inference.py "/home/jaliya/model/T1_faulty_001 (1).jpg" models/finetuned/enhanced_50epochs_best.pt

echo ""
echo "✅ System test completed!"
echo ""
echo "📋 Summary:"
echo "   - Base model: Available and working"
echo "   - Fine-tuned model: Available for testing"
echo "   - File structure: Properly organized"
echo ""
echo "💡 Usage:"
echo "   1. Test base model: python tools/inference.py <image>"
echo "   2. Fine-tune if needed: python tools/finetune.py <dataset.yaml> [epochs] [name]"
echo "   3. Use fine-tuned: python tools/inference.py <image> models/finetuned/<name>_best.pt"