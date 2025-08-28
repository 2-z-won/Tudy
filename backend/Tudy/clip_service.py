#!/usr/bin/env python3
"""
CLIP 기반 이미지 분류 서비스
Spring Boot에서 호출할 수 있는 Flask API 서버

Dependencies:
- flask
- transformers
- torch
- torchvision
- Pillow
- numpy

Install with:
pip install flask transformers torch torchvision Pillow numpy
"""

from flask import Flask, request, jsonify
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import torch
import io
import numpy as np
import logging
import os

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# CLIP 모델 로드 (한국어 지원)
MODEL_NAME = "Bingsu/clip-vit-large-patch14-ko"
model = None
processor = None

def load_model():
    """CLIP 모델을 로드합니다."""
    global model, processor
    try:
        logger.info(f"Loading CLIP model: {MODEL_NAME}")
        model = CLIPModel.from_pretrained(MODEL_NAME)
        processor = CLIPProcessor.from_pretrained(MODEL_NAME)
        logger.info("CLIP model loaded successfully!")
        return True
    except Exception as e:
        logger.error(f"Failed to load CLIP model: {e}")
        return False

@app.route('/classify', methods=['POST'])
def classify_image():
    """
    기본 카테고리 기반 이미지 분류
    
    Request:
    - image: 이미지 파일 (multipart/form-data)
    - categories: 쉼표로 구분된 카테고리 목록 (선택사항, 기본값: "공부,운동,카페")
    
    Response:
    {
        "best_category": "가장 적합한 카테고리",
        "confidence": 0.85,
        "scores": {"공부": 0.85, "운동": 0.10, "카페": 0.05}
    }
    """
    try:
        # 모델 로드 확인
        if model is None or processor is None:
            return jsonify({'error': 'Model not loaded'}), 500
        
        # 이미지 파일 받기
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        image_file = request.files['image']
        if image_file.filename == '':
            return jsonify({'error': 'No image file selected'}), 400
        
        # 카테고리 파라미터 받기
        categories = request.form.get('categories', '공부,운동,카페').split(',')
        categories = [cat.strip() for cat in categories if cat.strip()]
        
        if not categories:
            return jsonify({'error': 'No valid categories provided'}), 400
        
        # 이미지 로드 및 전처리
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
            'scores': scores,
            'total_categories': len(categories)
        })
        
    except Exception as e:
        logger.error(f"Error in classify_image: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/classify-text', methods=['POST'])
def classify_image_with_text():
    """
    텍스트 쿼리 기반 이미지 분류
    
    Request:
    - image: 이미지 파일 (multipart/form-data)
    - text_queries: '||'로 구분된 텍스트 쿼리 목록 (선택사항)
    
    Response:
    {
        "best_query": "가장 적합한 텍스트 쿼리",
        "confidence": 0.85,
        "scores": {"query1": 0.85, "query2": 0.15}
    }
    """
    try:
        # 모델 로드 확인
        if model is None or processor is None:
            return jsonify({'error': 'Model not loaded'}), 500
        
        # 이미지 파일 받기
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400
        
        image_file = request.files['image']
        if image_file.filename == '':
            return jsonify({'error': 'No image file selected'}), 400
        
        # 텍스트 쿼리 파라미터 받기
        text_queries_str = request.form.get('text_queries', '')
        if text_queries_str:
            text_queries = [query.strip() for query in text_queries_str.split('||') if query.strip()]
        else:
            # 기본 텍스트 쿼리
            text_queries = [
                "사람이 책을 읽거나 공부하고 있는 사진",
                "사람이 운동하거나 헬스를 하고 있는 사진", 
                "카페나 커피숍에서 음료를 마시고 있는 사진"
            ]
        
        if not text_queries:
            return jsonify({'error': 'No valid text queries provided'}), 400
        
        # 이미지 로드 및 전처리
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
            'scores': scores,
            'total_queries': len(text_queries)
        })
        
    except Exception as e:
        logger.error(f"Error in classify_image_with_text: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """
    서비스 상태 확인
    
    Response:
    {
        "status": "healthy",
        "model": "모델명",
        "model_loaded": true,
        "endpoints": ["사용 가능한 엔드포인트 목록"]
    }
    """
    model_loaded = model is not None and processor is not None
    
    return jsonify({
        'status': 'healthy' if model_loaded else 'model_not_loaded',
        'model': MODEL_NAME,
        'model_loaded': model_loaded,
        'endpoints': ['/classify', '/classify-text', '/health'],
        'version': '1.0.0'
    })

@app.errorhandler(404)
def not_found(error):
    """404 에러 핸들러"""
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """500 에러 핸들러"""
    logger.error(f"Internal server error: {error}")
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='CLIP Image Classification Service')
    parser.add_argument('--port', type=int, default=5001, 
                       help='Port to run the service on (default: 5001)')
    parser.add_argument('--host', type=str, default='0.0.0.0',
                       help='Host to bind the service to (default: 0.0.0.0)')
    parser.add_argument('--debug', action='store_true',
                       help='Enable debug mode')
    args = parser.parse_args()
    
    # 모델 로드
    if not load_model():
        logger.error("Failed to load model. Exiting...")
        exit(1)
    
    logger.info("Starting CLIP Image Classification Service...")
    logger.info("Available endpoints:")
    logger.info("  POST /classify - 카테고리 기반 분류")
    logger.info("  POST /classify-text - 텍스트 쿼리 기반 분류")
    logger.info("  GET /health - 서비스 상태 확인")
    logger.info(f"\nServer starting on http://{args.host}:{args.port}")
    
    app.run(host=args.host, port=args.port, debug=args.debug)