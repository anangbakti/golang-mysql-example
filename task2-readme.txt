 In task 2, additional table is added:

1. Exams, which stores data on students taking various courses, 
   with exam types Mid or End, and their respective scores.
2. Finalscores, which stores the final results of Exams. 
   Data filling is done by triggers in the Insert and Update operations of the Exams table, 
   calling the procedure CalculateAndUpsertFinalScore. 
   This procedure simply averages the Mid and End exam scores, 
   and the result is placed in the final_score column.