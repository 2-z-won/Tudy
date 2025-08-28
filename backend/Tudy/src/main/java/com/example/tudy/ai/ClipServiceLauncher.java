package com.example.tudy.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
public class ClipServiceLauncher implements CommandLineRunner {

    @Value("${clip.service.auto-start:true}")
    private boolean autoStart;

    @Value("${clip.service.port:5001}")
    private int clipPort;

    @Value("${clip.service.host:localhost}")
    private String clipHost;

    private Process clipProcess;

    @Override
    public void run(String... args) throws Exception {
        if (!autoStart) {
            log.info("CLIP 서비스 자동 시작이 비활성화되어 있습니다.");
            return;
        }

        log.info("CLIP 서비스 자동 시작을 시도합니다...");
        
        // Python이 설치되어 있는지 확인
        if (!isPythonAvailable()) {
            log.warn("Python이 설치되어 있지 않습니다. CLIP 서비스를 시작할 수 없습니다.");
            return;
        }

        // CLIP 서비스 시작
        startClipService();
    }

    private boolean isPythonAvailable() {
        try {
            Process process = new ProcessBuilder("python3", "--version")
                    .start();
            boolean available = process.waitFor(5, TimeUnit.SECONDS) && process.exitValue() == 0;
            if (available) {
                log.info("Python3가 사용 가능합니다.");
            }
            return available;
        } catch (Exception e) {
            try {
                Process process = new ProcessBuilder("python", "--version")
                        .start();
                boolean available = process.waitFor(5, TimeUnit.SECONDS) && process.exitValue() == 0;
                if (available) {
                    log.info("Python이 사용 가능합니다.");
                }
                return available;
            } catch (Exception ex) {
                log.warn("Python을 찾을 수 없습니다: {}", ex.getMessage());
                return false;
            }
        }
    }

