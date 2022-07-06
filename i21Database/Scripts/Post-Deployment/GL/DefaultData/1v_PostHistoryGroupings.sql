GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDetail where dtmDateEnteredMin IS NOT NULL)
BEGIN
    PRINT ('Begin updating Post History Groupings');
    WITH GLGroupings as(
    SELECT 
        strTransactionId,
        strBatchId,
        MIN(dtmDateEntered)dtmDateEnteredMin, 
        ROW_NUMBER() OVER (PARTITION BY strTransactionId ORDER BY min(dtmDateEntered)) rowId
        FROM tblGLDetail 
        GROUP BY strBatchId,dtmDateEntered,strTransactionId
    )

    UPDATE A 
    SET ysnPostAction = rowId%2 ,
    dtmDateEnteredMin = B.dtmDateEnteredMin
    FROM tblGLDetail A
    JOIN GLGroupings B on B.strBatchId = A.strBatchId
    PRINT ('Finished updating Post History Groupings')
END
GO

