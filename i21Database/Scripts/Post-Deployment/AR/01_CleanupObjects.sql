PRINT 'Begin AR Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuPOSGetLoggedIn','v') IS NOT NULL
	DROP VIEW vyuPOSGetLoggedIn;
GO

IF OBJECT_ID('vyuARSearchPOSEndOfDay','v') IS NOT NULL
	DROP VIEW vyuARSearchPOSEndOfDay;
GO




PRINT 'End AR Clean up Objects - Drop obsolete objects'
GO
