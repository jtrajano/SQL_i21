CREATE FUNCTION [dbo].[fnARGetInventoryItemPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@TransactionDate		DATETIME
	,@Quantity				NUMERIC(18,6)
	,@VendorId				INT
)
RETURNS @returntable TABLE
(
	 dblPrice			NUMERIC(18,6)
	,strPricing			NVARCHAR(250)
	,dblPriceBasis		NUMERIC(18,6)
	,dblDeviation		NUMERIC(18,6)
	,dblUOMQuantity		NUMERIC(18,6)
)
AS
BEGIN

	DECLARE  @Price			NUMERIC(18,6)
			,@Pricing		NVARCHAR(250)
			,@PriceBasis	NUMERIC(18,6)
			,@Deviation		NUMERIC(18,6)

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())	
	
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
			,@ItemUOMId
			,@VendorId
			,NULL
			,NULL
		);													
					
	--Item Special Pricing
	SELECT TOP 1 
		@Price			= @UOMQuantity *
							(CASE
								WHEN strDiscountBy = 'Amount'
									THEN dblUnitAfterDiscount - ISNULL(dblDiscount, 0.00)
								ELSE	
									dblUnitAfterDiscount - (dblUnitAfterDiscount * (ISNULL(dblDiscount, 0.00)/100.00) )
							END)
		,@PriceBasis	= dblUnitAfterDiscount		
		,@Deviation		= 
							(CASE
								WHEN strDiscountBy = 'Amount'
									THEN ISNULL(dblDiscount, 0.00)
								ELSE	
									(dblUnitAfterDiscount * (ISNULL(dblDiscount, 0.00)/100.00) )
							END)		
		,@Pricing		= 'Inventory Special Pricing'		
	FROM
		tblICItemSpecialPricing 
	WHERE
		intItemId = @ItemId 
		AND intItemLocationId = @ItemLocationId 
		AND (@ItemUOMId IS NULL OR intItemUnitMeasureId = @ItemUOMId)
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmBeginDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
	ORDER BY
		intItemSpecialPricingId 
	
	IF(ISNULL(@Price,0) <> 0)
		BEGIN
			INSERT @returntable(dblPrice, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
			SELECT @Price, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
			RETURN;
		END
	
	--Item Pricing Level
	SELECT TOP 1 
		@Price			= @UOMQuantity * PL.dblUnitPrice
		,@PriceBasis	= PL.dblUnitPrice		
		,@Deviation		= 0.00		
		,@Pricing		= 'Inventory - Pricing Level'		
	FROM
		tblICItemPricingLevel PL
	INNER JOIN
		tblARCustomer C									
			ON PL.strPriceLevel = C.strLevel																								
	INNER JOIN vyuICGetItemStock VIS
			ON PL.intItemId = VIS.intItemId
			AND PL.intItemLocationId = VIS.intItemLocationId															
	WHERE
		C.intEntityCustomerId = @CustomerId
		AND C.strPricing = 'Multi-Level Pricing'
		AND PL.intItemId = @ItemId
		AND PL.intItemLocationId = @ItemLocationId
		AND PL.intItemUnitMeasureId = @ItemUOMId
		AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
	ORDER BY
		PL.intItemPricingLevelId
		
	IF(ISNULL(@Price,0) <> 0)
		BEGIN
			INSERT @returntable(dblPrice, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
			SELECT @Price, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
			RETURN;
		END		
		
	SELECT TOP 1 
		@Price			= @UOMQuantity * PL.dblUnitPrice
		,@PriceBasis	= PL.dblUnitPrice		
		,@Deviation		= 0.00		
		,@Pricing		= 'Inventory - Pricing Level'		
	FROM
		tblICItemPricingLevel PL																								
	INNER JOIN vyuICGetItemStock VIS
			ON PL.intItemId = VIS.intItemId
			AND PL.intItemLocationId = VIS.intItemLocationId															
	WHERE
		PL.intItemId = @ItemId
		AND PL.intItemLocationId = @ItemLocationId
		AND PL.intItemUnitMeasureId = @ItemUOMId
		AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
	ORDER BY
		PL.intItemPricingLevelId


	IF(ISNULL(@Price,0) <> 0)
		BEGIN
			INSERT @returntable(dblPrice, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
			SELECT @Price, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
			RETURN;
		END
			
	RETURN;				
END
