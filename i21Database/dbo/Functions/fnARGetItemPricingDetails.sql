CREATE FUNCTION [dbo].[fnARGetItemPricingDetails]
(
	 @ItemId					INT
	,@CustomerId				INT	
	,@LocationId				INT
	,@ItemUOMId					INT
	,@CurrencyId				INT
	,@TransactionDate			DATETIME
	,@Quantity					NUMERIC(18,6)
	,@ContractHeaderId			INT
	,@ContractDetailId			INT
	,@ContractNumber			NVARCHAR(50)
	,@ContractSeq				INT
	,@AvailableQuantity			NUMERIC(18,6)
	,@UnlimitedQuantity			BIT
	,@OriginalQuantity			NUMERIC(18,6)
	,@CustomerPricingOnly		BIT
	,@ItemPricingOnly			BIT
	,@ExcludeContractPricing	BIT
	,@VendorId					INT
	,@SupplyPointId				INT
	,@LastCost					NUMERIC(18,6)
	,@ShipToLocationId			INT
	,@VendorLocationId			INT
	,@PricingLevelId			INT
	,@AllowQtyToExceed			BIT
	,@InvoiceType				NVARCHAR(200)
	,@TermId					INT
	,@GetAllAvailablePricing	BIT
)
RETURNS @returntable TABLE
(
	 dblPrice						NUMERIC(18,6)
	,dblUnitPrice					NUMERIC(18,6)
	,dblTermDiscount				NUMERIC(18,6)
	,strTermDiscountBy				NVARCHAR(50)
	,dblTermDiscountRate			NUMERIC(18,6)
	,ysnTermDiscountExempt			BIT
	,strPricing						NVARCHAR(250)
	,intCurrencyExchangeRateTypeId  INT
    ,strCurrencyExchangeRateType    NVARCHAR(20)
    ,dblCurrencyExchangeRate        NUMERIC(18,6)
	,intSubCurrencyId				INT
	,dblSubCurrencyRate				NUMERIC(18,6)
	,strSubCurrency					NVARCHAR(40)
	,intContractUOMId				INT
	,strContractUOM					NVARCHAR(50)
	,intPriceUOMId					INT
	,strPriceUOM					NVARCHAR(50)
	,dblDeviation					NUMERIC(18,6)
	,intContractHeaderId			INT
	,intContractDetailId			INT
	,strContractNumber				NVARCHAR(50)
	,intContractSeq					INT
	,dblPriceUOMQuantity			NUMERIC(18,6)
	,dblQuantity					NUMERIC(18,6)
	,dblAvailableQty				NUMERIC(18,6)
	,ysnUnlimitedQty				BIT
	,strPricingType					NVARCHAR(50)
	,intTermId						INT NULL
	,intSort						INT
	,intSpecialPriceId				INT NULL
)
AS
BEGIN

DECLARE @ItemVendorId				INT
		,@ItemLocationId			INT
		,@ItemCategoryId			INT
		,@ItemCategory				NVARCHAR(100)
		,@UOMQuantity				NUMERIC(18,6)
		,@PriceUOMQuantity			NUMERIC(18,6) = 1.000000

