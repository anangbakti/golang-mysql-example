-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

-- Dumping structure for table school.exams
DROP TABLE IF EXISTS `exams`;
CREATE TABLE IF NOT EXISTS `exams` (
  `exam_id` int NOT NULL AUTO_INCREMENT,
  `course_id` int DEFAULT NULL,
  `student_id` int DEFAULT NULL,
  `exam_type` varchar(20) NOT NULL,
  `score` int DEFAULT NULL,
  PRIMARY KEY (`exam_id`),
  KEY `student_id` (`student_id`),
  KEY `idx_exams_course_student` (`course_id`,`student_id`),
  CONSTRAINT `exams_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  CONSTRAINT `exams_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table school.finalscores
DROP TABLE IF EXISTS `finalscores`;
CREATE TABLE IF NOT EXISTS `finalscores` (
  `course_id` int NOT NULL,
  `student_id` int NOT NULL,
  `final_score` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`course_id`,`student_id`),
  CONSTRAINT `fk_finalscores_exams` FOREIGN KEY (`course_id`, `student_id`) REFERENCES `exams` (`course_id`, `student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping structure for procedure school.CalculateAndUpsertFinalScore
DROP PROCEDURE IF EXISTS `CalculateAndUpsertFinalScore`;
DELIMITER //
CREATE PROCEDURE `CalculateAndUpsertFinalScore`(
	IN `new_course_id` INT,
	IN `new_student_id` INT,
	IN `new_exam_type` VARCHAR(20),
	INOUT `new_score` INT
)
BEGIN
    -- Declare a variable to store the final_score
    DECLARE final_score_val DECIMAL(10, 2);

    -- Calculate the final_score using a derived table for 'Mid'
    IF new_exam_type = 'Mid' THEN
        SELECT (new_score + COALESCE((SELECT score FROM Exams WHERE course_id = new_course_id AND student_id = new_student_id AND exam_type = 'End'), 0)) / 2 INTO final_score_val;
    -- Calculate the final_score using a derived table for 'End'
    ELSEIF new_exam_type = 'End' THEN
        SELECT (new_score + COALESCE((SELECT score FROM Exams WHERE course_id = new_course_id AND student_id = new_student_id AND exam_type = 'Mid'), 0)) / 2 INTO final_score_val;
    END IF;
    
    -- Perform upsert into the Finalscores table
    INSERT INTO Finalscores (course_id, student_id, final_score)
    VALUES (new_course_id, new_student_id, final_score_val)
    ON DUPLICATE KEY UPDATE final_score = final_score_val;
END//
DELIMITER ;

-- Dumping structure for trigger school.insert_final_score_trigger
DROP TRIGGER IF EXISTS `insert_final_score_trigger`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `insert_final_score_trigger` BEFORE INSERT ON `exams` FOR EACH ROW BEGIN
 -- Call the stored procedure to calculate and upsert final scores
    CALL CalculateAndUpsertFinalScore(NEW.course_id, NEW.student_id, NEW.exam_type, NEW.score);

END//
DELIMITER ;

-- Dumping structure for trigger school.update_final_score_trigger
DROP TRIGGER IF EXISTS `update_final_score_trigger`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `update_final_score_trigger` BEFORE UPDATE ON `exams` FOR EACH ROW BEGIN
     -- Call the stored procedure to calculate and upsert final scores
    CALL CalculateAndUpsertFinalScore(NEW.course_id, NEW.student_id, NEW.exam_type, NEW.score);

END//
DELIMITER ;