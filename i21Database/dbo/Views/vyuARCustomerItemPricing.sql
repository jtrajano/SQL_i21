CREATE VIEW [dbo].[vyuARCustomerItemPricing]
	AS 
	

SELECT
	 [strTransactionNumber]	= ARI.[strInvoiceNumber]	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intEntityCustomerId]	= ARI.[intEntityCustomerId]	--CAST(NULL AS INT)
	,[intItemId]			= ARID.[intItemId]			--CAST(NULL AS INT)
	,[dblPrice]				= IP.[dblPrice]				--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]		= IP.[dblTermDiscount]		--CAST(0 AS NUMERIC(18,6))
	,[strPricing]			= IP.[strPricing]			--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]			= IP.[dblDeviation]			--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]	= IP.[intContractHeaderId]	--CAST(NULL AS INT)
	,[intContractDetailId]	= IP.[intContractDetailId]	--CAST(NULL AS INT) 
	,[strContractNumber]	= IP.[strContractNumber]	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]		= IP.[intContractSeq]		--CAST(NULL AS INT)
	,[dblAvailableQty]		= IP.[dblAvailableQty]		--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]		= IP.[ysnUnlimitedQty]		--CAST(NULL AS BIT)
	,[strPricingType]		= IP.[strPricingType]		--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSort]				= IP.[intSort]				--CAST(NULL AS INT)
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
CROSS APPLY
	dbo.[fnARGetItemPricingDetails](
		 ARID.[intItemId]			--@ItemId
		,ARI.[intEntityCustomerId]	--@CustomerId
		,ARI.[intCompanyLocationId]	--@LocationId
		,ARID.[intItemUOMId]		--@ItemUOMId
		,ARI.[dtmDate]				--@TransactionDate
		,ARID.[dblQtyShipped]		--@Quantity
		,NULL						--@ContractHeaderId
		,NULL						--@ContractDetailId
		,NULL						--@ContractNumber
		,NULL						--@ContractSeq
		,NULL						--@AvailableQuantity
		,0							--@UnlimitedQuantity
		,0							--@OriginalQuantity
		,0							--@CustomerPricingOnly
		,0							--@ItemPricingOnly
		,0							--@ExcludeContractPricing
		,NULL						--@VendorId
		,NULL						--@SupplyPointId
		,NULL						--@LastCost
		,ARI.[intShipToLocationId]	--@ShipToLocationId
		,NULL						--@VendorLocationId
		,NULL						--@PricingLevelId
		,NULL						--@AllowQtyToExceed
		,ARI.[strType]				--@InvoiceType
		,ARI.[intTermId]			--@TermId
		,1							--@GetAllAvailablePricing
		) AS IP
		
UNION ALL

SELECT
	 [strTransactionNumber]	= SO.[strSalesOrderNumber]	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intEntityCustomerId]	= SO.[intEntityCustomerId]	--CAST(NULL AS INT)
	,[intItemId]			= SOSOD.[intItemId]			--CAST(NULL AS INT)
	,[dblPrice]				= IP.[dblPrice]				--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]		= IP.[dblTermDiscount]		--CAST(0 AS NUMERIC(18,6))
	,[strPricing]			= IP.[strPricing]			--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]			= IP.[dblDeviation]			--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]	= IP.[intContractHeaderId]	--CAST(NULL AS INT)
	,[intContractDetailId]	= IP.[intContractDetailId]	--CAST(NULL AS INT) 
	,[strContractNumber]	= IP.[strContractNumber]	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]		= IP.[intContractSeq]		--CAST(NULL AS INT)
	,[dblAvailableQty]		= IP.[dblAvailableQty]		--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]		= IP.[ysnUnlimitedQty]		--CAST(NULL AS BIT)
	,[strPricingType]		= IP.[strPricingType]		--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSort]				= IP.[intSort]				--CAST(NULL AS INT)
FROM
	tblSOSalesOrderDetail SOSOD
INNER JOIN
	tblSOSalesOrder SO
		ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]
CROSS APPLY
	dbo.[fnARGetItemPricingDetails](
		 SOSOD.[intItemId]			--@ItemId
		,SO.[intEntityCustomerId]	--@CustomerId
		,SO.[intCompanyLocationId]	--@LocationId
		,SOSOD.[intItemUOMId]		--@ItemUOMId
		,SO.[dtmDate]				--@TransactionDate
		,SOSOD.[dblQtyOrdered] 		--@Quantity
		,NULL						--@ContractHeaderId
		,NULL						--@ContractDetailId
		,NULL						--@ContractNumber
		,NULL						--@ContractSeq
		,NULL						--@AvailableQuantity
		,0							--@UnlimitedQuantity
		,0							--@OriginalQuantity
		,0							--@CustomerPricingOnly
		,0							--@ItemPricingOnly
		,0							--@ExcludeContractPricing
		,NULL						--@VendorId
		,NULL						--@SupplyPointId
		,NULL						--@LastCost
		,SO.[intShipToLocationId]	--@ShipToLocationId
		,NULL						--@VendorLocationId
		,NULL						--@PricingLevelId
		,NULL						--@AllowQtyToExceed
		,SO.[strType]				--@InvoiceType
		,SO.[intTermId]				--@TermId
		,1							--@GetAllAvailablePricing
		) AS IP

