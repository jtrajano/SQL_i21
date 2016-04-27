﻿CREATE FUNCTION [dbo].[fnARGetInventoryItemPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@TransactionDate		DATETIME
	,@Quantity				NUMERIC(18,6)
	,@VendorId				INT
	,@PricingLevelId		INT
	,@TermId				INT
)
RETURNS @returntable TABLE
(
	 dblPrice			NUMERIC(18,6)
	,strPricing			NVARCHAR(250)
	,dblTermDiscount	NUMERIC(18,6)
	,dblPriceBasis		NUMERIC(18,6)
	,dblDeviation		NUMERIC(18,6)
	,dblUOMQuantity		NUMERIC(18,6)
)
AS
BEGIN

	DECLARE  @Price			NUMERIC(18,6)
			,@TermDiscount	NUMERIC(18,6)
			,@Pricing		NVARCHAR(250)
			,@PriceBasis	NUMERIC(18,6)
			,@Deviation		NUMERIC(18,6)
			,@DiscountBy	NVARCHAR(50)
			,@PromotionType	NVARCHAR(50)

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
					
	--Item Promotional Pricing
	SELECT TOP 1 
		@Price			= @UOMQuantity *
							(CASE WHEN strPromotionType = 'Terms Discount' THEN dblUnitAfterDiscount
							ELSE
								(CASE
									WHEN strDiscountBy = 'Amount'
										THEN dblUnitAfterDiscount - ISNULL(dblDiscount, 0.00)
									ELSE	
										dblUnitAfterDiscount - (dblUnitAfterDiscount * (ISNULL(dblDiscount, 0.00)/100.00) )
								END)
							END)
		,@PriceBasis	= dblUnitAfterDiscount		
		,@Deviation		= (CASE WHEN strPromotionType = 'Terms Discount' THEN dblDiscount
							ELSE
								(CASE
									WHEN strDiscountBy = 'Amount'
										THEN ISNULL(dblDiscount, 0.00)
									ELSE	
										(dblUnitAfterDiscount * (ISNULL(dblDiscount, 0.00)/100.00) )
								END)
							END) 									
		,@DiscountBy	= strDiscountBy
		,@PromotionType	= strPromotionType
		,@TermDiscount	= @Quantity *
								(CASE
									WHEN strDiscountBy = 'Amount'
										THEN ISNULL(dblDiscount, 0.00)
									ELSE	
										(@Price * (ISNULL(dblDiscount, 0.00)/100.00) )
								END)
		,@Pricing		= 'Inventory Promotional Pricing' + ISNULL('(' + strPromotionType + ')','')	
	FROM
		tblICItemSpecialPricing 
	WHERE
		intItemId = @ItemId 
		AND intItemLocationId = @ItemLocationId 
		AND intItemUnitMeasureId = @ItemUOMId
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmBeginDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
	ORDER BY
		dtmBeginDate DESC
	
	IF(ISNULL(@Price,0) <> 0)
		BEGIN
			IF @PromotionType = 'Terms Discount'
				BEGIN
					IF @DiscountBy = 'Terms Rate'
						BEGIN
							DECLARE @Type NVARCHAR(100)
							DECLARE @DiscountDay INT, @DayMonthDue INT, @DueNextMonth INT
							DECLARE @DiscountEP NUMERIC(18,6)
							DECLARE @DiscountDate DATETIME
							DECLARE @InvoiceDiscountTotal NUMERIC(18,6)


							SELECT 
								 @Type = strType 
								,@DiscountDay = ISNULL(intDiscountDay, 0)
								,@DiscountDate = ISNULL(dtmDiscountDate, @TransactionDate) 
								,@DiscountEP = ISNULL(dblDiscountEP,0)
							FROM
								tblSMTerm
							WHERE
								intTermID = @TermId

							IF (@Type = 'Standard')
								BEGIN
									IF (DATEADD(DAY,@DiscountDay,@TransactionDate) >= @TransactionDate)
										BEGIN
											SET @TermDiscount = (@Quantity * (@Price * (@DiscountEP / 100)))
										END
								END	
							ELSE IF (@Type = 'Date Driven')
								BEGIN
									DECLARE @TransactionMonth int, @TransactionDay int, @TransactionYear int
									SELECT @TransactionMonth = DATEPART(MONTH,@TransactionDate), @TransactionDay = DATEPART(DAY,@TransactionDate) ,@TransactionYear = DATEPART(YEAR,@TransactionDate)
		
									DECLARE @TempDiscountDate datetime
									Set @TempDiscountDate = CONVERT(datetime, (CAST(@TransactionMonth AS nvarchar(10)) + '/' + CAST(@DiscountDay AS nvarchar(10)) + '/' + CAST(@TransactionYear AS nvarchar(10))), 101)
			
									IF (@TempDiscountDate >= @TransactionDate)
										BEGIN
											SET @TermDiscount = (@Quantity * (@Price * (@DiscountEP / 100)))
										END		
								END	
							ELSE
								BEGIN
									IF (@DiscountDate >= @TransactionDate)
										BEGIN
											SET @TermDiscount = (@Quantity * (@Price * (@DiscountEP / 100)))
										END
								END
						END					
				END
			ELSE
				BEGIN
					SET @TermDiscount = 0.00
				END

			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
			SELECT @Price, @TermDiscount, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
			RETURN;
		END
	
	--Item Pricing Level

	IF ISNULL(@PricingLevelId,0) <> 0
	BEGIN

		DECLARE @PriceLevel AS NVARCHAR(100)
		SELECT TOP 1 @PriceLevel = strPricingLevelName FROM tblSMCompanyLocationPricingLevel WHERE intCompanyLocationPricingLevelId = @PricingLevelId
		IF EXISTS(SELECT NULL FROM tblARCustomer WHERE intEntityCustomerId = @CustomerId AND strPricing = 'Multi-Level Pricing')
			BEGIN
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
					PL.strPriceLevel = @PriceLevel	
					AND PL.intItemId = @ItemId
					AND PL.intItemLocationId = @ItemLocationId
					AND PL.intItemUnitMeasureId = @ItemUOMId
					AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
				ORDER BY
					PL.intItemPricingLevelId
		
				IF(ISNULL(@Price,0) <> 0)
					BEGIN
						INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
						SELECT @Price, @TermDiscount, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
						RETURN;
					END	
			END	
	END

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
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
			SELECT @Price, @TermDiscount, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
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
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblPriceBasis, dblDeviation, dblUOMQuantity)
			SELECT @Price, @TermDiscount, @Pricing, @PriceBasis, @Deviation, @UOMQuantity
			RETURN;
		END
			
	RETURN;				
END