    private void startClipService() {
        try {
            // CLIP 서비스 파일을 임시 디렉토리로 복사
            Path clipServicePath = copyClipServiceToTemp();
            
            // requirements.txt 파일도 복사
            Path requirementsPath = copyRequirementsToTemp();

            // Python 의존성 설치
            installDependencies(requirementsPath);

            // CLIP 서비스 실행
            String pythonCommand = isPythonAvailable() ? "python3" : "python";
            ProcessBuilder pb = new ProcessBuilder(
                    pythonCommand, 
                    clipServicePath.toString(),
                    "--port", String.valueOf(clipPort),
                    "--host", clipHost
            );

            // 환경 변수 설정
            pb.environment().put("PYTHONPATH", clipServicePath.getParent().toString());
            
            // 로그 리다이렉션
            pb.redirectErrorStream(true);

            log.info("CLIP 서비스를 시작합니다: {} {} --port {} --host {}", 
                    pythonCommand, clipServicePath, clipPort, clipHost);

            clipProcess = pb.start();

            // 비동기로 서비스 상태 확인
            CompletableFuture.runAsync(() -> {
                try {
                    // 서비스가 시작될 때까지 대기
                    Thread.sleep(10000); // 10초 대기
                    
                    if (clipProcess.isAlive()) {
                        log.info("CLIP 서비스가 성공적으로 시작되었습니다. 포트: {}", clipPort);
                    } else {
                        log.error("CLIP 서비스 시작에 실패했습니다.");
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });

            // 애플리케이션 종료 시 CLIP 서비스도 종료
            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                if (clipProcess != null && clipProcess.isAlive()) {
                    log.info("CLIP 서비스를 종료합니다...");
                    clipProcess.destroy();
                    try {
                        if (!clipProcess.waitFor(5, TimeUnit.SECONDS)) {
                            clipProcess.destroyForcibly();
                        }
                    } catch (InterruptedException e) {
                        clipProcess.destroyForcibly();
                    }
                }
            }));

        } catch (Exception e) {
            log.error("CLIP 서비스 시작 중 오류가 발생했습니다: {}", e.getMessage(), e);
        }
    }

    private Path copyClipServiceToTemp() throws IOException {
        Path tempDir = Files.createTempDirectory("clip-service");
        Path clipServicePath = tempDir.resolve("clip_service.py");
        
        // ClassPath에서 clip_service.py 파일을 찾아서 복사
        try {
            ClassPathResource resource = new ClassPathResource("clip_service.py");
            if (resource.exists()) {
                Files.copy(resource.getInputStream(), clipServicePath, StandardCopyOption.REPLACE_EXISTING);
            } else {
                // 프로젝트 루트에서 파일 복사
                Path projectRoot = Paths.get("").toAbsolutePath();
                Path sourcePath = projectRoot.resolve("clip_service.py");
                if (Files.exists(sourcePath)) {
                    Files.copy(sourcePath, clipServicePath, StandardCopyOption.REPLACE_EXISTING);
                } else {
                    throw new IOException("clip_service.py 파일을 찾을 수 없습니다.");
                }
            }
        } catch (Exception e) {
            // 프로젝트 루트에서 파일 복사 (fallback)
            Path projectRoot = Paths.get("").toAbsolutePath();
            Path sourcePath = projectRoot.resolve("clip_service.py");
            if (Files.exists(sourcePath)) {
                Files.copy(sourcePath, clipServicePath, StandardCopyOption.REPLACE_EXISTING);
            } else {
                throw new IOException("clip_service.py 파일을 찾을 수 없습니다: " + e.getMessage());
            }
        }
        
        log.info("CLIP 서비스 파일이 복사되었습니다: {}", clipServicePath);
        return clipServicePath;
    }

    private Path copyRequirementsToTemp() throws IOException {
        Path tempDir = Files.createTempDirectory("clip-service");
        Path requirementsPath = tempDir.resolve("requirements.txt");
        
        // requirements 파일을 찾아서 복사
        try {
            ClassPathResource resource = new ClassPathResource("requirements");
            if (resource.exists()) {
                Files.copy(resource.getInputStream(), requirementsPath, StandardCopyOption.REPLACE_EXISTING);
            } else {
                // 프로젝트 루트에서 파일 복사
                Path projectRoot = Paths.get("").toAbsolutePath();
                Path sourcePath = projectRoot.resolve("requirements");
                if (Files.exists(sourcePath)) {
                    Files.copy(sourcePath, requirementsPath, StandardCopyOption.REPLACE_EXISTING);
                } else {
                    // 기본 requirements.txt 생성
                    String defaultRequirements = "flask==2.3.3\ntransformers==4.35.2\ntorch==2.1.0\ntorchvision==0.16.0\nPillow==10.0.1\nnumpy==1.24.3";
                    Files.write(requirementsPath, defaultRequirements.getBytes());
                }
            }
        } catch (Exception e) {
            // 기본 requirements.txt 생성 (fallback)
            String defaultRequirements = "flask==2.3.3\ntransformers==4.35.2\ntorch==2.1.0\ntorchvision==0.16.0\nPillow==10.0.1\nnumpy==1.24.3";
            Files.write(requirementsPath, defaultRequirements.getBytes());
        }
        
        log.info("Requirements 파일이 복사되었습니다: {}", requirementsPath);
        return requirementsPath;
    }

    private void installDependencies(Path requirementsPath) {
        try {
            String pythonCommand = isPythonAvailable() ? "python3" : "python";
            ProcessBuilder pb = new ProcessBuilder(
                    pythonCommand, "-m", "pip", "install", "-r", requirementsPath.toString()
            );
            
            pb.redirectErrorStream(true);
            Process process = pb.start();
            
            log.info("Python 의존성을 설치합니다...");
            
            // 설치 완료 대기 (최대 5분)
            if (process.waitFor(5, TimeUnit.MINUTES)) {
                if (process.exitValue() == 0) {
                    log.info("Python 의존성 설치가 완료되었습니다.");
                } else {
                    log.warn("Python 의존성 설치 중 일부 오류가 발생했습니다.");
                }
            } else {
                log.warn("Python 의존성 설치 시간이 초과되었습니다.");
                process.destroyForcibly();
            }
            
        } catch (Exception e) {
            log.warn("Python 의존성 설치 중 오류가 발생했습니다: {}", e.getMessage());
        }
    }
}
