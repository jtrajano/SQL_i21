PRINT 'Begin Ticket Management Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSCPostDestinationWeightsAndGradesReversalProcess'))
       DROP PROCEDURE uspSCPostDestinationWeightsAndGradesReversalProcess;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSCReverseTicket'))
       DROP PROCEDURE uspSCReverseTicket;
GO





PRINT 'End Ticket Management Clean up Objects - Drop obsolete objects'
GO
