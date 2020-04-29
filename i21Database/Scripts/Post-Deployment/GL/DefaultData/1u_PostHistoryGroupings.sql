GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDetail WHERE strDescription ='Post History Groupings') -- THIS INDICATES THAT THIS UPDATE SCRIPT HAVE NOT BEEN EXECUTED
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

    INSERT INTO tblGLDataFix VALUES('Post History Groupings')

    PRINT ('Finished updating Post History Groupings')
END
GO

