PRINT 'Begin IC Clean up Objects - Drop obsolete objects'
GO

IF object_id('fnICCalculatePricingLevelUnitPrice ', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fnICCalculatePricingLevelUnitPrice]
END
GO




PRINT 'End IC Clean up Objects - Drop obsolete objects'
GO