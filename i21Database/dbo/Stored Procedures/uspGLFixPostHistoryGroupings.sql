CREATE PROCEDURE uspGLFixPostHistoryGroupings
    @strTransactionId NVARCHAR(30)
AS

IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail WHERE strTransactionId = @strTransactionId AND dtmDateEnteredMin IS NULL) -- THIS INDICATES THAT THIS UPDATE SCRIPT HAVE NOT BEEN EXECUTED
BEGIN
    WITH GLGroupings as(
    SELECT 
        strBatchId,
        MIN(dtmDateEntered)dtmDateEnteredMin, 
        ROW_NUMBER() OVER (ORDER BY min(dtmDateEntered)) rowId
        FROM tblGLDetail 
        WHERE @strTransactionId = strTransactionId
        GROUP BY strBatchId,dtmDateEntered
    )
    UPDATE A 
    SET ysnPostAction = rowId%2 ,
    dtmDateEnteredMin = B.dtmDateEnteredMin
    FROM tblGLDetail A
    JOIN GLGroupings B on B.strBatchId = A.strBatchId
    WHERE @strTransactionId = A.strTransactionId
END
GO
