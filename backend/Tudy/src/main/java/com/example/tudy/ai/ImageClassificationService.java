package com.example.tudy.ai;

import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.tensorflow.lite.Interpreter;
import lombok.extern.slf4j.Slf4j;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class ImageClassificationService {
    
    private Interpreter tflite;
    private Map<Integer, String> labels;
    
    // 모델 입력 크기 (일반적으로 224x224, 실제 모델에 맞게 조정 필요)
    private static final int INPUT_SIZE = 224;
    private static final int PIXEL_SIZE = 3; // RGB
    
    public ImageClassificationService() {
        try {
            loadModel();
            loadLabels();
            log.info("이미지 분류 모델이 성공적으로 로드되었습니다.");
        } catch (Exception e) {
            log.error("이미지 분류 모델 로드 실패: ", e);
            throw new RuntimeException("이미지 분류 모델 초기화 실패", e);
        }
    }
    
    /**
     * TensorFlow Lite 모델 로드
     */
    private void loadModel() throws IOException {
        ClassPathResource modelResource = new ClassPathResource("model_unquant.tflite");
        
        try (InputStream inputStream = modelResource.getInputStream();
             FileChannel fileChannel = ((FileInputStream) inputStream).getChannel()) {
            
            MappedByteBuffer modelBuffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, 0, fileChannel.size());
            tflite = new Interpreter(modelBuffer);
            
        } catch (ClassCastException e) {
            // InputStream이 FileInputStream이 아닌 경우 (JAR 파일 내부)
            byte[] modelBytes = modelResource.getInputStream().readAllBytes();
            ByteBuffer modelBuffer = ByteBuffer.allocateDirect(modelBytes.length);
            modelBuffer.put(modelBytes);
            modelBuffer.rewind();
            tflite = new Interpreter(modelBuffer);
        }
    }
    
    /**
     * 라벨 파일 로드
     */
    private void loadLabels() throws IOException {
        labels = new HashMap<>();
        ClassPathResource labelResource = new ClassPathResource("labels.txt");
        
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(labelResource.getInputStream(), "UTF-8"))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    String[] parts = line.split(" ", 2);
                    if (parts.length == 2) {
                        int index = Integer.parseInt(parts[0]);
                        String label = parts[1];
                        labels.put(index, label);
                    }
                }
            }
        }
        
        log.info("로드된 라벨: {}", labels);
    }
    
    /**
     * 이미지 분류 수행
     * @param imageBytes 이미지 바이트 배열
     * @return 분류 결과 (카페, 운동, 공부)
     */
    public ClassificationResult classifyImage(byte[] imageBytes) {
        try {
            // 이미지 전처리
            ByteBuffer inputBuffer = preprocessImage(imageBytes);
            
            // 모델 실행
            float[][] output = new float[1][labels.size()];
            tflite.run(inputBuffer, output);
            
            // 결과 분석
            return analyzeOutput(output[0]);
            
        } catch (Exception e) {
            log.error("이미지 분류 중 오류 발생: ", e);
            throw new RuntimeException("이미지 분류 실패", e);
        }
    }
    
    /**
     * 이미지 전처리
     */
    private ByteBuffer preprocessImage(byte[] imageBytes) throws IOException {
        BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageBytes));
        
        // 이미지 크기 조정
        BufferedImage resizedImage = resizeImage(image, INPUT_SIZE, INPUT_SIZE);
        
        // 정규화된 픽셀 데이터를 ByteBuffer에 저장
        ByteBuffer inputBuffer = ByteBuffer.allocateDirect(INPUT_SIZE * INPUT_SIZE * PIXEL_SIZE * 4);
        inputBuffer.order(ByteOrder.nativeOrder());
        
        for (int y = 0; y < INPUT_SIZE; y++) {
            for (int x = 0; x < INPUT_SIZE; x++) {
                int pixel = resizedImage.getRGB(x, y);
                
                // RGB 값 추출 및 정규화 (0-255 -> 0.0-1.0)
                float r = ((pixel >> 16) & 0xFF) / 255.0f;
                float g = ((pixel >> 8) & 0xFF) / 255.0f;
                float b = (pixel & 0xFF) / 255.0f;
                
                inputBuffer.putFloat(r);
                inputBuffer.putFloat(g);
                inputBuffer.putFloat(b);
            }
        }
        
        return inputBuffer;
    }
    
    /**
     * 이미지 크기 조정
     */
    private BufferedImage resizeImage(BufferedImage originalImage, int width, int height) {
        BufferedImage resizedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = resizedImage.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2d.drawImage(originalImage, 0, 0, width, height, null);
        g2d.dispose();
        return resizedImage;
    }
    
    /**
     * 모델 출력 분석
     */
    private ClassificationResult analyzeOutput(float[] output) {
        int maxIndex = 0;
        float maxConfidence = output[0];
        
        for (int i = 1; i < output.length; i++) {
            if (output[i] > maxConfidence) {
                maxConfidence = output[i];
                maxIndex = i;
            }
        }
        
        String predictedLabel = labels.get(maxIndex);
        
        log.info("분류 결과 - 라벨: {}, 신뢰도: {}", predictedLabel, maxConfidence);
        
        return new ClassificationResult(predictedLabel, maxConfidence, maxIndex);
    }
    
    /**
     * 분류 결과 클래스
     */
    public static class ClassificationResult {
        private final String label;
        private final float confidence;
        private final int index;
        
        public ClassificationResult(String label, float confidence, int index) {
            this.label = label;
            this.confidence = confidence;
            this.index = index;
        }
        
        public String getLabel() { return label; }
        public float getConfidence() { return confidence; }
        public int getIndex() { return index; }
        
        @Override
        public String toString() {
            return String.format("ClassificationResult{label='%s', confidence=%.3f, index=%d}", 
                    label, confidence, index);
        }
    }
}
