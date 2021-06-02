PRINT 'Begin IC Clean up Objects - Drop obsolete objects'
GO

IF object_id('fnICCalculatePricingLevelUnitPrice ', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fnICCalculatePricingLevelUnitPrice]
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

PRINT 'End IC Clean up Objects - Drop obsolete objects'
GO