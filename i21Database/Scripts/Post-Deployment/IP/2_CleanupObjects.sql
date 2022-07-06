PRINT 'Begin IP Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspIPGenerateContractFeedDetail'))
       DROP PROCEDURE uspIPGenerateContractFeedDetail;
GO




PRINT 'End IP Clean up Objects - Drop obsolete objects'
GO
