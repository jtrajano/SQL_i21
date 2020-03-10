GO
	PRINT N'BEGIN INSERT DEFAULT DATA SYNC FOR GL'
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataSync WHERE strSyncName = 'tblGLDetail_FiscalPeriod')
	insert into tblGLDataSync VALUES( 'tblGLDetail_FiscalPeriod', 0)
IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataSync WHERE strSyncName = 'tblGLDetail_FiscalPeriod')	
	insert into tblGLDataSync VALUES( 'tblGLTrialBalance_FiscalPeriod', 0)
GO
	PRINT N'END INSERT DEFAULT DATA SYNC FOR GL'
GO
