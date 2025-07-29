package com.example.tudy.group;

import com.example.tudy.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@Entity
@Table(name = "group_join_requests")
public class GroupJoinRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id")
    private Group group;

    private LocalDateTime createdAt;

    @Enumerated(EnumType.STRING)
    private RequestStatus status = RequestStatus.PENDING;

    public GroupJoinRequest(User user, Group group) {
        this.user = user;
        this.group = group;
        this.createdAt = LocalDateTime.now();
    }

    public enum RequestStatus {
        PENDING,    // 대기중
        APPROVED,   // 승인됨
        REJECTED    // 거부됨
    }
} 