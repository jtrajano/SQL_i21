CREATE FUNCTION [dbo].[fnTMComputeNewBurnRate]
(
	@intSiteId INT
	,@intInvoiceDetailId INT
	,@intDDReadingId INT 
	,@intPreviousDDReadingId INT 
	,@ysnMultipleInvoice BIT = 0
	,@intDeliveryHistoryId INT = NULL
)
RETURNS NUMERIC(18,6) AS
BEGIN
	DECLARE @dblReturnValue NUMERIC(18,6)

	SELECT TOP 1 @dblReturnValue = dblBurnRate FROM dbo.fnTMComputeNewBurnRateTable(@intSiteId,@intInvoiceDetailId,@intDDReadingId,@intPreviousDDReadingId,@ysnMultipleInvoice,@intDeliveryHistoryId)
	
	RETURN ISNULL(@dblReturnValue,0.0)
END

GO