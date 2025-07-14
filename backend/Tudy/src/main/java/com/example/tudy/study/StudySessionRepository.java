package com.example.tudy.study;

import com.example.tudy.goal.Goal;
import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface StudySessionRepository extends JpaRepository<StudySession, Long> {
    List<StudySession> findByUser(User user);

    @Query("select ss.user.major as major, sum(ss.duration) as total from StudySession ss group by ss.user.major order by total desc")
    List<Object[]> totalDurationByMajor();

    List<StudySession> findByGoal(Goal goal);
}