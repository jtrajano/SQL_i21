PRINT 'Begin Manufacturing Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspMFCompleteBlendsheet')) --small sheet not Sheet is what's being dropped here
       DROP PROCEDURE uspMFCompleteBlendsheet;
GO

PRINT 'End Manufacturing Clean up Objects - Drop obsolete objects'
GO