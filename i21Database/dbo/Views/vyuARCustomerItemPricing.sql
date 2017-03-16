CREATE VIEW [dbo].[vyuARCustomerItemPricing]
AS
--Current Selected - Invoice
SELECT
	 [strTransactionNumber]		= ARI.[strInvoiceNumber]									--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intTransactionId]			= ARI.[intInvoiceId]										--CAST(NULL AS INT)
	,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]									--CAST(NULL AS INT)
	,[intEntityCustomerId]		= ARI.[intEntityCustomerId]									--CAST(NULL AS INT)
	,[intItemId]				= ARID.[intItemId]											--CAST(NULL AS INT)
	,[dblPrice]					= ARID.[dblPrice]											--CAST(0 AS NUMERIC(18,6))
	,[dblOriginalPrice]			= ISNULL(ARPH.[dblOriginalPrice],0)									--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]			= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[strTermDiscountBy]		= CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[strPricing]				= ARPH.[strPricing]            COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[strOriginalPricing]		= ARPH.[strOriginalPricing]	   COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]				= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]		= ARID.[intContractHeaderId]								--CAST(NULL AS INT)
	,[intContractDetailId]		= ARID.[intContractDetailId]								--CAST(NULL AS INT) 
	,[strContractNumber]		= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]			= CAST(NULL AS INT)											--CAST(NULL AS INT)
	,[dblAvailableQty]			= CAST(NULL AS NUMERIC(18,6))								--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]			= CAST(NULL AS BIT)											--CAST(NULL AS BIT)
	,[strPricingType]			= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSourceTransactionId]	= CAST(2 AS INT)											--CAST(NULL AS INT)
	,[ysnApplied]				= ARPH.[ysnApplied] 										--CAST(NULL AS BIT)
	,[intSort]					= CAST(0 AS INT)											--CAST(NULL AS INT)
	,[intSubCurrencyId]			= ARID.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= ARID.[dblSubCurrencyRate]
	,[strSubCurrency]			= CAST('' AS NVARCHAR(40))
	,[ysnDefaultPricing]		= CAST(0 AS BIT)
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
	tblARPricingHistory ARPH
		ON ARID.[intInvoiceDetailId] = ARPH.[intTransactionDetailId] 
		AND ARI.[intInvoiceId] = ARPH.[intTransactionId]
		AND ARPH.[intSourceTransactionId] = 2
		AND ARPH.[ysnApplied] = 1
		AND ARPH.[ysnDeleted] = 0

UNION ALL

--Original Pricing - Invoice
SELECT
	 [strTransactionNumber]		= ARI.[strInvoiceNumber]									--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intTransactionId]			= ARI.[intInvoiceId]										--CAST(NULL AS INT)
	,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]									--CAST(NULL AS INT)
	,[intEntityCustomerId]		= ARI.[intEntityCustomerId]									--CAST(NULL AS INT)
	,[intItemId]				= ARID.[intItemId]											--CAST(NULL AS INT)
	,[dblPrice]					= ARID.[dblPrice]											--CAST(0 AS NUMERIC(18,6))
	,[dblOriginalPrice]			= ISNULL(ARPH.[dblOriginalPrice],0)									--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]			= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[strTermDiscountBy]		= CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[strPricing]				= ARPH.[strPricing]            COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[strOriginalPricing]		= ARPH.[strOriginalPricing]	   COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]				= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]		= ARID.[intContractHeaderId]								--CAST(NULL AS INT)
	,[intContractDetailId]		= ARID.[intContractDetailId]								--CAST(NULL AS INT) 
	,[strContractNumber]		= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]			= CAST(NULL AS INT)											--CAST(NULL AS INT)
	,[dblAvailableQty]			= CAST(NULL AS NUMERIC(18,6))								--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]			= CAST(NULL AS BIT)											--CAST(NULL AS BIT)
	,[strPricingType]			= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSourceTransactionId]	= CAST(2 AS INT)											--CAST(NULL AS INT)
	,[ysnApplied]				= CAST(0 AS BIT)											--CAST(NULL AS BIT)
	,[intSort]					= CAST(0 AS INT)											--CAST(NULL AS INT)
	,[intSubCurrencyId]			= ARID.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= ARID.[dblSubCurrencyRate]
	,[strSubCurrency]			= CAST('' AS NVARCHAR(40))
	,[ysnDefaultPricing]		= CAST(1 AS BIT)
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
	tblARPricingHistory ARPH
		ON ARID.[intInvoiceDetailId] = ARPH.[intTransactionDetailId] 
		AND ARI.[intInvoiceId] = ARPH.[intTransactionId]
		AND ARPH.[intSourceTransactionId] = 2
		AND ARPH.[ysnDeleted] = 0
