#!/usr/bin/env python3
"""
CLIP 기반 이미지 분류 서비스
Spring Boot에서 호출할 수 있는 Flask API 서버
"""

from flask import Flask, request, jsonify
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import torch
import io
import numpy as np

app = Flask(__name__)

# CLIP 모델 로드 (한국어 지원)
MODEL_NAME = "Bingsu/clip-vit-large-patch14-ko"
print(f"Loading CLIP model: {MODEL_NAME}")
model = CLIPModel.from_pretrained(MODEL_NAME)
processor = CLIPProcessor.from_pretrained(MODEL_NAME)
print("CLIP model loaded successfully!")

@app.route('/classify', methods=['POST'])
def classify_image():
    """
    기본 카테고리 기반 이미지 분류
    """
    try:
        # 이미지 파일 받기
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        image_file = request.files['image']
        categories = request.form.get('categories', '공부,운동,카페').split(',')
        
        # 이미지 로드
        image = Image.open(io.BytesIO(image_file.read()))
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # CLIP 처리
        inputs = processor(text=categories, images=image, return_tensors="pt", padding=True)
        
        with torch.no_grad():
            outputs = model(**inputs)
        
        # 확률 계산
        logits_per_image = outputs.logits_per_image
        probs = logits_per_image.softmax(dim=1)
        
        # 결과 생성
        scores = {categories[i]: float(probs[0][i]) for i in range(len(categories))}
        best_idx = torch.argmax(probs, dim=1).item()
        best_category = categories[best_idx]
        confidence = float(probs[0][best_idx])
        
        return jsonify({
            'best_category': best_category,
            'confidence': confidence,
            'scores': scores
        })
        
    except Exception as e:
        print(f"Error in classify_image: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/classify-text', methods=['POST'])
def classify_image_with_text():
    """
    텍스트 쿼리 기반 이미지 분류
    """
    try:
        # 이미지 파일 받기
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        image_file = request.files['image']
        text_queries = request.form.get('text_queries', '').split('||')
        
        if not text_queries or text_queries == ['']:
            text_queries = [
                "사람이 책을 읽거나 공부하고 있는 사진",
                "사람이 운동하거나 헬스를 하고 있는 사진", 
                "카페나 커피숍에서 음료를 마시고 있는 사진"
            ]
        
        # 이미지 로드
        image = Image.open(io.BytesIO(image_file.read()))
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # CLIP 처리
        inputs = processor(text=text_queries, images=image, return_tensors="pt", padding=True)
        
        with torch.no_grad():
            outputs = model(**inputs)
        
        # 확률 계산
        logits_per_image = outputs.logits_per_image
        probs = logits_per_image.softmax(dim=1)
        
        # 결과 생성
        scores = {text_queries[i]: float(probs[0][i]) for i in range(len(text_queries))}
        best_idx = torch.argmax(probs, dim=1).item()
        best_query = text_queries[best_idx]
        confidence = float(probs[0][best_idx])
        
        return jsonify({
            'best_query': best_query,
            'confidence': confidence,
            'scores': scores
        })
        
    except Exception as e:
        print(f"Error in classify_image_with_text: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """
    서비스 상태 확인
    """
    return jsonify({'status': 'healthy', 'model': MODEL_NAME})

if __name__ == '__main__':
    print("Starting CLIP Image Classification Service...")
    print("Available endpoints:")
    print("  POST /classify - 카테고리 기반 분류")
    print("  POST /classify-text - 텍스트 쿼리 기반 분류") 
    print("  GET /health - 서비스 상태 확인")
    print("\nServer starting on http://localhost:5000")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
