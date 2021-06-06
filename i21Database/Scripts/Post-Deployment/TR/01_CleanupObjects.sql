PRINT 'Begin Transports Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuTRQuoteView','v') IS NOT NULL
	DROP VIEW vyuTRQuoteView;
GO


IF OBJECT_ID('vyuTRRackPriceView','v') IS NOT NULL
	DROP VIEW vyuTRRackPriceView;
GO



PRINT 'End Transports Clean up Objects - Drop obsolete objects'
GO
