CREATE FUNCTION [dbo].[fnARGetItemPrice]
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
	,@OriginalQuantity			NUMERIC(18,6)
	,@CustomerPricingOnly		BIT
	,@ItemPricingOnly			BIT
	,@ExcludeContractPricing	BIT
	,@VendorId					INT
	,@SupplyPointId				INT
	,@LastCost					NUMERIC(18,6)
	,@ShipToLocationId			INT
	,@VendorLocationId			INT
	,@InvoiceType				NVARCHAR(200)
	,@GetAllAvailablePricing	BIT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @ItemPrice NUMERIC(18,6)

	SELECT
		 @ItemPrice	= dblPrice		
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
			,NULL
			,NULL
			,@OriginalQuantity
			,@CustomerPricingOnly
			,@ItemPricingOnly
			,@ExcludeContractPricing
			,@VendorId
			,@SupplyPointId
			,@LastCost
			,@ShipToLocationId
			,@VendorLocationId
			,NULL
			,NULL
			,@InvoiceType
			,NULL
			,@GetAllAvailablePricing
		)

	RETURN @ItemPrice
END
