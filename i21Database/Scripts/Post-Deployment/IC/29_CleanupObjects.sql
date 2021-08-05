PRINT 'Begin IC Clean up Objects - Drop obsolete objects'
GO

IF object_id('fnICCalculatePricingLevelUnitPrice ', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fnICCalculatePricingLevelUnitPrice]
END
GO

IF object_id('fnGetItemCostingOnPostCustodyErrors ', 'IF') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].fnGetItemCostingOnPostCustodyErrors
END
GO

IF object_id('fnGetItemCostingOnUnpostCustodyErrors ', 'IF') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].fnGetItemCostingOnUnpostCustodyErrors
END
GO


IF OBJECT_ID('uspICRepostBillCostAdjustment', 'P') IS NOT NULL AND OBJECT_ID('uspAPRepostBillCostAdjustment', 'P') IS NULL
BEGIN
	-- Rename uspICRepostBillCostAdjustment to uspAPRepostBillCostAdjustment so that ownership and maintenance of this sp will be now in AP. 
	EXEC sp_rename 'dbo.uspICRepostBillCostAdjustment', 'uspAPRepostBillCostAdjustment'; 
END
GO


IF OBJECT_ID('uspICRepostBillCostAdjustment', 'P') IS NOT NULL 
BEGIN
	EXEC('DROP PROCEDURE uspICRepostBillCostAdjustment') 
END
GO

IF OBJECT_ID('uspICErrorMessages', 'P') IS NOT NULL 
BEGIN
	EXEC('DROP PROCEDURE uspICErrorMessages') 
END
GO

IF OBJECT_ID('vyuICBEExportProductPrice','v') IS NOT NULL
	DROP VIEW vyuICBEExportProductPrice;
GO
IF OBJECT_ID('vyuICShipmentInvoice2ByLocation','v') IS NOT NULL
	DROP VIEW vyuICShipmentInvoice2ByLocation;
GO


PRINT 'End IC Clean up Objects - Drop obsolete objects'
GO