CREATE PROCEDURE [dbo].[uspARGetItemPrice]
	 @ItemId					INT
	,@CustomerId				INT	
	,@LocationId				INT				= NULL
	,@ItemUOMId					INT				= NULL
	,@TransactionDate			DATETIME		= NULL
	,@Quantity					NUMERIC(18,6)
	,@Price						NUMERIC(18,6)	= NULL OUTPUT
	,@UnitPrice					NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing					NVARCHAR(250)	= NULL OUTPUT	
	,@ContractHeaderId			INT				= NULL OUTPUT
	,@ContractDetailId			INT				= NULL OUTPUT
	,@ContractNumber			NVARCHAR(50)	= NULL OUTPUT
	,@ContractSeq				INT				= NULL OUTPUT
	,@PriceUOMQuantity			NUMERIC(18,6)   = NULL OUTPUT
	,@ContractUOMId				INT			    = NULL OUTPUT
	,@ContractUOM				NVARCHAR(50)	= NULL OUTPUT
	,@PriceUOMId				INT			    = NULL OUTPUT
	,@PriceUOM					NVARCHAR(50)	= NULL OUTPUT
	,@AvailableQuantity			NUMERIC(18,6)   = NULL OUTPUT
	,@UnlimitedQuantity			BIT             = 0    OUTPUT
	,@Deviation					NUMERIC(18,6)	= NULL OUTPUT
	,@TermDiscount				NUMERIC(18,6)	= NULL OUTPUT
	,@TermDiscountBy			NVARCHAR(50)	= NULL OUTPUT
	,@TermDiscountRate			NUMERIC(18,6)	= NULL OUTPUT
	,@TermDiscountExempt		BIT             = 0    OUTPUT	
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
	,@CurrencyExchangeRateTypeId    INT            = NULL OUTPUT
    ,@CurrencyExchangeRateType  NVARCHAR(20)    = NULL OUTPUT
    ,@CurrencyExchangeRate      NUMERIC(18,6)    = NULL OUTPUT
	,@SubCurrencyId				INT				= NULL OUTPUT
	,@SubCurrency				NVARCHAR(250)	= NULL OUTPUT
	,@SubCurrencyRate			NUMERIC(18,6)	= NULL OUTPUT
	,@PricingType				NVARCHAR(50)	= NULL OUTPUT
	,@TermIdOut					INT				= NULL OUTPUT
	,@GetAllAvailablePricing	BIT				= 0	
	,@SpecialPriceId			INT				= NULL OUTPUT
	,@ProgramId					INT				= NULL OUTPUT
	,@ProgramType				NVARCHAR(100)	= NULL OUTPUT
	
AS	

	SELECT
		 @Price							= dblPrice
		,@UnitPrice						= dblUnitPrice
		,@Pricing						= strPricing
		,@ContractHeaderId				= intContractHeaderId
		,@ContractDetailId				= intContractDetailId
		,@ContractNumber				= strContractNumber
		,@ContractSeq					= intContractSeq
		,@ContractUOMId					= intContractUOMId
		,@ContractUOM					= strContractUOM
		,@PriceUOMId					= intPriceUOMId
		,@PriceUOM						= strPriceUOM
		,@PriceUOMQuantity				= dblPriceUOMQuantity
		,@AvailableQuantity				= dblAvailableQty
		,@UnlimitedQuantity				= ysnUnlimitedQty
		,@Deviation						= dblDeviation
		,@TermDiscount					= dblTermDiscount  
		,@PricingType					= strPricingType
		,@TermIdOut						= intTermId
		,@TermDiscountBy				= strTermDiscountBy
		,@TermDiscountRate				= dblTermDiscountRate
		,@TermDiscountExempt			= ysnTermDiscountExempt
		,@CurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
        ,@CurrencyExchangeRateType      = strCurrencyExchangeRateType
        ,@CurrencyExchangeRate          = dblCurrencyExchangeRate
		,@SubCurrencyId					= intSubCurrencyId
		,@SubCurrency					= strSubCurrency
		,@SubCurrencyRate				= dblSubCurrencyRate
		,@SpecialPriceId				= intSpecialPriceId
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
			,@CurrencyExchangeRate
			,@CurrencyExchangeRateTypeId
		)

		IF @SpecialPriceId is not null or @SpecialPriceId > 0
		BEGIN
			SELECT top 1 @ProgramId=intProgramId  ,@ProgramType=strProgramType  from tblARCustomerSpecialPrice
		END

RETURN 0