CREATE PROCEDURE [dbo].[uspARGetItemPrice]
	@ItemId				INT
	,@CustomerId		INT	
	,@LocationId		INT
	,@ItemUOMId			INT				= NULL
	,@TransactionDate	DATETIME		= NULL
	,@Quantity			NUMERIC(18,6)
	,@Price				NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing			NVARCHAR(250)	= NULL OUTPUT
	,@ContractHeaderId	INT				= NULL OUTPUT
	,@ContractDetailId	INT				= NULL OUTPUT
	,@ContractNumber	INT				= NULL OUTPUT
	,@ContractSeq		INT				= NULL OUTPUT
	,@OriginalQuantity	NUMERIC(18,6)	= NULL
AS
	--	DECLARE 	
	--	@ItemId				INT
	--	,@CustomerId		INT	
	--	,@LocationId		INT
	--	,@ItemUOMId			INT
	--	,@TransactionDate	DATETIME
	--	,@Quantity			NUMERIC(18,6)
	--	,@CustomerPricing	NVARCHAR(250)


	--SET @ItemId = 5347
	--SET @CustomerId = 457
	--SET @LocationId = 1
	--SET @ItemUOMId = 793
	--SET @TransactionDate = '03/22/2015'
	--SET @Quantity = 6



	--DECLARE	@Price AS NUMERIC(18,6)
	--		,@Pricing AS NVARCHAR(250)
	--SET @Price = NULL;
	--SET @Pricing = '';
	
	
	DECLARE @VendorId			INT
			,@ItemLocationId	INT
			,@ItemCategoryId	INT
			,@ItemCategory		NVARCHAR(100)
			,@UOMQuantity		NUMERIC(18,6)

	SELECT @VendorId	   = VI.intVendorId
		  ,@ItemLocationId = intItemLocationId
		  ,@ItemCategoryId = I.intCategoryId
		  ,@ItemCategory   = C.strCategoryCode
		  ,@UOMQuantity    = CASE WHEN UOM.dblUnitQty = 0 OR UOM.dblUnitQty IS NULL THEN 1.00 ELSE UOM.dblUnitQty END
	FROM
		tblICItem I
	INNER JOIN
		vyuICGetItemStock VI
			ON I.intItemId = VI.intItemId
	LEFT OUTER JOIN
		tblICCategory C
			ON I.intCategoryId = C.intCategoryId
	LEFT OUTER JOIN
		tblICItemUOM UOM
			ON I.intItemId = UOM.intItemId
	WHERE
		I.intItemId = @ItemId
		AND VI.intLocationId = @LocationId 
		AND (UOM.intItemUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
		
		
	--Customer Contract Price
	
	SELECT TOP 1
		 @Price				= dblCashPrice
		,@ContractHeaderId	= intContractHeaderId
		,@ContractDetailId	= intContractDetailId
		,@ContractNumber	= intContractNumber
		,@ContractSeq		= intContractSeq
	FROM
		vyuCTContractDetailView
	WHERE
		intEntityId = @CustomerId
		AND intCompanyLocationId = @LocationId
		AND intItemUOMId = @ItemUOMId
		AND intItemId = @ItemId
		AND ISNULL(@OriginalQuantity,0.00) + (dblDetailQuantity - ISNULL(dblScheduleQty,0)) >= @Quantity
		AND @TransactionDate BETWEEN dtmStartDate AND dtmEndDate
		AND intContractHeaderId = @ContractHeaderId
		AND intContractDetailId = @ContractDetailId
		AND ISNULL(@OriginalQuantity,0.00) + (dblDetailQuantity - ISNULL(dblScheduleQty,0)) > 0
		AND dblBalance > 0
	ORDER BY
		 dtmStartDate
		,intContractSeq
		
	IF(@Price IS NOT NULL)
	BEGIN
		SET @Pricing = 'Contracts - Customer Pricing'
		--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
		RETURN 1;
	END
	
	SET @ContractHeaderId	= NULL
	SET @ContractDetailId	= NULL
	SET @ContractNumber		= NULL
	SET @ContractSeq		= NULL		
			
	SELECT TOP 1
		 @Price				= dblCashPrice
		,@ContractHeaderId	= intContractHeaderId
		,@ContractDetailId	= intContractDetailId
		,@ContractNumber	= intContractNumber
		,@ContractSeq		= intContractSeq
	FROM
		vyuCTContractDetailView
	WHERE
		intEntityId = @CustomerId
		AND intCompanyLocationId = @LocationId
		AND intItemUOMId = @ItemUOMId
		AND intItemId = @ItemId
		AND (dblDetailQuantity - ISNULL(dblScheduleQty,0)) >= @Quantity
		AND @TransactionDate BETWEEN dtmStartDate AND dtmEndDate
		AND (dblDetailQuantity - ISNULL(dblScheduleQty,0)) > 0
		AND dblBalance > 0
	ORDER BY
		 dtmStartDate
		,intContractSeq
		
	IF(@Price IS NOT NULL)
	BEGIN
		SET @Pricing = 'Contracts - Customer Pricing'
		--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
		RETURN 1;
	END	
			
	EXEC [dbo].[uspARGetCustomerSpecialPrice]
		@ItemId
		,@CustomerId
		,@LocationId
		,@ItemUOMId
		,@TransactionDate
		,@Quantity
		,@Price OUTPUT
		,@Pricing OUTPUT
		
	IF(@Price IS NOT NULL)
	BEGIN		
		RETURN 1;
	END	

	--Item Special Pricing
	SET @Price = @UOMQuantity *	
					(	SELECT 
							--dblUnitAfterDiscount
							(CASE
								WHEN strDiscountBy = 'Amount'
									THEN dblUnitAfterDiscount - ISNULL(dblDiscount, 0.00)
								ELSE	
									dblUnitAfterDiscount - (dblUnitAfterDiscount * (ISNULL(dblDiscount, 0.00)/100.00) )
							END)
						FROM
							tblICItemSpecialPricing 
						WHERE
							intItemId = @ItemId 
							AND intItemLocationId = @ItemLocationId 
							AND (@ItemUOMId IS NULL OR intItemUnitMeasureId = @ItemUOMId)
							AND @TransactionDate BETWEEN dtmBeginDate AND dtmEndDate
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Special Pricing'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN 1;
		END	


	--Item Pricing Level
	DECLARE @PricingLevel NVARCHAR(100)
	SET @Price = @UOMQuantity *	
						( 
							SELECT
								PL.dblUnitPrice
							FROM
								tblICItemPricingLevel PL
							INNER JOIN
								tblEntityLocation CL
									ON PL.strPriceLevel = CL.strPricingLevel
							INNER JOIN
								tblARCustomer C									
									ON CL.intEntityId = C.intEntityCustomerId
									AND CL.ysnDefaultLocation = 1															
							INNER JOIN vyuICGetItemStock VIS
									ON PL.intItemId = VIS.intItemId
									AND PL.intItemLocationId = VIS.intItemLocationId															
							WHERE
								C.intEntityCustomerId = @CustomerId
								AND PL.intItemId = @ItemId
								AND PL.intItemLocationId = @ItemLocationId
								AND PL.intItemUnitMeasureId = @ItemUOMId
								AND @Quantity BETWEEN PL.dblMin AND PL.dblMax
							)
	IF(@Price IS NOT NULL)
		BEGIN
			SET @Pricing = 'Inventory - Pricing Level'
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN 1;
		END	


	--Item Standard Pricing
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
			--SELECT @Price AS 'Price', @Pricing AS 'Pricing'	
			RETURN 1;
		END	



RETURN 0
