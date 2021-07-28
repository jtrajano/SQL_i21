PRINT 'Begin Contract Management Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTAllowDPContractClosure'))
       DROP PROCEDURE uspCTAllowDPContractClosure;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTProcessInvoiceDelete'))
       DROP PROCEDURE uspCTProcessInvoiceDelete;
GO


IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTErrorMessages'))
       DROP PROCEDURE uspCTErrorMessages;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTImportContractText'))
       DROP PROCEDURE uspCTImportContractText;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspCTAllowDPContractClosure'))
       DROP PROCEDURE uspCTAllowDPContractClosure;
GO



IF OBJECT_ID('vyuCTPriceContract','v') IS NOT NULL
	DROP VIEW vyuCTPriceContract;
GO
IF OBJECT_ID('vyuCTContractDetails','v') IS NOT NULL
	DROP VIEW vyuCTContractDetails;
GO
IF OBJECT_ID('vyuCTContractDetailGrid','v') IS NOT NULL
	DROP VIEW vyuCTContractDetailGrid;
GO
IF OBJECT_ID('vyuCTContractDetailView2','v') IS NOT NULL
	DROP VIEW vyuCTContractDetailView2;
GO
IF OBJECT_ID('vyuCTYetToPriceFix','v') IS NOT NULL
	DROP VIEW vyuCTYetToPriceFix;
GO



PRINT 'End Contract Management Clean up Objects - Drop obsolete objects'
GO
