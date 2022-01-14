PRINT '********************** BEGIN - Refresh AR TEMPORARY TABLES **********************'
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [type] = 'P' AND [name] = 'uspARInitializeTempTableForPosting')
    EXEC [dbo].[uspARInitializeTempTableForPosting]

PRINT ' ********************** END - Refresh AR TEMPORARY TABLES  **********************'
GO