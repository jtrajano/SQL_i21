CREATE FUNCTION [dbo].[fnGetItemTotalTaxForVendor]
(
	 @ItemId			INT
	,@VendorId			INT
	,@TransactionDate	DATETIME
	,@ItemCost			NUMERIC(18,6)
	,@Quantity			NUMERIC(18,6)
	,@TaxGroupId		INT
	,@CompanyLocationId	INT
	,@BillToLocationId	INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @LineItemTotal NUMERIC(18,6)
	
	SELECT
		@LineItemTotal = SUM([dblAdjustedTax])
	FROM
		[dbo].[fnGetItemTaxComputationForVendor](@ItemId, @VendorId, @TransactionDate, @ItemCost, @Quantity, @TaxGroupId, @CompanyLocationId, @BillToLocationId)
		
	RETURN @LineItemTotal		
END