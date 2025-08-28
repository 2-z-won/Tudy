package com.example.tudy.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class S3FileService {

    private final S3Client s3Client;

    @Value("${aws.s3.bucket}")
    private String bucketName;

    @Value("${aws.s3.region}")
    private String region;

    /**
     * 파일을 S3에 업로드하고 공개 URL을 반환합니다.
     * 
     * @param file 업로드할 파일
     * @param directory S3 내 저장할 디렉토리 (예: "profile-images", "proof-images")
     * @return S3 공개 URL
     */
    public String uploadFile(MultipartFile file, String directory) {
        try {
            // 파일명 생성
            String fileName = generateFileName(file.getOriginalFilename());
            String key = directory + "/" + fileName;

            // S3에 파일 업로드
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .contentType(file.getContentType())
                    .build();

            s3Client.putObject(putObjectRequest, 
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
            
            // 공개 URL 반환
            String publicUrl = String.format("https://%s.s3.%s.amazonaws.com/%s", 
                    bucketName, region, key);
            
            log.info("파일 업로드 성공: {}", publicUrl);
            return publicUrl;
            
        } catch (IOException e) {
            log.error("파일 업로드 실패: {}", e.getMessage(), e);
            throw new RuntimeException("파일 업로드에 실패했습니다: " + e.getMessage(), e);
        }
    }

    /**
     * S3에서 파일을 삭제합니다.
     * 
     * @param fileUrl S3 파일 URL
     */
    public void deleteFile(String fileUrl) {
        try {
            // URL에서 key 추출
            String key = extractKeyFromUrl(fileUrl);
            
            DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();
                    
            s3Client.deleteObject(deleteObjectRequest);
            log.info("파일 삭제 성공: {}", key);
        } catch (Exception e) {
            log.error("파일 삭제 실패: {}", e.getMessage(), e);
            throw new RuntimeException("파일 삭제에 실패했습니다: " + e.getMessage(), e);
        }
    }

    /**
     * S3 파일이 존재하는지 확인합니다.
     * 
     * @param fileUrl S3 파일 URL
     * @return 파일 존재 여부
     */
    public boolean fileExists(String fileUrl) {
        try {
            String key = extractKeyFromUrl(fileUrl);
            
            HeadObjectRequest headObjectRequest = HeadObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();
                    
            s3Client.headObject(headObjectRequest);
            return true;
        } catch (NoSuchKeyException e) {
            return false;
        } catch (Exception e) {
            log.error("파일 존재 확인 실패: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * 고유한 파일명을 생성합니다.
     * 
     * @param originalFilename 원본 파일명
     * @return 생성된 파일명
     */
    private String generateFileName(String originalFilename) {
        String fileExtension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"));
        String randomStr = UUID.randomUUID().toString().substring(0, 6);
        
        return timestamp + "_" + randomStr + fileExtension;
    }

    /**
     * S3 URL에서 key를 추출합니다.
     * 
     * @param url S3 URL
     * @return 추출된 key
     */
    private String extractKeyFromUrl(String url) {
        if (url == null || url.isEmpty()) {
            throw new IllegalArgumentException("파일 URL이 비어있습니다.");
        }

        // https://bucket-name.s3.region.amazonaws.com/key 형식에서 key 추출
        String[] parts = url.split(".amazonaws.com/");
        if (parts.length != 2) {
            throw new IllegalArgumentException("유효하지 않은 S3 URL 형식입니다: " + url);
        }
        
        return parts[1];
    }
}
