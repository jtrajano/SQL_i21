GO
	PRINT N'BEGIN INSERT DEFAULT DATA SYNC FOR CM'
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblCMDataFixLog WHERE strDescription = 'tblCMBankTransaction_FiscalPeriod')
    BEGIN

        UPDATE 	A 
        SET		
        intFiscalPeriodId = F.intGLFiscalPeriodId
        FROM tblCMBankTransaction A
        CROSS APPLY dbo.fnGLGetFiscalPeriod(A.dtmDate) F
        WHERE	A.ysnPosted = 1

        INSERT INTO tblCMDataFixLog VALUES(GETDATE(), 'tblCMBankTransaction_FiscalPeriod', @@ROWCOUNT)
        PRINT N'UPDATED tblCMBankTransaction Fiscal Period'
    END
GO
	PRINT N'END INSERT DEFAULT DATA SYNC FOR CM'
GO