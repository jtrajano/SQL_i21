PRINT 'Begin AP Clean up Objects - Drop obsolete objects'
GO

IF OBJECT_ID('vyuETCustomer','v') IS NOT NULL
	DROP VIEW vyuETCustomer;
GO
IF OBJECT_ID('vyuARGetItemPricingLevelDetail','v') IS NOT NULL
	DROP VIEW vyuARGetItemPricingLevelDetail;
GO


PRINT 'End AP Clean up Objects - Drop obsolete objects'
GO
