CREATE FUNCTION [dbo].[fnGetItemTotalTaxForVendor]
(
	 @ItemId			INT
	,@TransactionDate	DATETIME
	,@ItemPrice			NUMERIC(18,6)
	,@QtyShipped		NUMERIC(18,6)
	,@TaxGroupId		INT
	,@CompanyLocationId	INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @LineItemTotal NUMERIC(18,6)
	
	SELECT
		@LineItemTotal = SUM([dblAdjustedTax])
	FROM
		[dbo].[fnGetItemTaxComputationForVendor](@ItemId, NULL, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @CompanyLocationId)
		
	RETURN @LineItemTotal		
END