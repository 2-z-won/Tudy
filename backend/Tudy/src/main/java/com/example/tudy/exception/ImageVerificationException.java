package com.example.tudy.exception;

public class ImageVerificationException extends RuntimeException {
    private final String errorCode;
    private final float confidence;

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
