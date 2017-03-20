CREATE PROCEDURE [dbo].[uspARGetItemPrice]
	 @ItemId					INT
	,@CustomerId				INT	
	,@LocationId				INT				= NULL
	,@ItemUOMId					INT				= NULL
	,@TransactionDate			DATETIME		= NULL
	,@Quantity					NUMERIC(18,6)
	,@Price						NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing					NVARCHAR(250)	= NULL OUTPUT	
	,@ContractHeaderId			INT				= NULL OUTPUT
	,@ContractDetailId			INT				= NULL OUTPUT
	,@ContractNumber			NVARCHAR(50)	= NULL OUTPUT
	,@ContractSeq				INT				= NULL OUTPUT
	,@AvailableQuantity			NUMERIC(18,6)   = NULL OUTPUT
	,@UnlimitedQuantity			BIT             = 0    OUTPUT
	,@Deviation					NUMERIC(18,6)	= NULL OUTPUT
	,@TermDiscount				NUMERIC(18,6)	= NULL OUTPUT
	,@TermDiscountBy			NVARCHAR(50)	= NULL OUTPUT
	,@OriginalQuantity			NUMERIC(18,6)	= NULL
	,@CustomerPricingOnly		BIT				= 0
	,@ItemPricingOnly			BIT				= 0
	,@ExcludeContractPricing	BIT				= 0
	,@VendorId					INT				= NULL
	,@SupplyPointId				INT				= NULL
	,@LastCost					NUMERIC(18,6)	= NULL
	,@ShipToLocationId			INT				= NULL
	,@VendorLocationId			INT				= NULL
	,@PricingLevelId			INT				= NULL
	,@AllowQtyToExceedContract	BIT				= 0
	,@InvoiceType				NVARCHAR(200)	= NULL
	,@TermId					INT				= NULL
	,@CurrencyId				INT				= NULL
	,@SubCurrencyId				INT				= NULL OUTPUT
	,@SubCurrency				NVARCHAR(250)	= NULL OUTPUT
	,@SubCurrencyRate			NUMERIC(18,6)	= NULL OUTPUT
	,@PricingType				NVARCHAR(50)	= NULL OUTPUT
	,@TermIdOut					INT				= NULL OUTPUT
	,@GetAllAvailablePricing	BIT				= 0	
AS	

	SELECT
		 @Price				= dblPrice
		,@Pricing			= strPricing
		,@ContractHeaderId	= intContractHeaderId
		,@ContractDetailId	= intContractDetailId
		,@ContractNumber	= strContractNumber
		,@ContractSeq		= intContractSeq
		,@AvailableQuantity = dblAvailableQty
		,@UnlimitedQuantity = ysnUnlimitedQty
		,@Deviation			= dblDeviation
		,@TermDiscount		= dblTermDiscount  
		,@PricingType		= strPricingType
		,@TermIdOut			= intTermId
		,@TermDiscountBy	= strTermDiscountBy
		,@SubCurrencyId		= intSubCurrencyId
		,@SubCurrency		= strSubCurrency
		,@SubCurrencyRate	= dblSubCurrencyRate
	FROM
		[dbo].[fnARGetItemPricingDetails](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@ItemUOMId
			,@CurrencyId
			,@TransactionDate
			,@Quantity
			,@ContractHeaderId
			,@ContractDetailId
			,@ContractNumber
			,@ContractSeq
			,@AvailableQuantity
			,@UnlimitedQuantity
			,@OriginalQuantity
			,@CustomerPricingOnly
			,@ItemPricingOnly
			,@ExcludeContractPricing
			,@VendorId
			,@SupplyPointId
			,@LastCost
			,@ShipToLocationId
			,@VendorLocationId
			,@PricingLevelId
			,@AllowQtyToExceedContract
			,@InvoiceType
			,@TermId
			,@GetAllAvailablePricing
		)

RETURN 0