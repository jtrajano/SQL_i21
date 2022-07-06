PRINT 'Begin AR Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuPOSGetLoggedIn','v') IS NOT NULL
	DROP VIEW vyuPOSGetLoggedIn;
GO
IF OBJECT_ID('vyuARSearchPOSEndOfDay','v') IS NOT NULL
	DROP VIEW vyuARSearchPOSEndOfDay;
GO
IF OBJECT_ID('vyuARPOSAvailableDrawer','v') IS NOT NULL
	DROP VIEW vyuARPOSAvailableDrawer;
GO
IF OBJECT_ID('vyuARCustomerStatementDetailReport','v') IS NOT NULL
	DROP VIEW vyuARCustomerStatementDetailReport;
GO
IF OBJECT_ID('vyuARCustomerBalancesForET','v') IS NOT NULL
	DROP VIEW vyuARCustomerBalancesForET;
GO
IF OBJECT_ID('vyuARCustomerStatementReport','v') IS NOT NULL
	DROP VIEW vyuARCustomerStatementReport;
GO


IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspARErrorMessages'))
       DROP PROCEDURE uspARErrorMessages;
GO


PRINT 'End AR Clean up Objects - Drop obsolete objects'
GO
