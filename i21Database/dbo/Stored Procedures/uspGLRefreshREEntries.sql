CREATE PROCEDURE uspGLRefreshREEntries
AS
BEGIN
    DECLARE @tblPeriod TABLE (   
        guidPostId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL 
    )

    INSERT INTO @tblPeriod
    SELECT CAST(guidPostId AS NVARCHAR(40))    
    FROM tblGLFiscalYearPeriod
    DECLARE @strGuid NVARCHAR(40)
    WHILE EXISTS (SELECT 1 FROM @tblPeriod)
    BEGIN
        SELECT  @strGuid = guidPostId FROM @tblPeriod
        DELETE FROM tblGLDetail WHERE strBatchId = @strGuid
        DELETE FROM @tblPeriod WHERE guidPostId = @strGuid
    END

END