WHERE
	ARPH.[intPricingHistoryId] =	(
										SELECT MIN(ARPH1.intPricingHistoryId) 
										FROM 
											tblARPricingHistory ARPH1 
										WHERE 
											ARPH1.[intTransactionId] = ARPH.[intTransactionId] 
											AND ARPH1.[intTransactionDetailId] = ARPH.[intTransactionDetailId] 
											AND ARPH1.[intSourceTransactionId] = ARPH.[intSourceTransactionId]
										GROUP BY
											 ARPH1.[intSourceTransactionId]
											,ARPH1.[intTransactionId]										
									)


UNION ALL

--Available Pricing - Invoice
SELECT
	 [strTransactionNumber]		= ARI.[strInvoiceNumber]	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intTransactionId]			= ARI.[intInvoiceId]		--CAST(NULL AS INT)
	,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]	--CAST(NULL AS INT)
	,[intEntityCustomerId]		= ARI.[intEntityCustomerId]	--CAST(NULL AS INT)
	,[intItemId]				= ARID.[intItemId]			--CAST(NULL AS INT)
	,[dblPrice]					= IP.[dblPrice]				--CAST(0 AS NUMERIC(18,6))
	,[dblOriginalPrice]			= ISNULL(ARID.[dblPrice],0)	--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]			= IP.[dblTermDiscount]		--CAST(0 AS NUMERIC(18,6))
	,[strTermDiscountBy]		= IP.[strTermDiscountBy] 	--CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[strPricing]				= IP.[strPricing]			--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[strOriginalPricing]		= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]				= IP.[dblDeviation]			--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]		= IP.[intContractHeaderId]	--CAST(NULL AS INT)
	,[intContractDetailId]		= IP.[intContractDetailId]	--CAST(NULL AS INT) 
	,[strContractNumber]		= IP.[strContractNumber]	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]			= IP.[intContractSeq]		--CAST(NULL AS INT)
	,[dblAvailableQty]			= IP.[dblAvailableQty]		--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]			= IP.[ysnUnlimitedQty]		--CAST(NULL AS BIT)
	,[strPricingType]			= IP.[strPricingType]		--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSourceTransactionId]	= CAST(2 AS INT)			--CAST(NULL AS INT)
	,[ysnApplied]				= CAST(0 AS BIT)			--CAST(NULL AS BIT)
	,[intSort]					= IP.[intSort]				--CAST(NULL AS INT)
	,[intSubCurrencyId]			= IP.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= IP.[dblSubCurrencyRate]
	,[strSubCurrency]			= IP.[strSubCurrency]
	,[ysnDefaultPricing]		= CAST(0 AS BIT)
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
		,ISNULL(ARI.intCurrencyId, (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference))		--@CurrencyId
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
WHERE
	NOT EXISTS(	SELECT TOP 1 NULL 
				FROM tblARPricingHistory ARPH 
				WHERE
					ARID.[intInvoiceDetailId] = ARPH.[intTransactionDetailId] 
					AND ARI.[intInvoiceId] = ARPH.[intTransactionId]
					AND ARID.[dblPrice] = IP.[dblPrice] 
					AND ARID.[strPricing] = IP.[strPricing] COLLATE Latin1_General_CI_AS
					AND ARPH.[intSourceTransactionId] = 2
					AND ARPH.[ysnApplied] = 1
					AND ARPH.[ysnDeleted] = 0 
				ORDER BY ARPH.[ysnApplied] DESC)

