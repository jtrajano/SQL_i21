PRINT 'Begin TF Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuTFGetTaxAuthorityBeginEndInventoryDetail','v') IS NOT NULL
	DROP VIEW vyuTFGetTaxAuthorityBeginEndInventoryDetail;
GO

PRINT 'End TF Clean up Objects - Drop obsolete objects'
GO
