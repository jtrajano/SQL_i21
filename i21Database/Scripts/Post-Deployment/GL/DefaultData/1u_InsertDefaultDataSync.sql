
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataFix WHERE strDescription = 'tblGLDetail_FiscalPeriod')
    BEGIN
        PRINT N'BEGIN INSERTING DEFAULT DATA FOR GL'
        UPDATE T set strPeriod = F.strPeriod FROM tblGLDetail T 
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        WHERE T.ysnIsUnposted = 0

        INSERT INTO tblGLDataFix VALUES( 'tblGLDetail_FiscalPeriod')
        PRINT N'FINISHED INSERTING DEFAULT DATA FOR GL'
    END

    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataFix WHERE strDescription = 'tblGLTrialBalance_FiscalPeriod')	
    BEGIN
        PRINT N'BEGIN UPDATEING tblGLTrialBalance Fiscal Period'
        UPDATE T SET strPeriod = F.strPeriod 
        FROM tblGLTrialBalance T JOIN
            tblGLFiscalYearPeriod F 
        ON T.intGLFiscalYearPeriodId = F.intGLFiscalYearPeriodId

        INSERT INTO tblGLDataFix VALUES( 'tblGLTrialBalance_FiscalPeriod')
        PRINT N'FINISHED UPDATEING tblGLTrialBalance Fiscal Period'
    END
GO
