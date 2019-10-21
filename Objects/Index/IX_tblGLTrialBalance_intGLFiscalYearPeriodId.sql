CREATE NONCLUSTERED INDEX IX_tblGLTrialBalance_intGLFiscalYearPeriodId
ON [dbo].[tblGLTrialBalance] ([intGLFiscalYearPeriodId])
INCLUDE ([intAccountId],[MTDBalance],[YTDBalance])
GO