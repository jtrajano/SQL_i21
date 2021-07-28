PRINT 'Begin Manufacturing Clean up Objects - Drop obsolete objects'
GO

IF OBJECT_ID('uspMFGErrorMessages', 'P') IS NOT NULL 
BEGIN
	EXEC('DROP PROCEDURE uspMFGErrorMessages') 
END


PRINT 'End Manufacturing Clean up Objects - Drop obsolete objects'
GO