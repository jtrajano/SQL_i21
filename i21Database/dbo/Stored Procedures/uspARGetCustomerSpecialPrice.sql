CREATE PROCEDURE [dbo].[uspARGetCustomerSpecialPrice]
	@ItemId						INT
	,@CustomerId				INT	
	,@LocationId				INT				= NULL
	,@ItemUOMId					INT				= NULL
	,@TransactionDate			DATETIME		= NULL
	,@Quantity					NUMERIC(18,6)
	,@Price						NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing					NVARCHAR(250)	= NULL OUTPUT	
	,@Deviation					NUMERIC(18,6)	= NULL OUTPUT
	,@TermDiscount				NUMERIC(18,6)	= NULL OUTPUT
	,@VendorId					INT				= NULL
	,@SupplyPointId				INT				= NULL
	,@LastCost					NUMERIC(18,6)	= NULL
	,@ShipToLocationId			INT				= NULL
	,@VendorLocationId			INT				= NULL
	,@InvoiceType				NVARCHAR(200)	= NULL
	,@TermId					INT				= NULL
	,@CurrencyId				INT				= NULL	
AS		
	
	SELECT
		 @Price		= dblPrice
		,@Pricing	= strPricing
		,@Deviation	= dblDeviation 
	FROM
		[dbo].[fnARGetItemPricingDetails](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@ItemUOMId
			,@CurrencyId
			,@TransactionDate
			,@Quantity
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,0
			,1
			,0
			,NULL
			,@VendorId
			,@SupplyPointId
			,@LastCost
			,@ShipToLocationId
			,@VendorLocationId
			,NULL
			,NULL
			,@InvoiceType
			,@TermId
			,0
		)

RETURN 0
