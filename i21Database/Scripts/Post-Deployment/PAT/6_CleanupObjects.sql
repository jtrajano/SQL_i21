PRINT 'Begin Patronage Clean up Objects - Drop obsolete objects'
GO

IF OBJECT_ID('vyuPATCalculateFiscalSummary','v') IS NOT NULL
	DROP VIEW vyuPATCalculateFiscalSummary;
GO


PRINT 'End Patronage Clean up Objects - Drop obsolete objects'
GO
