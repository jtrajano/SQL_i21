GO
IF NOT EXISTS( SELECT 1 FROM tblGLDataFixLog WHERE strDescription = 'Reset Retained Earnings Posting')
BEGIN
    IF COL_LENGTH('dbo.tblGLFiscalYear', 'guidPostId') IS NOT NULL
    BEGIN
        EXEC ('
        DECLARE @tblPeriod TABLE (   
            guidPostId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL 
        )
        INSERT INTO @tblPeriod
        SELECT CAST(guidPostId AS NVARCHAR(40))    
        FROM tblGLFiscalYear
        DECLARE @strGuid NVARCHAR(40)
        WHILE EXISTS (SELECT 1 FROM @tblPeriod)
        BEGIN
            SELECT  @strGuid = guidPostId FROM @tblPeriod
            DELETE FROM tblGLDetail WHERE strBatchId = @strGuid
            DELETE FROM @tblPeriod WHERE guidPostId = @strGuid
        END')
    END

    IF COL_LENGTH('dbo.tblGLFiscalYearPeriod', 'guidPostId') IS NOT NULL
    BEGIN
        EXEC('
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
        END')
    END

    IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCompanyPreferenceOption]') AND type in (N'U')) 
    EXEC ('UPDATE tblGLCompanyPreferenceOption SET ysnREOverride = 0, ysnREOverrideLocation = 0 , ysnREOverrideLOB=0, ysnREOverrideCompany = 0
	INSERT INTO tblGLDataFixLog (dtmDate, strDescription)
	VALUES (GETDATE(),  ''Reset Retained Earnings Posting''')
END
GO