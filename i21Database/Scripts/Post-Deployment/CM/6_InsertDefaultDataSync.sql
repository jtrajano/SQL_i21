GO
	PRINT N'BEGIN INSERT DEFAULT DATA SYNC FOR CM'
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblCMDataSync WHERE strSyncName = 'tblCMBankTransaction_FiscalPeriod')
    BEGIN
        UPDATE T set strPeriod = F.strPeriod FROM tblCMBankTransaction T
        JOIN tblGLFiscalYearPeriod F on T.dtmDate between F.dtmStartDate AND F.dtmEndDate
        AND T.ysnPosted = 1

        INSERT INTO tblCMDataSync VALUES( 'tblCMBankTransaction_FiscalPeriod', 1)
        PRINT N'UPDATED tblCMBankTransaction Fiscal Period'
    END
GO
	PRINT N'END INSERT DEFAULT DATA SYNC FOR CM'
GO
