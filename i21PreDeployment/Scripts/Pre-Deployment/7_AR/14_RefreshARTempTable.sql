PRINT '********************** BEGIN - Refresh AR TEMPORARY TABLES **********************'
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspARInitializeTempTableForPosting')
BEGIN
	EXEC [dbo].[uspARInitializeTempTableForPosting]
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspARInitializeTempTableForAging')
BEGIN
	EXEC [dbo].[uspARInitializeTempTableForAging]
END

PRINT ' ********************** END - Refresh AR TEMPORARY TABLES  **********************'
GO