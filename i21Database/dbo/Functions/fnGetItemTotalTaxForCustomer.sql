CREATE FUNCTION [dbo].[fnGetItemTotalTaxForCustomer]
(
	 @ItemId				INT
	,@CustomerId			INT
	,@TransactionDate		DATETIME
	,@ItemPrice				NUMERIC(18,6)
	,@QtyShipped			NUMERIC(18,6)
	,@TaxGroupId			INT
	,@CompanyLocationId		INT
	,@CustomerLocationId	INT	
	,@IncludeExemptedCodes	BIT
	,@IsCustomerSiteTaxable	BIT
	,@SiteId				INT
	,@FreightTermId			INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @LineItemTotal NUMERIC(18,6)
	
	SELECT
		@LineItemTotal = SUM([dblAdjustedTax])
	FROM
		[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @CompanyLocationId, @CustomerLocationId, @IncludeExemptedCodes, @IsCustomerSiteTaxable, @SiteId, @FreightTermId)
		
	RETURN @LineItemTotal		
END