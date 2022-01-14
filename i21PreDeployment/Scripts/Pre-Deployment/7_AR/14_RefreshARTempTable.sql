PRINT '********************** BEGIN - Refresh AR TEMPORARY TABLES **********************'
GO


EXEC [dbo].[uspARInitializeTempTableForPosting]
EXEC [dbo].[uspARInitializeTempTableForAging]


PRINT ' ********************** END - Refresh AR TEMPORARY TABLES  **********************'
GO