UNION ALL
--Current Selected - Sales Order
SELECT
	 [strTransactionNumber]		= SO.[strSalesOrderNumber]									--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intTransactionId]			= SO.[intSalesOrderId]										--CAST(NULL AS INT)
	,[intTransactionDetailId]	= SOSOD.[intSalesOrderDetailId]								--CAST(NULL AS INT)
	,[intEntityCustomerId]		= SO.[intEntityCustomerId]									--CAST(NULL AS INT)
	,[intItemId]				= SOSOD.[intItemId]											--CAST(NULL AS INT)
	,[dblPrice]					= SOSOD.[dblPrice]											--CAST(0 AS NUMERIC(18,6))
	,[dblOriginalPrice]			= ISNULL(ARPH.[dblOriginalPrice],0)									--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]			= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[strTermDiscountBy]		= CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[strPricing]				= ARPH.[strPricing]			   COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[strOriginalPricing]		= ARPH.[strOriginalPricing]	   COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]				= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]		= SOSOD.[intContractHeaderId]								--CAST(NULL AS INT)
	,[intContractDetailId]		= SOSOD.[intContractDetailId]								--CAST(NULL AS INT) 
	,[strContractNumber]		= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]			= CAST(NULL AS INT)											--CAST(NULL AS INT)
	,[dblAvailableQty]			= CAST(NULL AS NUMERIC(18,6))								--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]			= CAST(NULL AS BIT)											--CAST(NULL AS BIT)
	,[strPricingType]			= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSourceTransactionId]	= CAST(1 AS INT)											--CAST(NULL AS INT)
	,[ysnApplied]				= ARPH.[ysnApplied] 										--CAST(NULL AS BIT)
	,[intSort]					= CAST(0 AS INT)											--CAST(NULL AS INT)
	,[intSubCurrencyId]			= SOSOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= SOSOD.[dblSubCurrencyRate]
	,[strSubCurrency]			= CAST('' AS NVARCHAR(40))
	,[ysnDefaultPricing]		= CAST(0 AS BIT)
FROM
	tblSOSalesOrderDetail SOSOD
INNER JOIN
	tblSOSalesOrder SO
		ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]
INNER JOIN
	tblARPricingHistory ARPH
		ON SOSOD.[intSalesOrderDetailId] = ARPH.[intTransactionDetailId] 
		AND SO.[intSalesOrderId] = ARPH.[intTransactionId]
		AND ARPH.[intSourceTransactionId] = 1
		AND ARPH.[ysnApplied] = 1
		AND ARPH.[ysnDeleted] = 0

UNION ALL
--Original Pricing - Sales Order
SELECT
	 [strTransactionNumber]		= SO.[strSalesOrderNumber]									--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intTransactionId]			= SO.[intSalesOrderId]										--CAST(NULL AS INT)
	,[intTransactionDetailId]	= SOSOD.[intSalesOrderDetailId]								--CAST(NULL AS INT)
	,[intEntityCustomerId]		= SO.[intEntityCustomerId]									--CAST(NULL AS INT)
	,[intItemId]				= SOSOD.[intItemId]											--CAST(NULL AS INT)
	,[dblPrice]					= SOSOD.[dblPrice]											--CAST(0 AS NUMERIC(18,6))
	,[dblOriginalPrice]			= ISNULL(ARPH.[dblOriginalPrice],0)									--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]			= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[strTermDiscountBy]		= CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[strPricing]				= ARPH.[strPricing]			   COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[strOriginalPricing]		= ARPH.[strOriginalPricing]	   COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]				= CAST(0 AS NUMERIC(18,6))									--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]		= SOSOD.[intContractHeaderId]								--CAST(NULL AS INT)
	,[intContractDetailId]		= SOSOD.[intContractDetailId]								--CAST(NULL AS INT) 
	,[strContractNumber]		= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]			= CAST(NULL AS INT)											--CAST(NULL AS INT)
	,[dblAvailableQty]			= CAST(NULL AS NUMERIC(18,6))								--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]			= CAST(NULL AS BIT)											--CAST(NULL AS BIT)
	,[strPricingType]			= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSourceTransactionId]	= CAST(1 AS INT)											--CAST(NULL AS INT)
	,[ysnApplied]				= ARPH.[ysnApplied] 										--CAST(NULL AS BIT)
	,[intSort]					= CAST(0 AS INT)											--CAST(NULL AS INT)
	,[intSubCurrencyId]			= SOSOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= SOSOD.[dblSubCurrencyRate]
	,[strSubCurrency]			= CAST('' AS NVARCHAR(40))
	,[ysnDefaultPricing]		= CAST(1 AS BIT)
FROM
	tblSOSalesOrderDetail SOSOD
