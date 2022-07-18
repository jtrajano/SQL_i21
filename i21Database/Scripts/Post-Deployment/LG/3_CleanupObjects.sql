PRINT 'Begin LG Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuLGAllocationOpenPContracts','v') IS NOT NULL
	DROP VIEW vyuLGAllocationOpenPContracts;
GO
IF OBJECT_ID('vyuLGWeightLoss','v') IS NOT NULL
	DROP VIEW vyuLGWeightLoss;
GO
IF OBJECT_ID('vyuLGAllocationOpenSContracts','v') IS NOT NULL
	DROP VIEW vyuLGAllocationOpenSContracts;
GO
IF OBJECT_ID('vyuLGAllocationOpenSContracts','v') IS NOT NULL
	DROP VIEW vyuLGAllocationOpenSContracts;
GO

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'FK_tblLGLoadDetail_tblTMDispatch_intTMDispatchId' AND type = 'C' AND parent_object_id = OBJECT_ID('tblLGLoadDetail', 'U'))
BEGIN 
	EXEC ('
		ALTER TABLE tblLGLoadDetail
		DROP CONSTRAINT FK_tblLGLoadDetail_tblTMDispatch_intTMDispatchId		
	')
END

PRINT 'End LG Clean up Objects - Drop obsolete objects'
GO
