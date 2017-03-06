CREATE FUNCTION [dbo].[fnTMGetItemPricingDetails]
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
	,strPricing				NVARCHAR(250)
	,intContractDetailId	INT
)
AS
BEGIN
	INSERT @returntable(dblPrice
						,strPricing
						,intContractDetailId)
	SELECT dblPrice
		  ,strPricing
		  ,intContractDetailId
	FROM [dbo].[fnARGetItemPricingDetails](
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
		,@AllowQtyToExceed		
		,@InvoiceType			
		,@TermId				
		,@GetAllAvailablePricing)

	RETURN
END