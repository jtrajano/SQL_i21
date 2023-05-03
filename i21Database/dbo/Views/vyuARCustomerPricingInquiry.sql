CREATE VIEW [dbo].[vyuARCustomerPricingInquiry]
AS
SELECT intEntityCustomerId	= CUSTOMER.intEntityId	 
	 , intItemId			= ITEM.intItemId
	 , intCompanyLocationId	= ITEM.intLocationId
	 , intUnitMeasureId		= ITEM.intUnitMeasureId
	 , strItemNo			= ITEM.strItemNo
	 , strItemDescription	= ITEM.strDescription
	 , strLocationName		= ITEM.strLocationName
	 , strUnitMeasure		= ITEM.strUnitMeasure
	 , strPricing			= ISNULL(PRICING.strPricing, 'Inventory - Standard Pricing')
	 , dblPrice				= ISNULL(PRICING.dblPrice, 0.000000)
FROM tblARCustomer CUSTOMER
CROSS APPLY (
	SELECT intItemId		= I.intItemId
		 , intLocationId	= IL.intLocationId
		 , intUnitMeasureId	= UOM.intUnitMeasureId
		 , intItemUOMId		= IUOM.intItemUOMId
		 , strItemNo		= I.strItemNo
		 , strDescription	= I.strDescription
		 , strLocationName	= L.strLocationName
		 , strUnitMeasure	= UOM.strUnitMeasure
	FROM tblICItem I
	INNER JOIN tblICItemUOM IUOM ON I.intItemId = IUOM.intItemId AND IUOM.ysnStockUOM = 1
	INNER JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
	LEFT JOIN tblSMCompanyLocation L ON IL.intLocationId = L.intCompanyLocationId
	LEFT JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
) ITEM
OUTER APPLY (
	SELECT TOP 1 intDefaultCurrencyId 
	FROM tblSMCompanyPreference
) CPREF
CROSS APPLY (
	SELECT * FROM dbo.[fnARGetItemPricingDetails](
		 ITEM.intItemId				--@ItemId
		,CUSTOMER.intEntityId		--@CustomerId
		,ITEM.intLocationId			--@LocationId
		,ITEM.intItemUOMId			--@ItemUOMId
		,ISNULL(CUSTOMER.intCurrencyId, CPREF.intDefaultCurrencyId)		--@CurrencyId
		,GETDATE()					--@TransactionDate
		,1							--@Quantity
		,NULL						--@ContractHeaderId
		,NULL						--@ContractDetailId
		,NULL						--@ContractNumber
		,NULL						--@ContractSeq
		,NULL  						--@ItemContractHeaderId
	    ,NULL  						--@ItemContractDetailId
	    ,NULL  						--@ItemContractNumber
	    ,NULL  						--@ItemContractSeq
		,NULL						--@AvailableQuantity
		,0							--@UnlimitedQuantity
		,0							--@OriginalQuantity
		,0							--@CustomerPricingOnly
		,0							--@ItemPricingOnly
		,1							--@ExcludeContractPricing
		,NULL						--@VendorId
		,NULL						--@SupplyPointId
		,NULL						--@LastCost
		,CUSTOMER.intShipToId		--@ShipToLocationId
		,NULL						--@VendorLocationId
		,NULL						--@PricingLevelId
		,NULL						--@AllowQtyToExceed
		,'Standard'					--@InvoiceType
		,CUSTOMER.intTermsId		--@TermId
		,0							--@GetAllAvailablePricing
		,1.000000					--@CurrencyExchangeRate
		,NULL						--@CurrencyExchangeRateTypeId
		,1							--@ysnFromItemSelection
		,0 							--@ysnDisregardContractQty
	)
) PRICING
