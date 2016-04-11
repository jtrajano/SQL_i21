GO
	PRINT N'BEGIN INSERT DEFAULT TM GLOBAL JULIAN CALENDAR'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMGlobalJulianCalendar]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMGlobalJulianCalendar WHERE strDescription = 'Every 30 Days' AND ysnDefault = 1) INSERT INTO tblTMGlobalJulianCalendar (strDescription,ysnDefault) VALUES ('Every 30 Days', 1)
END

GO
	PRINT N'END INSERT DEFAULT TM GLOBAL JULIAN CALENDAR'
GO