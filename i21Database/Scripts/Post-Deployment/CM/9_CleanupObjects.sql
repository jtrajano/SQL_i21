PRINT 'Begin AR Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuPOSGetLoggedIn','v') IS NOT NULL
	DROP VIEW vyuPOSGetLoggedIn;
GO

IF OBJECT_ID('vyuARSearchPOSEndOfDay','v') IS NOT NULL
	DROP VIEW vyuARSearchPOSEndOfDay;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCMErrorMessages'))
       DROP PROCEDURE uspCMErrorMessages;
GO


PRINT 'End AR Clean up Objects - Drop obsolete objects'
GO
