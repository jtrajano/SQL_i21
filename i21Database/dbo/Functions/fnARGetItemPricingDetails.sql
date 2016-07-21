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
	,@PricingLevelId		INT
	,@AllowQtyToExceed		BIT
	,@InvoiceType			NVARCHAR(200)
	,@TermId				INT
)
RETURNS @returntable TABLE
(
	 dblPrice				NUMERIC(18,6)
	,dblTermDiscount		NUMERIC(18,6)
	,strPricing				NVARCHAR(250)
	,dblDeviation			NUMERIC(18,6)
	,intContractHeaderId	INT
	,intContractDetailId	INT
	,strContractNumber		NVARCHAR(50)
	,intContractSeq			INT
	,dblAvailableQty        NUMERIC(18,6)
	,ysnUnlimitedQty        BIT
	,strPricingType			NVARCHAR(50)
)
AS
BEGIN

DECLARE	 @Price			NUMERIC(18,6)
		,@Pricing		NVARCHAR(250)
		,@Deviation		NUMERIC(18,6)
		,@TermDiscount	NUMERIC(18,6)
		,@PricingType	NVARCHAR(50)

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())
	
	IF @CustomerPricingOnly IS NULL
		SET @CustomerPricingOnly = 0			
		
	IF @CustomerPricingOnly = 0
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
				,@AllowQtyToExceed
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
			SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
			RETURN
		END	
		
	END			
								
	BEGIN
		--Customer Special Pricing		
		SELECT TOP 1
			 @Price		= dblPrice
			,@Pricing	= strPricing
			,@Deviation	= dblDeviation
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
				,@InvoiceType
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
			SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
			RETURN
		END	
	END
	
	IF @CustomerPricingOnly = 1
		RETURN;
	
	BEGIN
		--Inventory Special Pricing
		SELECT TOP 1
			 @Price			= dblPrice
			,@Pricing		= strPricing
			,@Deviation		= dblDeviation
			,@TermDiscount	= dblTermDiscount 
		FROM
			[dbo].[fnARGetInventoryItemPricingDetails](
				 @ItemId
				,@CustomerId
				,@LocationId
				,@ItemUOMId
				,@TransactionDate
				,@Quantity
				,@VendorId
				,@PricingLevelId
				,@TermId
			);
			
			
		IF(@Price IS NOT NULL)
		BEGIN
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
			SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
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
			INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
			SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
			RETURN
		END	
			
	INSERT @returntable(dblPrice, dblTermDiscount, strPricing, dblDeviation, intContractHeaderId, intContractDetailId, strContractNumber, intContractSeq, dblAvailableQty, ysnUnlimitedQty, strPricingType)
	SELECT @Price, @TermDiscount, @Pricing, @Deviation, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
	RETURN				
END
