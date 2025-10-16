#!/usr/bin/env python3

import subprocess
import sys

def test_subprocess_finetune():
    """Test the exact subprocess command that smart_inference uses"""
    
    print("🧪 TESTING SUBPROCESS FINE-TUNING COMMAND")
    print("="*50)
    
    dataset_yaml = "/home/jaliya/model/complete_workflow_manual/dataset/dataset.yaml"
    model_name = "test_subprocess"
    
    # Exact same command as smart_inference.py
    bash_cmd = f"""
    source /home/jaliya/miniconda3/bin/activate YOLO && \
    cd /home/jaliya/model/yolov8p2_system && \
    python tools/finetune.py "{dataset_yaml}" "{model_name}"
    """
    
    print(f"📝 Command to run:")
    print(bash_cmd)
    print()
    
    print(f"🚀 Running subprocess...")
    
    result = subprocess.run(bash_cmd, shell=True, capture_output=True, text=True, executable='/bin/bash')
    
    print(f"📊 Results:")
    print(f"   Return code: {result.returncode}")
    print(f"   STDOUT length: {len(result.stdout) if result.stdout else 0}")
    print(f"   STDERR length: {len(result.stderr) if result.stderr else 0}")
    
    if result.stdout:
        print(f"\n📄 STDOUT:")
        print(result.stdout[:1000] + "..." if len(result.stdout) > 1000 else result.stdout)
    
    if result.stderr:
        print(f"\n❌ STDERR:")
        print(result.stderr[:1000] + "..." if len(result.stderr) > 1000 else result.stderr)
    
    # Check if model was actually created
    import os
    safe_model_name = model_name.replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
    expected_model = f"models/finetuned/{safe_model_name}/weights/best.pt"
    
    print(f"\n🔍 Checking for expected model:")
    print(f"   Path: {expected_model}")
    print(f"   Exists: {os.path.exists(expected_model)}")
    
    return result.returncode == 0

if __name__ == "__main__":
    success = test_subprocess_finetune()
    print(f"\n🎯 Test result: {'SUCCESS' if success else 'FAILED'}")