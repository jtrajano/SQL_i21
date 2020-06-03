
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataFix WHERE strDescription = 'tblGLDetail_FiscalPeriod')
    BEGIN
        PRINT N'BEGIN INSERTING DEFAULT DATA FOR GL'
        UPDATE T set intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblGLDetail T 
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        WHERE T.ysnIsUnposted = 0

        INSERT INTO tblGLDataFix VALUES( 'tblGLDetail_FiscalPeriod')
        PRINT N'FINISHED INSERTING DEFAULT DATA FOR GL'
    END
GO
