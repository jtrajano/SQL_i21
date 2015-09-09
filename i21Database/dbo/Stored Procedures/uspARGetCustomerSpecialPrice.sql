CREATE PROCEDURE [dbo].[uspARGetCustomerSpecialPrice]
	@ItemId				INT
	,@CustomerId		INT	
	,@LocationId		INT				= NULL
	,@ItemUOMId			INT				= NULL
	,@TransactionDate	DATETIME		= NULL
	,@Quantity			NUMERIC(18,6)
	,@Price				NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing			NVARCHAR(250)	= NULL OUTPUT	
	,@VendorId			INT				= NULL
	,@SupplyPointId		INT				= NULL
	,@LastCost			NUMERIC(18,6)	= NULL
	,@ShipToLocationId  INT				= NULL
	,@VendorLocationId  INT				= NULL
AS		
	
	SELECT
		 @Price		= dblPrice
		,@Pricing	= strPricing
	FROM
		[dbo].[fnARGetItemPricingDetails](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@ItemUOMId
			,@TransactionDate
			,@Quantity
			,NULL
			,NULL
			,NULL
			,NULL
			,0
			,1
			,@VendorId
			,@SupplyPointId
			,@LastCost
			,@ShipToLocationId
			,@VendorLocationId
		)

RETURN 0
