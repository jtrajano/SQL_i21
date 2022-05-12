PRINT 'Begin GL Clean up Objects - Drop obsolete objects'
GO

IF OBJECT_ID('vwGLChartOfAccounts','v') IS NOT NULL
	DROP VIEW vwGLChartOfAccounts;
GO

PRINT 'End GL Clean up Objects - Drop obsolete objects'
GO
