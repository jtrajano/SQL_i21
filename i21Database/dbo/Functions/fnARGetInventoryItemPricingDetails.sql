CREATE FUNCTION [dbo].[fnARGetInventoryItemPricingDetails]
(
	 @ItemId					INT
	,@CustomerId				INT	
	,@LocationId				INT
	,@ItemUOMId					INT
	,@TransactionDate			DATETIME
	,@Quantity					NUMERIC(18,6)
	,@VendorId					INT
	,@PricingLevelId			INT
	,@TermId					INT
	,@GetAllAvailablePricing	BIT
	,@CurrencyId				INT	
)
RETURNS @returntable TABLE
(
	 dblPrice			NUMERIC(18,6)
	,dblGrossPrice		NUMERIC(18,6)
	,strPricing			NVARCHAR(250)
	,dblTermDiscount	NUMERIC(18,6)
	,strTermDiscountBy	NVARCHAR(50)
	,dblPriceBasis		NUMERIC(18,6)
	,dblDeviation		NUMERIC(18,6)
	,dblUOMQuantity		NUMERIC(18,6)
	,intSort			INT
)
AS
BEGIN

	DECLARE  @Price				NUMERIC(18,6)
		    ,@GrossPrice 		NUMERIC(18,6)
			,@TermDiscount		NUMERIC(18,6)
			,@Pricing			NVARCHAR(250)
			,@PriceBasis		NUMERIC(18,6)
			,@Deviation			NUMERIC(18,6)
			,@DiscountBy		NVARCHAR(50)
			,@PromotionType		NVARCHAR(50)
			,@intSort			INT

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())	
	SET @intSort = 0
	
	DECLARE @ItemVendorId				INT
			,@ItemLocationId			INT
			,@ItemCategoryId			INT
			,@ItemCategory				NVARCHAR(100)
			,@UOMQuantity				NUMERIC(18,6)
			,@FunctionalCurrencyId		INT
			,@ZeroDecimal				DECIMAL(18,6)
	
	SET @ZeroDecimal = 0.000000


	SELECT TOP 1 @FunctionalCurrencyId = intDefaultCurrencyId  FROM tblSMCompanyPreference
	IF @CurrencyId IS NULL
		SET @CurrencyId = @FunctionalCurrencyId

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
			,@ItemUOMId
			,@VendorId
			,NULL
			,NULL
		);

	--Get GrossPrice regardless of Pricing level
	SELECT TOP 1 @GrossPrice = ISNULL(P.dblDefaultGrossPrice, 0)
	FROM tblICItemPricing P
	WHERE P.intItemId = @ItemId
	  AND P.intItemLocationId = @ItemLocationId
	  AND CAST(@TransactionDate AS DATE) >= CAST(ISNULL(P.dtmEffectiveRetailDate, @TransactionDate) AS DATE)
	ORDER BY CAST(ISNULL(P.dtmEffectiveRetailDate, '01/01/1900') AS DATE) DESC
					
	--Item Promotional Pricing 
	SELECT TOP 1
		@Price			= --@UOMQuantity *
							(CASE WHEN ICISP.strPromotionType = 'Terms Discount' THEN ICISP.dblUnitAfterDiscount
							ELSE
								(CASE
									WHEN ICISP.strDiscountBy = 'Amount'
										THEN ICISP.dblUnitAfterDiscount - (CASE WHEN ISNULL(ICISP.dblDiscountThruQty,0) = 0 OR @Quantity <= ICISP.dblDiscountThruQty THEN ( CASE WHEN @Quantity >= ICISP.dblUnit THEN  ISNULL(ICISP.dblDiscount, @ZeroDecimal) ELSE @ZeroDecimal END )  ELSE 0 END)
									ELSE	
										ICISP.dblUnitAfterDiscount - (CASE WHEN ISNULL(ICISP.dblDiscountThruQty,0) = 0 OR  @Quantity <= ICISP.dblDiscountThruQty THEN ( CASE WHEN @Quantity >= ICISP.dblUnit THEN  (ICISP.dblUnitAfterDiscount * (ISNULL(ICISP.dblDiscount, @ZeroDecimal)/100.000000) ) ELSE @ZeroDecimal END ) ELSE 0 END)
								END)
							END)
				 
		,@PriceBasis	= ICISP.dblUnitAfterDiscount	
		,@Deviation		= ICISP.dblUnitAfterDiscount							
		,@DiscountBy	= ICISP.strDiscountBy
		,@PromotionType	= ICISP.strPromotionType
		,@TermDiscount	= (CASE WHEN ICISP.strPromotionType = 'Terms Discount' THEN ISNULL((ISNULL(ICISP.dblDiscount, @ZeroDecimal)/ISNULL(ICISP.dblUnit, @ZeroDecimal)) * @UOMQuantity, @ZeroDecimal) ELSE @ZeroDecimal END)
		,@Pricing		= 'Inventory Promotional Pricing' + ISNULL('(' + ICISP.strPromotionType + ')','')	
	FROM
		tblICItemSpecialPricing ICISP
	WHERE
		ISNULL(ICISP.strPromotionType, '') <> ''
		AND ICISP.strPromotionType <> 'Terms Discount Exempt'
		AND ICISP.intItemId = @ItemId 
		AND ICISP.intItemLocationId = @ItemLocationId 
		AND ICISP.intItemUnitMeasureId = @ItemUOMId
		AND ISNULL(ICISP.intCurrencyId, @FunctionalCurrencyId) = @CurrencyId
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(ICISP.dtmBeginDate AS DATE) AND CAST(ISNULL(ICISP.dtmEndDate,@TransactionDate) AS DATE)
		AND (ICISP.strPromotionType = 'Terms Discount' OR ((ICISP.dblDiscountThruQty = 0 OR @Quantity <= ICISP.dblDiscountThruQty) AND @Quantity >= ICISP.dblUnit AND ICISP.strPromotionType <> 'Terms Discount'))
 	ORDER BY
		dtmBeginDate DESC
	
	IF(ISNULL(@Price, @ZeroDecimal) <> @ZeroDecimal)
		BEGIN
			IF @PromotionType = 'Terms Discount'
				BEGIN
					IF @DiscountBy = 'Terms Rate'
						BEGIN
							SET @TermDiscount =[dbo].[fnGetDiscountBasedOnTerm](GETDATE(), @TransactionDate, @TermId, (@Price * @Quantity))																	
						END					
				END
			ELSE
				BEGIN
					SET @TermDiscount = @ZeroDecimal
				END

			SET @intSort = @intSort + 1
			INSERT @returntable(dblPrice, dblGrossPrice, dblTermDiscount, strTermDiscountBy, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity, intSort)
			SELECT @Price, @GrossPrice, @TermDiscount, @DiscountBy, @Pricing, @PriceBasis, @Deviation, @UOMQuantity, @intSort
			IF @GetAllAvailablePricing = 0 RETURN;
		END
	
	--Item Pricing Level
	SET @Price = @ZeroDecimal
	IF ISNULL(@PricingLevelId,0) = 0
		BEGIN
			SELECT TOP 1 @PricingLevelId = CPL.intCompanyLocationPricingLevelId 
			FROM tblSMCompanyLocationPricingLevel CPL
			INNER JOIN (
				SELECT strLevel
				FROM tblARCustomer
				WHERE intEntityId = @CustomerId				  
			) C ON CPL.strPricingLevelName = C.strLevel
			WHERE CPL.intCompanyLocationId = @LocationId
		END
		
	IF ISNULL(@PricingLevelId,0) <> 0
	BEGIN

		DECLARE @PriceLevel AS NVARCHAR(100)
		SELECT TOP 1 @PriceLevel = strPricingLevelName FROM tblSMCompanyLocationPricingLevel WHERE intCompanyLocationPricingLevelId = @PricingLevelId
		IF EXISTS(SELECT NULL FROM tblARCustomer WHERE [intEntityId] = @CustomerId)
			BEGIN
				SELECT TOP 1 
					 @Price			= dbo.fnCalculateCostBetweenUOM(PL.intItemUnitMeasureId, @ItemUOMId, PL.dblUnitPrice)
					,@PriceBasis	= dbo.fnCalculateCostBetweenUOM(PL.intItemUnitMeasureId, @ItemUOMId, PL.dblUnitPrice)
					,@Deviation		= @ZeroDecimal
					,@Pricing		= 'Inventory - Pricing Level'
				FROM 
				tblICItemPricingLevel PL
				INNER JOIN tblSMCompanyLocationPricingLevel CPL 
					ON PL.intCompanyLocationPricingLevelId = CPL.intCompanyLocationPricingLevelId
				INNER JOIN vyuICGetItemStock VIS 
					ON PL.intItemId = VIS.intItemId
					AND PL.intItemLocationId = VIS.intItemLocationId															
				WHERE 
					CPL.strPricingLevelName = @PriceLevel	
					AND PL.intItemId = @ItemId
					AND PL.intItemLocationId = @ItemLocationId
					AND ISNULL(PL.intCurrencyId, @FunctionalCurrencyId) = @CurrencyId
					AND ((@Quantity BETWEEN ISNULL(PL.dblMin, 0) AND ISNULL(NULLIF(PL.dblMax, 0), 999999999999)) OR ( ISNULL(PL.dblMin, 0) = 0 AND ISNULL(PL.dblMax, 0) = 0))
					AND CAST(@TransactionDate AS DATE) BETWEEN CAST(ISNULL(PL.dtmEffectiveDate, @TransactionDate) AS DATE) AND CAST('12/31/2999' AS DATE)
				ORDER BY CAST(ISNULL(PL.dtmEffectiveDate, '01/01/1900') AS DATE) DESC
		
				IF(ISNULL(@Price, @ZeroDecimal) <> @ZeroDecimal)
					BEGIN
						SET @intSort = @intSort + 1
						INSERT @returntable(dblPrice, dblGrossPrice, dblTermDiscount, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity, intSort)
						SELECT @Price, @GrossPrice, @TermDiscount, @Pricing, @PriceBasis, @Deviation, @UOMQuantity, @intSort
						IF @GetAllAvailablePricing = 0 RETURN;
					END	
			END	
	END

	SET @Price = @ZeroDecimal
	SELECT TOP 1 
		--@Price			= @UOMQuantity * ICPL.dblUnitPrice
		@Price			= ICPL.dblUnitPrice
		,@PriceBasis	= ICPL.dblUnitPrice		
		,@Deviation		= @ZeroDecimal		
		,@Pricing		= 'Inventory - Pricing Level'		
	FROM
		tblICItemPricingLevel ICPL
	INNER JOIN vyuICGetItemStock ICGIS
			ON ICPL.intItemId = ICGIS.intItemId
			AND ICPL.intItemLocationId = ICGIS.intItemLocationId
	INNER JOIN tblSMCompanyLocationPricingLevel SMPL
			ON 
			ICGIS.intLocationId = SMPL.intCompanyLocationId 
			AND ICPL.intCompanyLocationPricingLevelId = SMPL.intCompanyLocationPricingLevelId --ICPL.strPriceLevel = SMPL.strPricingLevelName							
	INNER JOIN
		tblEMEntityLocation EMEL
			ON ICGIS.intLocationId = EMEL.intWarehouseId 
			AND EMEL.ysnDefaultLocation = 1
	INNER JOIN
		tblARCustomer ARC
			ON EMEL.intEntityId = ARC.[intEntityId] 
			AND SMPL.intCompanyLocationPricingLevelId  = ARC.intCompanyLocationPricingLevelId			
	INNER JOIN vyuICGetItemStock VIS
			ON ICPL.intItemId = VIS.intItemId
			AND ICPL.intItemLocationId = VIS.intItemLocationId											
	WHERE
		ARC.[intEntityId] = @CustomerId
		AND ICPL.intItemId = @ItemId
		AND ICPL.intItemLocationId = @ItemLocationId
		AND ICPL.intItemUnitMeasureId = @ItemUOMId
		AND ISNULL(ICPL.intCurrencyId, @FunctionalCurrencyId) = @CurrencyId
		AND ((@Quantity BETWEEN ISNULL(ICPL.dblMin, 0) AND ISNULL(ICPL.dblMax,0) ) OR (ISNULL(ICPL.dblMin, 0) = @ZeroDecimal AND ISNULL(ICPL.dblMax, 0) = @ZeroDecimal))
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(ISNULL(ICPL.dtmEffectiveDate, @TransactionDate) AS DATE) AND CAST('12/31/2999' AS DATE)
	ORDER BY CAST(ISNULL(ICPL.dtmEffectiveDate, '01/01/1900') AS DATE) DESC
		
	IF(ISNULL(@Price, @ZeroDecimal) <> @ZeroDecimal)
		BEGIN
			SET @intSort = @intSort + 1
			INSERT @returntable(dblPrice, dblGrossPrice, dblTermDiscount, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity, intSort)
			SELECT @Price, @GrossPrice, @TermDiscount, @Pricing, @PriceBasis, @Deviation, @UOMQuantity, @intSort
			IF @GetAllAvailablePricing = 0 RETURN;
		END		
	RETURN;				
END