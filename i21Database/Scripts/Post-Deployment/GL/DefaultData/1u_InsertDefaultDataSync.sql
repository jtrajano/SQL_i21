GO
	PRINT N'BEGIN INSERT DEFAULT DATA SYNC FOR GL'
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataSync WHERE strSyncName = 'tblGLDetail_FiscalPeriod')
    BEGIN
        UPDATE T set strPeriod = F.strPeriod FROM tblGLDetail T join tblGLFiscalYearPeriod F on T.dtmDate between F.dtmStartDate and F.dtmEndDate
        INSERT INTO tblGLDataSync VALUES( 'tblGLDetail_FiscalPeriod', 1)
        PRINT N'UPDATED tblGLDetail Fiscal Period'
    END

    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataSync WHERE strSyncName = 'tblGLTrialBalance')	
    BEGIN
        EXEC dbo.uspGLRecalcTrialBalance
        INSERT INTO tblGLDataSync VALUES( 'tblGLTrialBalance', 1 )
        INSERT INTO tblGLDataSync VALUES( 'tblGLTrialBalance_FiscalPeriod', 1 )
        PRINT N'UPDATED tblGLTrialBalance'
        PRINT N'UPDATED tblGLTrialBalance Fiscal Period'
    END

    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataSync WHERE strSyncName = 'tblGLTrialBalance_FiscalPeriod')	
    BEGIN
        UPDATE T SET strPeriod = F.strPeriod 
        FROM tblGLTrialBalance T JOIN
            tblGLFiscalYearPeriod F 
        ON T.intGLFiscalYearPeriodId = F.intGLFiscalYearPeriodId

        INSERT INTO tblGLDataSync VALUES( 'tblGLTrialBalance_FiscalPeriod', 1 )
        PRINT N'UPDATED tblGLTrialBalance Fiscal Period'
    END
GO
	PRINT N'END INSERT DEFAULT DATA SYNC FOR GL'
GO
