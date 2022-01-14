PRINT '********************** BEGIN - Refresh AR TEMPORARY TABLES **********************'
GO

EXEC [dbo].[uspARInitializeTempTableForPosting]

PRINT ' ********************** END - Refresh AR TEMPORARY TABLES  **********************'
GO