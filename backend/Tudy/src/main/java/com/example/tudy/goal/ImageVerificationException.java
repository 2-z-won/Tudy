package com.example.tudy.goal;

/**
 * 이미지 인증 관련 예외
 */
public class ImageVerificationException extends RuntimeException {
    
    private final String errorCode;
    private final float confidence;
    
    public ImageVerificationException(String message) {
        super(message);
        this.errorCode = "VERIFICATION_FAILED";
        this.confidence = 0.0f;
    }
    
    public ImageVerificationException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
        this.confidence = 0.0f;
    }
    
    public ImageVerificationException(String message, String errorCode, float confidence) {
        super(message);
        this.errorCode = errorCode;
        this.confidence = confidence;
    }
    
    public String getErrorCode() {
        return errorCode;
    }
    
    public float getConfidence() {
        return confidence;
    }
}
