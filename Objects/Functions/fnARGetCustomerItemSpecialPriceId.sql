CREATE FUNCTION [dbo].[fnARGetCustomerItemSpecialPriceId]
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
RETURNS INT
AS
BEGIN
	DECLARE @SpecialPriceId INT

	SELECT
		 @SpecialPriceId = intSpecialPriceId		
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

	RETURN @SpecialPriceId
END