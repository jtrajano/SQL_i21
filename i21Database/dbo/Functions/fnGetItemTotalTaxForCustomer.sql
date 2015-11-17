﻿CREATE FUNCTION [dbo].[fnGetItemTotalTaxForCustomer]
(
	 @ItemId				INT
	,@CustomerId			INT
	,@TransactionDate		DATETIME
	,@ItemPrice				NUMERIC(18,6)
	,@QtyShipped			NUMERIC(18,6)
	,@TaxGroupId			INT
	,@CompanyLocationId		INT
	,@ShipToLocationId		INT	
	,@IncludeExemptedCodes	INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @LineItemTotal NUMERIC(18,6)
	
	SELECT
		@LineItemTotal = SUM([dblAdjustedTax])
	FROM
		[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @CompanyLocationId, @ShipToLocationId, @IncludeExemptedCodes)
		
	RETURN @LineItemTotal		
END