INNER JOIN
	tblSOSalesOrder SO
		ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]
INNER JOIN
	tblARPricingHistory ARPH
		ON SOSOD.[intSalesOrderDetailId] = ARPH.[intTransactionDetailId] 
		AND SO.[intSalesOrderId] = ARPH.[intTransactionId]
		AND ARPH.[intSourceTransactionId] = 1
		AND ARPH.[ysnDeleted] = 0
WHERE
	ARPH.[intPricingHistoryId] =	(
										SELECT MIN(ARPH1.intPricingHistoryId)
										FROM 
											tblARPricingHistory ARPH1 
										WHERE 
											ARPH1.[intTransactionId] = ARPH.[intTransactionId] 
											AND ARPH1.[intTransactionDetailId] = ARPH.[intTransactionDetailId] 
											AND ARPH1.[intSourceTransactionId] = ARPH.[intSourceTransactionId]
										GROUP BY
											 ARPH1.[intSourceTransactionId]
											,ARPH1.[intTransactionId]
									)

UNION ALL
--Available Pricing - Sales Order
SELECT
	 [strTransactionNumber]		= SO.[strSalesOrderNumber]		--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	
	,[intTransactionId]			= SO.[intSalesOrderId] 			--CAST(NULL AS INT)
	,[intTransactionDetailId]	= SOSOD.[intSalesOrderDetailId]	--CAST(NULL AS INT)
	,[intEntityCustomerId]		= SO.[intEntityCustomerId]		--CAST(NULL AS INT)
	,[intItemId]				= SOSOD.[intItemId]				--CAST(NULL AS INT)
	,[dblPrice]					= IP.[dblPrice]					--CAST(0 AS NUMERIC(18,6))
	,[dblOriginalPrice]			= ISNULL(SOSOD.[dblPrice],0)		--CAST(0 AS NUMERIC(18,6))
	,[dblTermDiscount]			= IP.[dblTermDiscount]			--CAST(0 AS NUMERIC(18,6))
	,[strTermDiscountBy]		= IP.[strTermDiscountBy] 	--CAST(NULL AS  NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[strPricing]				= IP.[strPricing]				--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[strOriginalPricing]		= CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS	--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblDeviation]				= IP.[dblDeviation]				--CAST(0 AS NUMERIC(18,6))
	,[intContractHeaderId]		= IP.[intContractHeaderId]		--CAST(NULL AS INT)
	,[intContractDetailId]		= IP.[intContractDetailId]		--CAST(NULL AS INT) 
	,[strContractNumber]		= IP.[strContractNumber]		--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intContractSeq]			= IP.[intContractSeq]			--CAST(NULL AS INT)
	,[dblAvailableQty]			= IP.[dblAvailableQty]			--CAST(NULL AS NUMERIC(18,6))
	,[ysnUnlimitedQty]			= IP.[ysnUnlimitedQty]			--CAST(NULL AS BIT)
	,[strPricingType]			= IP.[strPricingType]			--CAST(NULL AS  NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intSourceTransactionId]	= CAST(1 AS INT)				--CAST(NULL AS INT)
	,[ysnApplied]				= CAST(0 AS BIT)				--CAST(NULL AS BIT)
	,[intSort]					= IP.[intSort]					--CAST(NULL AS INT)
	,[intSubCurrencyId]			= IP.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= IP.[dblSubCurrencyRate]
	,[strSubCurrency]			= IP.[strSubCurrency]
	,[ysnDefaultPricing]		= CAST(0 AS BIT)
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
		,SO.[intCurrencyId]			--@CurrencyId
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
WHERE
	NOT EXISTS(	SELECT TOP 1 NULL 
				FROM tblARPricingHistory ARPH 
				WHERE
					SOSOD.[intSalesOrderDetailId] = ARPH.[intTransactionDetailId] 
					AND SO.[intSalesOrderId] = ARPH.[intTransactionId]
					AND SOSOD.[dblPrice] = IP.[dblPrice] 
					AND SOSOD.[strPricing] = IP.[strPricing] COLLATE Latin1_General_CI_AS
					AND ARPH.[intSourceTransactionId] = 1
					AND ARPH.[ysnApplied] = 1
					AND ARPH.[ysnDeleted] = 0
				ORDER BY ARPH.[ysnApplied] DESC)