DECLARE	 @Price							NUMERIC(18,6)
		,@UnitPrice						NUMERIC(18,6)
		,@Pricing						NVARCHAR(250)
		,@ContractPrice					NUMERIC(18,6)
		,@ContractPricing				NVARCHAR(250)
		,@ContractMaxPrice				NUMERIC(18,6)
		,@Deviation						NUMERIC(18,6)
		,@TermDiscount					NUMERIC(18,6)
		,@TermDiscountRate				NUMERIC(18,6)
		,@TermDiscountExempt			BIT
		,@PricingType					NVARCHAR(50)
		,@TermDiscountBy				NVARCHAR(50)
		,@CurrencyExchangeRateTypeId	INT
        ,@CurrencyExchangeRateType		NVARCHAR(20)
        ,@CurrencyExchangeRate			NUMERIC(18,6) = 1.000000
		,@SubCurrencyRate				NUMERIC(18,6) = 1.000000
		,@SubCurrencyId					INT
		,@SubCurrency					NVARCHAR(40)
		,@ContractUOMId					INT
		,@ContractUOM					NVARCHAR(50)
		,@PriceUOMId					INT
		,@PriceUOM						NVARCHAR(50)
		,@OriginalItemUOMId				INT
		,@termIdOut						INT = NULL
		,@SpecialPriceId				INT = NULL
		,@IsMaxPrice					BIT = 0
		,@ContractPricingLevelId		INT = NULL
		,@Sort							INT = 0
	SET @OriginalItemUOMId = @ItemUOMId

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())
	
	IF @CustomerPricingOnly IS NULL
		SET @CustomerPricingOnly = 0

	IF @ItemPricingOnly IS NULL
		SET @ItemPricingOnly = 0
		
	IF @ExcludeContractPricing IS NULL
		SET @ExcludeContractPricing = 0		
		
	IF @GetAllAvailablePricing IS NULL
		SET @GetAllAvailablePricing = 0
		
	IF @CurrencyId IS NULL
		SET @CurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)		
		
	SELECT
		 @TermDiscountExempt	= ysnTermDiscountExempt
		,@TermDiscountRate		= dblTermDiscountRate
	FROM
		[dbo].[fnARItemTermDiscountExemptDetails](@ItemId, @LocationId, @TermId, @TransactionDate, GETDATE())
		
	IF NOT(@CustomerPricingOnly = 1 OR @ExcludeContractPricing = 1) AND @ItemPricingOnly = 0
	BEGIN		
		--Customer Contract Price		
		SELECT TOP 1
			 @Price							= dblPrice
			,@UnitPrice						= dblUnitPrice
			,@Pricing						= strPricing
			,@ContractPrice					= dblPrice
			,@ContractPricing				= strPricing
			,@Deviation						= dblPrice 
			,@ContractHeaderId				= intContractHeaderId
			,@ContractDetailId				= intContractDetailId
			,@ContractNumber				= strContractNumber
			,@ContractSeq					= intContractSeq
			,@PriceUOMQuantity				= dblPriceUOMQuantity
			,@AvailableQuantity				= dblAvailableQty
			,@UnlimitedQuantity				= ysnUnlimitedQty
			,@PricingType					= strPricingType
			,@CurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
            ,@CurrencyExchangeRateType		= strCurrencyExchangeRateType
            ,@CurrencyExchangeRate			= dblCurrencyExchangeRate
			,@SubCurrencyId					= intSubCurrencyId
			,@SubCurrencyRate				= dblSubCurrencyRate
			,@SubCurrency					= strSubCurrency
			,@ContractUOMId					= intContractUOMId 
			,@ContractUOM					= strContractUOM
			,@PriceUOMId					= intPriceUOMId 
			,@PriceUOM						= strPriceUOM
			,@termIdOut						= intTermId
			,@IsMaxPrice					= ysnMaxPrice
			,@ContractPricingLevelId = intCompanyLocationPricingLevelId
		FROM
			[dbo].[fnARGetContractPricingDetails](
				 @ItemId
				,@CustomerId
				,@LocationId
				,@ItemUOMId
				,@CurrencyId
				,@TransactionDate
				,@Quantity
				,@ContractHeaderId
				,@ContractDetailId
				,@OriginalQuantity
				,@AllowQtyToExceed
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			IF ISNULL(@IsMaxPrice,0) = 1
			BEGIN 

				SELECT TOP 1 
					 @ItemVendorId				= intItemVendorId
					,@ItemLocationId			= intItemLocationId
					,@ItemCategoryId			= intItemCategoryId
					,@ItemCategory				= strItemCategory
					,@UOMQuantity				= dblUOMQuantity
				FROM
					[dbo].[fnARGetLocationItemVendorDetailsForPricing](
						 @ItemId
						,@CustomerId
						,@LocationId
						,@OriginalItemUOMId
						,@VendorId
						,NULL
						,NULL
					);		
	
				--Item Standard Pricing
				IF ISNULL(@UOMQuantity,0) = 0
					SET @UOMQuantity = 1
				SET @Price = @UOMQuantity *	
									( 
										SELECT
											P.dblSalePrice
										FROM
											tblICItemPricing P
										WHERE
											P.intItemId = @ItemId
											AND P.intItemLocationId = @ItemLocationId
										)

				IF @Price <= @ContractPrice
				BEGIN
					SET @Pricing = @ContractPricing + '-Max Price'
					SET @ContractMaxPrice = @Price
					SET @UnitPrice = @Price
					SET @PriceUOMQuantity = 1.000000
				END
				ELSE
				BEGIN
					SET @Price = @ContractPrice
					SET @Pricing = @ContractPricing
				END

			END

			IF ISNULL(@ContractPricingLevelId,0) <> 0 --AND (ISNULL(@IsMaxPrice,0) = 0 OR @Pricing <> @ContractPricing + '-Max Price')
			BEGIN 
				SELECT TOP 1
					 @Price				= dblPrice
					,@Pricing			= strPricing
					,@Deviation			= dblDeviation
					,@TermDiscount		= dblTermDiscount
					,@TermDiscountBy	= strTermDiscountBy 
				FROM
					[dbo].[fnARGetInventoryItemPricingDetails](
						 @ItemId
						,@CustomerId
						,@LocationId
						,@OriginalItemUOMId
						,@TransactionDate
						,@Quantity
						,@VendorId
						,@ContractPricingLevelId
						,@TermId
						,0
						,@CurrencyId
					);

				IF 'Inventory - Pricing Level' = @Pricing AND @Price <= @ContractPrice
				BEGIN
					SET @Pricing = @ContractPricing + '-Pricing Level'
					SET @UnitPrice = @Price
					SET @PriceUOMQuantity = 1.000000
				END
				ELSE IF ISNULL(@IsMaxPrice,0) = 1 AND @ContractMaxPrice <= @ContractPrice
				BEGIN 
					SET @Pricing = @ContractPricing + '-Max Price'
					SET @Price = @ContractMaxPrice
					SET @UnitPrice = @ContractMaxPrice
					SET @PriceUOMQuantity = 1.000000
				END
				ELSE
				BEGIN
					SET @Price = @ContractPrice
					SET @Pricing = @ContractPricing
				END

			END

			SET @Sort = 1
			INSERT @returntable(dblPrice, dblUnitPrice, dblTermDiscount, strTermDiscountBy, dblTermDiscountRate, ysnTermDiscountExempt, strPricing, intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType, dblCurrencyExchangeRate, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intContractUOMId, strContractUOM, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblPriceUOMQuantity, dblQuantity, dblAvailableQty, ysnUnlimitedQty, strPricingType, intTermId, intSort, intSpecialPriceId)
			SELECT @Price, @UnitPrice, @TermDiscount, @TermDiscountBy, @TermDiscountRate, @TermDiscountExempt, @Pricing, @CurrencyExchangeRateTypeId, @CurrencyExchangeRateType, @CurrencyExchangeRate, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ContractUOMId, @ContractUOM, @PriceUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @PriceUOMQuantity, @Quantity, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @TermId, @Sort, @SpecialPriceId			
			IF @GetAllAvailablePricing = 0 RETURN
		END	
		
	END
	
	SELECT
		 @ContractHeaderId				= NULL
		,@ContractDetailId				= NULL
		,@ContractNumber				= NULL
		,@ContractSeq					= NULL
		,@AvailableQuantity				= 0.000000
		,@UnlimitedQuantity				= 0.000000
		,@PricingType					= NULL
		,@CurrencyExchangeRateTypeId	= NULL
		,@CurrencyExchangeRateType		= ''
		,@CurrencyExchangeRate			= 1.000000
		,@PriceUOMQuantity				= 1.000000
		,@ContractUOMId					= @ItemUOMId 
		,@ContractUOM					= ''
		,@PriceUOMId					= @ItemUOMId 
		,@PriceUOM						= ''
		,@SubCurrencyRate				= 1.000000
		,@SubCurrencyId					= NULL

	IF @ItemPricingOnly = 0								
	BEGIN
	--Customer Special Pricing		
		IF @GetAllAvailablePricing = 0 
			BEGIN
				SELECT TOP 1
					 @Price				= dblPrice
					,@UnitPrice			= dblPrice
					,@PriceUOMQuantity	= 1.000000
					,@Pricing			= strPricing
					,@Deviation			= dblDeviation
					,@SpecialPriceId 	= intSpecialPriceId
				FROM
					[dbo].[fnARGetCustomerPricingDetails](
						 @ItemId
						,@CustomerId
						,@LocationId
						,@OriginalItemUOMId
						,@TransactionDate
						,@Quantity
						,@VendorId
						,@SupplyPointId
						,@LastCost
						,@ShipToLocationId
						,@VendorLocationId
						,@InvoiceType
						,0
						,@CurrencyId
					);
			
			
				IF(@Price IS NOT NULL)
				BEGIN
					SET @Sort = @SpecialPriceId
					INSERT @returntable(dblPrice, dblUnitPrice, dblTermDiscount, strTermDiscountBy, dblTermDiscountRate, ysnTermDiscountExempt, strPricing, intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType, dblCurrencyExchangeRate, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intContractUOMId, strContractUOM, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblPriceUOMQuantity, dblQuantity, dblAvailableQty, ysnUnlimitedQty, strPricingType, intTermId, intSort, intSpecialPriceId)
					SELECT @Price, @UnitPrice, @TermDiscount, @TermDiscountBy, @TermDiscountRate, @TermDiscountExempt, @Pricing, @CurrencyExchangeRateTypeId, @CurrencyExchangeRateType, @CurrencyExchangeRate, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ContractUOMId, @ContractUOM, @PriceUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @PriceUOMQuantity, @Quantity, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @TermId, @Sort, @SpecialPriceId			
					RETURN
				END	
			END
		ELSE
			BEGIN
				INSERT @returntable(
					 dblPrice
					,dblUnitPrice
					,dblTermDiscount
					,strTermDiscountBy
					,dblTermDiscountRate
					,ysnTermDiscountExempt
					,strPricing
					,intCurrencyExchangeRateTypeId
					,strCurrencyExchangeRateType
					,dblCurrencyExchangeRate
					,intSubCurrencyId
					,dblSubCurrencyRate
					,strSubCurrency
					,intContractUOMId
					,strContractUOM
					,intPriceUOMId
					,strPriceUOM
					,dblDeviation
					,intContractHeaderId
					,intContractDetailId
					,strContractNumber
					,intContractSeq
					,dblPriceUOMQuantity
					,dblQuantity
					,dblAvailableQty
					,ysnUnlimitedQty
					,strPricingType
					,intTermId
					,intSort
					,intSpecialPriceId)
				SELECT 
					 dblPrice						= dblPrice
					,dblUnitPrice					= dblPrice
					,dblTermDiscount				= 0.000000
					,strTermDiscountBy				= ''
					,dblTermDiscountRate			= @TermDiscountRate
					,ysnTermDiscountExempt			= @TermDiscountExempt
					,strPricing						= strPricing
					,intCurrencyExchangeRateTypeId	= @CurrencyExchangeRateTypeId
					,strCurrencyExchangeRateType	= @CurrencyExchangeRateType
					,dblCurrencyExchangeRate		= @CurrencyExchangeRate
					,intSubCurrencyId				= @SubCurrencyId
					,dblSubCurrencyRate				= @SubCurrencyRate
					,strSubCurrency					= @SubCurrency
					,intContractUOMId				= @ContractUOMId
					,strContractUOM					= @ContractUOM
					,intPriceUOMId					= @PriceUOMId
					,strPriceUOM					= @PriceUOM
					,dblDeviation					= dblDeviation
					,intContractHeaderId			= @ContractHeaderId
					,intContractDetailId			= @ContractDetailId
					,strContractNumber				= @ContractNumber
					,intContractSeq					= @ContractSeq
					,dblPriceUOMQuantity			= @PriceUOMQuantity
					,dblQuantity					= @Quantity
					,dblAvailableQty				= @AvailableQuantity
					,ysnUnlimitedQty				= @UnlimitedQuantity
					,strPricingType					= @PricingType
					,intTermId						= @TermId
					,intSort						= intSort + 10
					,intSpecialPriceId				= intSpecialPriceId
				FROM
					[dbo].[fnARGetCustomerPricingDetails](
						 @ItemId
						,@CustomerId
						,@LocationId
						,@OriginalItemUOMId
						,@TransactionDate
						,@Quantity
						,@VendorId
						,@SupplyPointId
						,@LastCost
						,@ShipToLocationId
						,@VendorLocationId
						,@InvoiceType
						,@GetAllAvailablePricing
						,@CurrencyId
					)
			END				
	END
	
	IF @CustomerPricingOnly = 1
		RETURN;
	
	BEGIN
		--Inventory Special Pricing
		IF @GetAllAvailablePricing = 0 
			BEGIN
				SELECT TOP 1
					 @Price				= dblPrice
					,@UnitPrice			= dblPrice
					,@PriceUOMQuantity	= 1.000000
					,@Pricing			= strPricing
					,@Deviation			= dblDeviation
					,@TermDiscount		= dblTermDiscount
					,@TermDiscountBy	= strTermDiscountBy 
				FROM
					[dbo].[fnARGetInventoryItemPricingDetails](
						 @ItemId
						,@CustomerId
						,@LocationId
						,@OriginalItemUOMId
						,@TransactionDate
						,@Quantity
						,@VendorId
						,@PricingLevelId
						,@TermId
						,0
						,@CurrencyId
					);
			
			
				IF(@Price IS NOT NULL)
				BEGIN
					SET @Sort = @SpecialPriceId
					INSERT @returntable(dblPrice, dblUnitPrice, dblTermDiscount, strTermDiscountBy, dblTermDiscountRate, ysnTermDiscountExempt, strPricing, intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType, dblCurrencyExchangeRate, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intContractUOMId, strContractUOM, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblPriceUOMQuantity, dblQuantity, dblAvailableQty, ysnUnlimitedQty, strPricingType, intTermId, intSort, intSpecialPriceId)
					SELECT @Price, @UnitPrice, @TermDiscount, @TermDiscountBy, @TermDiscountRate, @TermDiscountExempt, @Pricing, @CurrencyExchangeRateTypeId, @CurrencyExchangeRateType, @CurrencyExchangeRate, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ContractUOMId, @ContractUOM, @PriceUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @PriceUOMQuantity, @Quantity, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @TermId, @Sort, @SpecialPriceId			
					RETURN
				END	
			END
		ELSE
			BEGIN
				INSERT @returntable(
					 dblPrice
					,dblUnitPrice
					,dblTermDiscount
					,strTermDiscountBy
					,dblTermDiscountRate
					,ysnTermDiscountExempt
					,strPricing
					,intCurrencyExchangeRateTypeId
					,strCurrencyExchangeRateType
					,dblCurrencyExchangeRate
					,intSubCurrencyId
					,dblSubCurrencyRate
					,strSubCurrency
					,intContractUOMId
					,strContractUOM
					,intPriceUOMId
					,strPriceUOM
					,dblDeviation
					,intContractHeaderId
					,intContractDetailId
					,strContractNumber
					,intContractSeq
					,dblPriceUOMQuantity
					,dblQuantity
					,dblAvailableQty
					,ysnUnlimitedQty
					,strPricingType
					,intTermId
					,intSort
					,intSpecialPriceId)
				SELECT 
					 dblPrice						= dblPrice
					,dblUnitPrice					= dblPrice
					,dblTermDiscount				= dblTermDiscount
					,strTermDiscountBy				= strTermDiscountBy
					,dblTermDiscountRate			= @TermDiscountRate
					,ysnTermDiscountExempt			= @TermDiscountExempt
					,strPricing						= strPricing
					,intCurrencyExchangeRateTypeId	= @CurrencyExchangeRateTypeId
					,strCurrencyExchangeRateType	= @CurrencyExchangeRateType
					,dblCurrencyExchangeRate		= @CurrencyExchangeRate
					,intSubCurrencyId				= @SubCurrencyId
					,dblSubCurrencyRate				= @SubCurrencyRate
					,strSubCurrency					= @SubCurrency
					,intContractUOMId				= @ContractUOMId
					,strContractUOM					= @ContractUOM
					,intPriceUOMId					= @PriceUOMId
					,strPriceUOM					= @PriceUOM
					,dblDeviation					= dblDeviation
					,intContractHeaderId			= @ContractHeaderId
					,intContractDetailId			= @ContractDetailId
					,strContractNumber				= @ContractNumber
					,intContractSeq					= @ContractSeq
					,dblPriceUOMQuantity			= @PriceUOMQuantity
					,dblQuantity					= @Quantity
					,dblAvailableQty				= @AvailableQuantity
					,ysnUnlimitedQty				= @UnlimitedQuantity
					,strPricingType					= @PricingType
					,intTermId						= @TermId
					,intSort						= intSort + 500
					,intSpecialPriceId				= @SpecialPriceId
				FROM
					[dbo].[fnARGetInventoryItemPricingDetails](
						 @ItemId
						,@CustomerId
						,@LocationId
						,@OriginalItemUOMId
						,@TransactionDate
						,@Quantity
						,@VendorId
						,@PricingLevelId
						,@TermId
						,@GetAllAvailablePricing
						,@CurrencyId
					);
			END								
	END

	IF (@PricingLevelId IS NOT NULL)
	BEGIN
		SET @Price =
			( 
				SELECT 
					P.dblUnitPrice 
				FROM
					tblICItemPricingLevel P
				WHERE
					P.intItemId = @ItemId
					AND P.intItemPricingLevelId = @PricingLevelId								 
			)
		IF(@Price IS NOT NULL)
			BEGIN
				SET @Pricing = 'Inventory - Pricing Level'
				SET @Sort = 1000
				INSERT @returntable(dblPrice, dblUnitPrice, dblTermDiscount, strTermDiscountBy, dblTermDiscountRate, ysnTermDiscountExempt, strPricing, intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType, dblCurrencyExchangeRate, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intContractUOMId, strContractUOM, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblPriceUOMQuantity, dblQuantity, dblAvailableQty, ysnUnlimitedQty, strPricingType, intTermId, intSort, intSpecialPriceId)
				SELECT @Price, @Price, @TermDiscount, @TermDiscountBy, @TermDiscountRate, @TermDiscountExempt, @Pricing, @CurrencyExchangeRateTypeId, @CurrencyExchangeRateType, @CurrencyExchangeRate, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ContractUOMId, @ContractUOM, @PriceUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @PriceUOMQuantity, @Quantity, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @TermId, @Sort, @SpecialPriceId			
				IF @GetAllAvailablePricing = 0 RETURN
			END	
	END
	
	--DECLARE @ItemVendorId				INT
	--		,@ItemLocationId			INT
	--		,@ItemCategoryId			INT
	--		,@ItemCategory				NVARCHAR(100)
	--		,@UOMQuantity				NUMERIC(18,6)

	SELECT TOP 1 
		 @ItemVendorId				= intItemVendorId
		,@ItemLocationId			= intItemLocationId
		,@ItemCategoryId			= intItemCategoryId
		,@ItemCategory				= strItemCategory
		,@UOMQuantity				= dblUOMQuantity
	FROM
		[dbo].[fnARGetLocationItemVendorDetailsForPricing](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@OriginalItemUOMId
			,@VendorId
			,NULL
			,NULL
		);
		
		
	
	--Item Standard Pricing
	IF ISNULL(@UOMQuantity,0) = 0
		SET @UOMQuantity = 1
	SET @Price = @UOMQuantity *	
						( 
							SELECT
								P.dblSalePrice
							FROM
								tblICItemPricing P
							WHERE
								P.intItemId = @ItemId
								AND P.intItemLocationId = @ItemLocationId
							)
	IF(@Price IS NOT NULL)
		BEGIN
			DECLARE @DefaultCurrencyExchangeRateTypeId INT
			SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 [intAccountsReceivableRateTypeId] FROM tblSMMultiCurrency)

			DECLARE @FunctionalCurrencyId INT
			SET @FunctionalCurrencyId = (SELECT TOP 1 [intDefaultCurrencyId] FROM tblSMCompanyPreference)

			IF @FunctionalCurrencyId <> @CurrencyId AND @DefaultCurrencyExchangeRateTypeId IS NOT NULL AND (@CurrencyExchangeRateTypeId IS NULL OR @CurrencyExchangeRate = 0.000000)
			BEGIN
				SELECT TOP 1
					 @Price							= @Price / (CASE WHEN ISNULL([dblRate], 0.000000) = 0.000000 THEN 1.000000 ELSE [dblRate] END)
					,@CurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
					,@CurrencyExchangeRateType		= strCurrencyExchangeRateType
					,@CurrencyExchangeRate			= (CASE WHEN ISNULL([dblRate], 0.000000) = 0.000000 THEN 1.000000 ELSE [dblRate] END)
				FROM
					[vyuSMForex]
				WHERE
					[intCurrencyExchangeRateTypeId] = @DefaultCurrencyExchangeRateTypeId
					AND [intFromCurrencyId] = @CurrencyId 
					AND [intToCurrencyId] = @FunctionalCurrencyId 
					AND CAST([dtmValidFromDate] AS DATE) < = CAST(@TransactionDate AS DATE)
				ORDER BY
					[dtmValidFromDate] DESC	
			END

			SET @CurrencyExchangeRate = (CASE WHEN ISNULL(@CurrencyExchangeRate, 0.000000) = 0.000000 THEN 1.000000 ELSE @CurrencyExchangeRate END)					
			SET @Pricing = 'Inventory - Standard Pricing'
			SET @Sort = 1100
				INSERT @returntable(dblPrice, dblUnitPrice, dblTermDiscount, strTermDiscountBy, dblTermDiscountRate, ysnTermDiscountExempt, strPricing, intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType, dblCurrencyExchangeRate, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intContractUOMId, strContractUOM, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblPriceUOMQuantity, dblQuantity, dblAvailableQty, ysnUnlimitedQty, strPricingType, intTermId, intSort, intSpecialPriceId)
				SELECT @Price, @Price, @TermDiscount, @TermDiscountBy, @TermDiscountRate, @TermDiscountExempt, @Pricing, @CurrencyExchangeRateTypeId, @CurrencyExchangeRateType, @CurrencyExchangeRate, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ContractUOMId, @ContractUOM, @PriceUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @PriceUOMQuantity, @Quantity, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @TermId, @Sort, @SpecialPriceId			
			IF @GetAllAvailablePricing = 0 RETURN
		END	
	
	IF @GetAllAvailablePricing = 1 RETURN			
	SET @Sort = 1000
	INSERT @returntable(dblPrice, dblUnitPrice, dblTermDiscount, strTermDiscountBy, dblTermDiscountRate, ysnTermDiscountExempt, strPricing, intCurrencyExchangeRateTypeId, strCurrencyExchangeRateType, dblCurrencyExchangeRate, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intContractUOMId, strContractUOM, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblPriceUOMQuantity, dblQuantity, dblAvailableQty, ysnUnlimitedQty, strPricingType, intTermId, intSort, intSpecialPriceId)
	SELECT @Price, @UnitPrice, @TermDiscount, @TermDiscountBy, @TermDiscountRate, @TermDiscountExempt, @Pricing, @CurrencyExchangeRateTypeId, @CurrencyExchangeRateType, @CurrencyExchangeRate, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ContractUOMId, @ContractUOM, @PriceUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @PriceUOMQuantity, @Quantity, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @TermId, @Sort, @SpecialPriceId			
	RETURN				
END


