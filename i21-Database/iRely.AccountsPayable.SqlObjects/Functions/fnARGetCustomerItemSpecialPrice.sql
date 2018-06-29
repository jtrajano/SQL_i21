CREATE FUNCTION [dbo].[fnARGetCustomerItemSpecialPrice]
(
	 @ItemId						INT
	,@CustomerId					INT	
	,@LocationId					INT
	,@ItemUOMId						INT
	,@TransactionDate				DATETIME
	,@Quantity						NUMERIC(18,6)
	,@VendorId						INT
	,@SupplyPointId					INT
	,@LastCost						NUMERIC(18,6)
	,@ShipToLocationId				INT
	,@VendorLocationId				INT
	,@InvoiceType					NVARCHAR(200)
	,@SpecialPricingCurrencyId		INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @ItemPrice NUMERIC(18,6)

	SELECT
		 @ItemPrice	= dblPrice		
	FROM
		[dbo].[fnARGetCustomerPricingDetails](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@ItemUOMId
			,@TransactionDate
			,@Quantity
			,@VendorId
			,@SupplyPointId
			,@LastCost
			,@ShipToLocationId
			,@VendorLocationId
			,@InvoiceType
			,0
			,@SpecialPricingCurrencyId
		);

	RETURN @ItemPrice
END