package com.example.tudy.study;

import com.example.tudy.goal.Goal;
import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StudySessionRepository extends JpaRepository<StudySession, Long> {
    List<StudySession> findByUser(User user);

    @Query("select ss.user.college as college, sum(ss.duration) as total from StudySession ss where ss.duration is not null group by ss.user.college order by total desc")
    List<Object[]> totalDurationByCollege();

    List<StudySession> findByGoal(Goal goal);

    @Query("SELECT COALESCE(SUM(s.duration), 0) FROM StudySession s WHERE s.goal.id = :goalId")
    Integer findTotalDurationByGoalId(@Param("goalId") Long goalId);
}