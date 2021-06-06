PRINT 'Begin AP Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuAPChargesForBilling','v') IS NOT NULL
	DROP VIEW vyuAPChargesForBilling;
GO

PRINT 'End AP Clean up Objects - Drop obsolete objects'
GO
