package com.example.tudy.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
public class ClipServiceStarter {

    @Value("${clip.service.url:http://localhost:5001}")
    private String clipServiceUrl;

    @Value("${clip.service.port:5001}")
    private int clipServicePort;

    @Value("${clip.service.auto-start:true}")
    private boolean autoStart;

    private Process clipProcess;

    @EventListener(ApplicationReadyEvent.class)
    public void startClipService() {
        if (!autoStart) {
            log.info("CLIP 서비스 자동 시작이 비활성화되어 있습니다.");
            return;
        }

        log.info("CLIP 서비스 상태를 확인합니다...");
        
        if (isClipServiceRunning()) {
            log.info("CLIP 서비스가 이미 실행 중입니다: {}", clipServiceUrl);
            return;
        }

        log.info("CLIP 서비스를 시작합니다...");
        startClipServiceProcess();
    }

    private boolean isClipServiceRunning() {
        try {
            URL url = new URL(clipServiceUrl + "/health");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(3000);
            connection.setReadTimeout(3000);
            
            int responseCode = connection.getResponseCode();
            return responseCode == 200;
        } catch (Exception e) {
            return false;
        }
    }

    private void startClipServiceProcess() {
        CompletableFuture.runAsync(() -> {
            try {
                // 현재 작업 디렉토리에서 clip_service.py 찾기
                File currentDir = new File(System.getProperty("user.dir"));
                File clipScript = new File(currentDir, "clip_service.py");
                
                if (!clipScript.exists()) {
                    log.error("clip_service.py 파일을 찾을 수 없습니다: {}", clipScript.getAbsolutePath());
                    return;
                }

                // Python 실행 명령어 구성
                ProcessBuilder processBuilder = new ProcessBuilder(
                    "python3", 
                    clipScript.getAbsolutePath(),
                    "--port", String.valueOf(clipServicePort)
                );
                
                processBuilder.directory(currentDir);
                processBuilder.redirectErrorStream(true);
                
                log.info("CLIP 서비스를 시작합니다: python3 {} --port {}", 
                        clipScript.getAbsolutePath(), clipServicePort);
                
                clipProcess = processBuilder.start();
                
                // 프로세스 출력 로깅
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(clipProcess.getInputStream()))) {
                    
                    String line;
                    while ((line = reader.readLine()) != null) {
                        if (line.contains("CLIP model loaded successfully")) {
                            log.info("✅ CLIP 모델이 성공적으로 로드되었습니다.");
                        } else if (line.contains("Server starting")) {
                            log.info("✅ CLIP 서비스가 포트 {}에서 시작되었습니다.", clipServicePort);
                        } else if (line.contains("ERROR") || line.contains("Exception")) {
                            log.error("❌ CLIP 서비스 오류: {}", line);
                        } else {
                            log.debug("CLIP: {}", line);
                        }
                    }
                }
                
            } catch (IOException e) {
                log.error("CLIP 서비스 시작 실패: {}", e.getMessage());
            }
        });

        // 서비스가 시작될 때까지 잠시 대기
        CompletableFuture.runAsync(() -> {
            for (int i = 0; i < 30; i++) { // 최대 30초 대기
                try {
                    TimeUnit.SECONDS.sleep(1);
                    if (isClipServiceRunning()) {
                        log.info("🎉 CLIP 서비스가 성공적으로 시작되었습니다: {}", clipServiceUrl);
                        return;
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
            log.warn("⚠️ CLIP 서비스 시작을 확인할 수 없습니다. 수동으로 확인해주세요.");
        });
    }

    public void stopClipService() {
        if (clipProcess != null && clipProcess.isAlive()) {
            log.info("CLIP 서비스를 종료합니다...");
            clipProcess.destroyForcibly();
            try {
                clipProcess.waitFor(5, TimeUnit.SECONDS);
                log.info("CLIP 서비스가 종료되었습니다.");
            } catch (InterruptedException e) {
                log.warn("CLIP 서비스 종료 대기 중 인터럽트 발생");
                Thread.currentThread().interrupt();
            }
        }
    }

    // Spring Boot 종료 시 CLIP 서비스도 함께 종료
    @EventListener
    public void handleContextStop(ContextClosedEvent event) {
        stopClipService();
    }
}
