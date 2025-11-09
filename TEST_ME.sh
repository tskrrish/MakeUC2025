#!/bin/bash
# Test script for EmpathLens
# Run this in a SEPARATE terminal while the service is running
# Usage: bash TEST_ME.sh

echo "🧪 Testing EmpathLens..."
echo ""

cd /Users/krrishts/Documents/MakeUC2025

# Run tests using Anaconda Python
/opt/anaconda3/bin/python test_service.py

