PRINT 'Begin LG Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuLGAllocationOpenPContracts','v') IS NOT NULL
	DROP VIEW vyuLGAllocationOpenPContracts;
GO

PRINT 'End LG Clean up Objects - Drop obsolete objects'
GO
