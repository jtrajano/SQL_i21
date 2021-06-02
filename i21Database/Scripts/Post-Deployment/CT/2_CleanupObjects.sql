PRINT 'Begin Contract Management Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTAllowDPContractClosure'))
       DROP PROCEDURE uspCTAllowDPContractClosure;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTProcessInvoiceDelete'))
       DROP PROCEDURE uspCTProcessInvoiceDelete;
GO



PRINT 'End Contract Management Clean up Objects - Drop obsolete objects'
GO
