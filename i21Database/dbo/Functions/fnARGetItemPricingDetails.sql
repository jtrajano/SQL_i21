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
	 dblPrice				NUMERIC(18,6)
	,dblTermDiscount		NUMERIC(18,6)
	,strTermDiscountBy		NVARCHAR(50)
	,strPricing				NVARCHAR(250)
	,intSubCurrencyId		INT
	,dblSubCurrencyRate		NUMERIC(18,6)
	,strSubCurrency			NVARCHAR(40)
	,intPriceUOMId			INT
	,strPriceUOM			NVARCHAR(50)
	,dblDeviation			NUMERIC(18,6)
	,intContractHeaderId	INT
	,intContractDetailId	INT
	,strContractNumber		NVARCHAR(50)
	,intContractSeq			INT
	,dblAvailableQty        NUMERIC(18,6)
	,ysnUnlimitedQty        BIT
	,strPricingType			NVARCHAR(50)
	,intSort				INT
)
AS
BEGIN

DECLARE	 @Price				NUMERIC(18,6)
		,@Pricing			NVARCHAR(250)
		,@Deviation			NUMERIC(18,6)
		,@TermDiscount		NUMERIC(18,6)
		,@PricingType		NVARCHAR(50)
		,@TermDiscountBy	NVARCHAR(50)
		,@SubCurrencyRate	NUMERIC(18,6)
		,@SubCurrencyId		INT
		,@SubCurrency		NVARCHAR(40)
		,@PriceUOM			NVARCHAR(50)
		,@OriginalItemUOMId	INT

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
		
	IF NOT(@CustomerPricingOnly = 1 OR @ExcludeContractPricing = 1) AND @ItemPricingOnly = 0
	BEGIN
		--Customer Contract Price		
		SELECT TOP 1
			 @Price				= dblPrice
			,@Pricing			= strPricing
			,@Deviation			= dblPrice 
			,@ContractHeaderId	= intContractHeaderId
			,@ContractDetailId	= intContractDetailId
			,@ContractNumber	= strContractNumber
			,@ContractSeq		= intContractSeq
			,@AvailableQuantity = dblAvailableQty
			,@UnlimitedQuantity = ysnUnlimitedQty
			,@PricingType		= strPricingType
			,@SubCurrencyId		= intSubCurrencyId
			,@SubCurrencyRate	= dblSubCurrencyRate
			,@SubCurrency		= strSubCurrency
			,@ItemUOMId			= intPriceUOMId 
			,@PriceUOM			= strPriceUOM
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
			INSERT @returntable(dblPrice, dblTermDiscount, strTermDiscountBy, strPricing, intSubCurrencyId, dblSubCurrencyRate, strSubCurrency, intPriceUOMId, strPriceUOM, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType, intSort)
			SELECT @Price, @TermDiscount, @TermDiscountBy, @Pricing, @SubCurrencyId, @SubCurrencyRate, @SubCurrency, @ItemUOMId, @PriceUOM, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType, 1
			IF @GetAllAvailablePricing = 0 RETURN
		END	
		
	END
	
	SELECT
		 @ContractHeaderId	= NULL
		,@ContractDetailId	= NULL
		,@ContractNumber	= NULL
		,@ContractSeq		= NULL
		,@AvailableQuantity	= 0
		,@UnlimitedQuantity	= 0
		,@PricingType		= NULL

	IF @ItemPricingOnly = 0								
	BEGIN
	--Customer Special Pricing		
		IF @GetAllAvailablePricing = 0 
			BEGIN
				SELECT TOP 1
					 @Price		= dblPrice
					,@Pricing	= strPricing
					,@Deviation	= dblDeviation
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
					INSERT @returntable(dblPrice, dblTermDiscount, strTermDiscountBy, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
					SELECT @Price, @TermDiscount, @TermDiscountBy, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
					RETURN
				END	
			END
		ELSE
			BEGIN
				INSERT @returntable(
					 dblPrice
					,dblTermDiscount
					,strPricing
					,dblDeviation
					,intContractHeaderId
					,intContractDetailId
					,strContractNumber
					,intContractSeq
					,dblAvailableQty
					,ysnUnlimitedQty
					,strPricingType
					,intSort)
				SELECT 
					 dblPrice				= dblPrice 
					,dblTermDiscount		= 0
					,strPricing				= strPricing 
					,dblDeviation			= dblDeviation 
					,intContractHeaderId	= NULL
					,intContractDetailId	= NULL
					,strContractNumber		= ''
					,intContractSeq			= NULL
					,dblAvailableQty		= 0
					,ysnUnlimitedQty		= 0
					,strPricingType			= ''
					,intSort				= intSort + 10
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
					INSERT @returntable(dblPrice, dblTermDiscount, strTermDiscountBy, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
					SELECT @Price, @TermDiscount, @TermDiscountBy, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
					RETURN
				END	
			END
		ELSE
			BEGIN
				INSERT @returntable(
					 dblPrice
					,dblTermDiscount
					,strTermDiscountBy
					,strPricing
					,dblDeviation
					,intContractHeaderId
					,intContractDetailId
					,strContractNumber
					,intContractSeq
					,dblAvailableQty
					,ysnUnlimitedQty
					,strPricingType
					,intSort)
				SELECT 
					 dblPrice				= dblPrice 
					,dblTermDiscount		= dblTermDiscount
					,strTermDiscountBy		= strTermDiscountBy 
					,strPricing				= strPricing 
					,dblDeviation			= dblDeviation 
					,intContractHeaderId	= NULL
					,intContractDetailId	= NULL
					,strContractNumber		= ''
					,intContractSeq			= NULL
					,dblAvailableQty		= 0
					,ysnUnlimitedQty		= 0
					,strPricingType			= ''
					,intSort				= intSort + 500
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
				SET @Pricing = 'Inventory - Standard Pricing'
				INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType, intSort)
				SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType, 1000
				IF @GetAllAvailablePricing = 0 RETURN
			END	
	END
	
	DECLARE @ItemVendorId				INT
			,@ItemLocationId			INT
			,@ItemCategoryId			INT
			,@ItemCategory				NVARCHAR(100)
			,@UOMQuantity				NUMERIC(18,6)

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
			SET @Pricing = 'Inventory - Standard Pricing'
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType, intSort)
			SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType, 1100
			IF @GetAllAvailablePricing = 0 RETURN
		END	
	
	IF @GetAllAvailablePricing = 1 RETURN			
	INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
	SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
	RETURN				
END


