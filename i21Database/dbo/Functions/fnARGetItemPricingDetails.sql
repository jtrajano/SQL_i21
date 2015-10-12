CREATE FUNCTION [dbo].[fnARGetItemPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@TransactionDate		DATETIME
	,@Quantity				NUMERIC(18,6)
	,@ContractHeaderId		INT
	,@ContractDetailId		INT
	,@ContractNumber		NVARCHAR(50)
	,@ContractSeq			INT
	,@AvailableQuantity		NUMERIC(18,6)
	,@UnlimitedQuantity     BIT
	,@OriginalQuantity		NUMERIC(18,6)
	,@CustomerPricingOnly	BIT
	,@VendorId				INT
	,@SupplyPointId			INT
	,@LastCost				NUMERIC(18,6)
	,@ShipToLocationId      INT
	,@VendorLocationId		INT
)
RETURNS @returntable TABLE
(
	 dblPrice				NUMERIC(18,6)
	,strPricing				NVARCHAR(250)
	,intContractHeaderId	INT
	,intContractDetailId	INT
	,strContractNumber		NVARCHAR(50)
	,intContractSeq			INT
	,dblAvailableQty        NUMERIC(18,6)
	,ysnUnlimitedQty        BIT
)
AS
BEGIN

DECLARE	 @Price		NUMERIC(18,6)
		,@Pricing	NVARCHAR(250)

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())
	
	IF @CustomerPricingOnly IS NULL
		SET @CustomerPricingOnly = 0			
		
	IF @CustomerPricingOnly = 0
	BEGIN
		--Customer Contract Price		
		SELECT TOP 1
			 @Price				= dblPrice
			,@Pricing			= strPricing
			,@ContractHeaderId	= intContractHeaderId
			,@ContractDetailId	= intContractDetailId
			,@ContractNumber	= strContractNumber
			,@ContractSeq		= intContractSeq
			,@AvailableQuantity = dblAvailableQty
			,@UnlimitedQuantity = ysnUnlimitedQty
		FROM
			[dbo].[fnARGetContractPricingDetails](
				 @ItemId
				,@CustomerId
				,@LocationId
				,@ItemUOMId
				,@TransactionDate
				,@Quantity
				,@ContractHeaderId
				,@ContractDetailId
				,@OriginalQuantity
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			INSERT @returntable(dblPrice, strPricing, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty)
			SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
			RETURN
		END	
		
	END			
								
	BEGIN
		--Customer Special Pricing		
		SELECT TOP 1
			 @Price		= dblPrice
			,@Pricing	= strPricing
		FROM
			[dbo].[fnARGetCustomerPricingDetails](
				 @ItemId
				,@CustomerId
				,@LocationId
				,@ItemUOMId
				,@TransactionDate
				,@Quantity
				,@VendorId
				,@SupplyPointId
				,@LastCost
				,@ShipToLocationId
				,@VendorLocationId
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			INSERT @returntable(dblPrice, strPricing, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty)
			SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
			RETURN
		END	
	END
	
	IF @CustomerPricingOnly = 1
		RETURN;
	
	BEGIN
		--Inventory Special Pricing
		SELECT TOP 1
			 @Price		= dblPrice
			,@Pricing	= strPricing
		FROM
			[dbo].[fnARGetInventoryItemPricingDetails](
				 @ItemId
				,@CustomerId
				,@LocationId
				,@ItemUOMId
				,@TransactionDate
				,@Quantity
				,@VendorId
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			INSERT @returntable(dblPrice, strPricing, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty)
			SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
			RETURN
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
			,@ItemUOMId
			,@VendorId
			,NULL
			,NULL
		);		
	
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
			INSERT @returntable
			SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
			RETURN
		END	
			
	INSERT @returntable
	SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity
	RETURN				
END
