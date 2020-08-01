CREATE PROCEDURE [dbo].[uspARPopulateItemsForInTransitCosting]

AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
DECLARE	@AVERAGECOST AS INT	= 1

SELECT	@INVENTORY_INVOICE_TYPE = [intTransactionTypeId] 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	[strName] = 'Invoice'

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000			

INSERT INTO #ARItemsForInTransitCosting
	([intItemId] 
	,[intItemLocationId] 
	,[intItemUOMId] 
	,[dtmDate] 
	,[dblQty] 
	,[dblUOMQty] 
	,[dblCost] 
	,[dblValue] 
	,[dblSalesPrice] 
	,[intCurrencyId] 
	,[dblExchangeRate] 
	,[intTransactionId] 
	,[intTransactionDetailId] 
	,[strTransactionId] 
	,[intTransactionTypeId] 
	,[intLotId] 
	,[intSourceTransactionId] 
	,[strSourceTransactionId] 
	,[intSourceTransactionDetailId] 
	,[intFobPointId] 
	,[intInTransitSourceLocationId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intLinkedItem])
--INVENTORY SHIPMENT NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= - ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ISNULL(ARID.[dblQtyShipped], ICS.dblQuantity)), @ZeroDecimal)  --ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ISNULL(ARID.[intLotId], ICIT.[intLotId])
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.intChildItemLinkId
		 , ICISI.dblQuantity  
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
CROSS APPLY (
	SELECT TOP 1 IT.* 
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = ICS.[intInventoryShipmentId] 
	  AND IT.[strTransactionId] = ICS.[strShipmentNumber] 
	  AND IT.[intTransactionDetailId] = ICS.[intInventoryShipmentItemId]
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0			 
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0 
) ICIT
LEFT JOIN (
	SELECT [intInvoiceDetailLotId]
		 , [intInvoiceDetailId]
		 , [dblQuantityShipped]
	FROM tblARInvoiceDetailLot ARIDL
) ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ISNULL(ARID.[intLoadDetailId], 0) = 0
    AND ARID.[intTicketId] IS NULL
	AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
	AND ARID.[strTransactionType] <> 'Credit Memo'
    AND ISNULL(ARIDL.[intInvoiceDetailLotId],0) = 0
	
UNION ALL

--INVENTORY SHIPMENT LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= - ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ISNULL(ARID.[intLotId], ICIT.[intLotId])
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.intChildItemLinkId
		 , ICISI.dblQuantity  
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICS.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[ysnIsUnposted] = 0
OUTER APPLY (
	SELECT TOP 1 [intInvoiceDetailLotId]
			   , [intInvoiceDetailId]
			   , [dblQuantityShipped]
	FROM tblARInvoiceDetailLot ARIDL
	WHERE ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
) ARIDL
WHERE ISNULL(ARID.[intLoadDetailId], 0) = 0
  AND ARID.[intTicketId] IS NULL
  AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0
  AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND ARID.[strTransactionType] <> 'Credit Memo'
  AND ISNULL(ARIDL.[intInvoiceDetailLotId],0) <> 0
	
UNION ALL

--SCALE TICKET NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ISNULL(ARID.[intLotId], ICIT.[intLotId])
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.[intChildItemLinkId]
		 , ICISI.[intDestinationWeightId]
		 , ICISI.[ysnDestinationWeightsAndGrades]
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICS.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[ysnIsUnposted] = 0
										 AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0 
LEFT JOIN (
	SELECT [intInvoiceDetailLotId]
		 , [intInvoiceDetailId]
	FROM tblARInvoiceDetailLot ARIDL	
) ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ISNULL(ARID.[intLoadDetailId], 0) = 0
  AND ARID.[intTicketId] IS NOT NULL
  AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND ARID.[strTransactionType] <> 'Credit Memo'
  AND ISNULL(ARIDL.[intInvoiceDetailLotId],0) = 0

UNION ALL

--SCALE TICKET LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ISNULL(ARID.[intLotId], ICIT.[intLotId])
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.[intChildItemLinkId]
		 , ICISI.[intDestinationWeightId]
		 , ICISI.[intDestinationGradeId]
		 , ICISI.[ysnDestinationWeightsAndGrades]
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN (
	SELECT[intInvoiceDetailLotId]
		, [intInvoiceDetailId]
		, [dblQuantityShipped]
		, [intLotId]
	FROM tblARInvoiceDetailLot ARIDL		
) ARIDL	ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICS.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[ysnIsUnposted] = 0
										 AND ICIT.[intLotId] = ARIDL.[intLotId]
										 AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0 
WHERE ISNULL(ARID.[intLoadDetailId], 0) = 0
  AND ARID.[intTicketId] IS NOT NULL
  AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND ARID.[strTransactionType] <> 'Credit Memo'

UNION ALL

--LOADSHIPMENT NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= - ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ICIT.[intItemUOMId], ARID.[dblShipmentNetWt]), @ZeroDecimal) --ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ISNULL(ARID.[intLotId], ICIT.[intLotId])
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT LGD.[intLoadId]
		 , LGD.[intLoadDetailId]
		 , LGD.[intSCompanyLocationId] 
		 , LGL.[intPurchaseSale]
		 , LGL.[strLoadNumber]
	FROM tblLGLoadDetail LGD WITH (NOLOCK) 
	INNER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGD.[intLoadId] = LGL.[intLoadId] 
) LG ON LG.[intLoadDetailId] = ARID.[intLoadDetailId]
CROSS APPLY (
	SELECT TOP 1 IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = LG.[intLoadId] 
	  AND IT.[intTransactionDetailId] = LG.[intLoadDetailId] 
	  AND IT.[strTransactionId] = LG.[strLoadNumber] 			 
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0
) ICIT
LEFT JOIN (
	SELECT [intInvoiceDetailLotId]
		 , [intInvoiceDetailId]
		 , [dblQuantityShipped]
	FROM tblARInvoiceDetailLot ARIDL
) ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
LEFT JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.intChildItemLinkId  
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
	AND ISNULL(LG.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ICS.[intInventoryShipmentItemId], 0) = 0
	AND ARID.[strTransactionType] <> 'Credit Memo'
    AND ARID.[intTicketId] IS NULL
    AND ISNULL(ARIDL.[intInvoiceDetailLotId],0) = 0    

UNION ALL

--LOADSHIPMENT LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= CASE WHEN ARID.[strTransactionType] IN ('Credit Memo', 'Credit Note') THEN ICIT.[dblQty] ELSE -ICIT.[dblQty] END--ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ICIT.[intItemUOMId], ARID.[dblShipmentNetWt]), @ZeroDecimal)
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT LGD.[intLoadId]
		 , LGD.[intLoadDetailId]
		 , LGD.[intSCompanyLocationId] 
		 , LGL.[intPurchaseSale]
		 , LGL.[strLoadNumber]
	FROM tblLGLoadDetail LGD WITH (NOLOCK) 
	INNER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGD.[intLoadId] = LGL.[intLoadId] 
) LG ON LG.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN (
	SELECT[intInvoiceDetailLotId]
		, [intInvoiceDetailId]
		, [dblQuantityShipped]
		, [intLotId]
	FROM tblARInvoiceDetailLot ARIDL		
) ARIDL	ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN (
	SELECT IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0	  
) ICIT ON ICIT.[intTransactionId] = LG.[intLoadId] 
	  AND ICIT.[intTransactionDetailId] = LG.[intLoadDetailId] 
	  AND ICIT.[strTransactionId] = LG.[strLoadNumber]
	  AND ICIT.[intItemId] = ARID.[intItemId]
	  AND ICIT.[intLotId] = ARIDL.[intLotId]
LEFT JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.intChildItemLinkId  
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
	AND ISNULL(LG.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ICS.[intInventoryShipmentItemId], 0) = 0
	AND ARID.[strTransactionType] <> 'Credit Memo'

UNION ALL

--LOADSHIPMENT RETURN NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= - ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ICIT.[intItemUOMId], ARID.[dblShipmentNetWt]), @ZeroDecimal) --ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ISNULL(ARID.[intLotId], ICIT.[intLotId])
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= NULL
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT LGD.[intLoadId]
		 , LGD.[intLoadDetailId]
		 , LGD.[intSCompanyLocationId] 
		 , LGL.[intPurchaseSale]
		 , LGL.[strLoadNumber]
	FROM tblLGLoadDetail LGD WITH (NOLOCK) 
	INNER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGD.[intLoadId] = LGL.[intLoadId] 
) LG ON LG.[intLoadDetailId] = ARID.[intLoadDetailId]
LEFT JOIN (
	SELECT [intInvoiceDetailLotId]
		 , [intInvoiceDetailId]
	FROM tblARInvoiceDetailLot ARIDL
) ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN (
	SELECT I.intInvoiceId 
	     , I.strInvoiceNumber
		 , ID.intInvoiceDetailId
		 , ID.intItemId
	FROM tblARInvoice I WITH (NOLOCK)
	INNER JOIN tblARInvoiceDetail ID WITH (NOLOCK) ON I.intInvoiceId = ID.intInvoiceId
	WHERE I.ysnReturned = 1 
	  AND I.ysnPosted = 1 
	  AND I.strTransactionType = 'Invoice'
) ARRETURN ON ARID.[intOriginalInvoiceId] = ARRETURN.[intInvoiceId]
INNER JOIN (
	SELECT IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0
) ICIT ON ICIT.[intTransactionId] = ARRETURN.[intInvoiceId] 
	  AND ICIT.[intTransactionDetailId] = ARRETURN.[intInvoiceDetailId] 
	  AND ICIT.[strTransactionId] = ARRETURN.[strInvoiceNumber] 			 
	  AND ICIT.[intItemId] = ARRETURN.[intItemId]
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
	AND ISNULL(LG.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	AND ARID.[strTransactionType] = 'Credit Memo'
    AND ARID.[intTicketId] IS NULL
    AND ISNULL(ARIDL.[intInvoiceDetailLotId],0) = 0    

UNION ALL

--LOADSHIPMENT RETURN LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -CASE WHEN ARID.[strTransactionType] IN ('Credit Memo', 'Credit Note') THEN ICIT.[dblQty] ELSE -ICIT.[dblQty] END
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= NULL
FROM #ARPostInvoiceDetail ARID
INNER JOIN (	
	SELECT LGD.[intLoadId]
		 , LGD.[intLoadDetailId]
		 , LGD.[intSCompanyLocationId] 
		 , LGL.[intPurchaseSale]
		 , LGL.[strLoadNumber]
	FROM tblLGLoadDetail LGD WITH (NOLOCK) 
	INNER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGD.[intLoadId] = LGL.[intLoadId] 
) LG ON LG.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN (
	SELECT I.intInvoiceId
		 , I.strInvoiceNumber
		 , ID.intInvoiceDetailId
		 , ID.intItemId
		 , IDL.intLotId
	FROM tblARInvoice I WITH (NOLOCK)
	INNER JOIN tblARInvoiceDetail ID WITH (NOLOCK) ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblARInvoiceDetailLot IDL WITH (NOLOCK) ON ID.intInvoiceDetailId = IDL.intInvoiceDetailId
	WHERE I.ysnReturned = 1 
	  AND I.ysnPosted = 1 
	  AND I.strTransactionType = 'Invoice'
) ARRETURN ON ARID.[intOriginalInvoiceId] = ARRETURN.[intInvoiceId]
INNER JOIN (
	SELECT IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0	  
) ICIT ON ICIT.[intTransactionId] = ARRETURN.[intInvoiceId] 
	  AND ICIT.[intTransactionDetailId] = ARRETURN.[intInvoiceDetailId]
	  AND ICIT.[strTransactionId] = ARRETURN.[strInvoiceNumber]
	  AND ICIT.[intItemId] = ARRETURN.[intItemId]
	  AND ICIT.[intLotId] = ARRETURN.[intLotId]
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
	AND ISNULL(LG.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	AND ARID.[strTransactionType] = 'Credit Memo'

UNION ALL

--LOADSHIPMENT LOTTED (PROVISIONAL INVOICE REVERSAL)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM 
(SELECT 
	INVD.intInvoiceId
	, INVD.intLoadDetailId
	, INVD.intInvoiceDetailId
	, INVD.intItemId
	, INVD.intInventoryShipmentItemId
	, ARPID.dtmPostDate
	, ARPID.dtmShipDate 
	, ARPID.strTransactionType
	, INVD.dblPrice
	, ARPID.intCurrencyId
	, ARPID.strInvoiceNumber
	, INVD.intCurrencyExchangeRateTypeId
	, INVD.dblCurrencyExchangeRate
	, ARPID.intSourceId
FROM tblARInvoiceDetail INVD
INNER JOIN #ARPostInvoiceDetail ARPID
ON INVD.intInvoiceDetailId = ARPID.intOriginalInvoiceDetailId
AND INVD.dblQtyShipped <> ARPID.dblQtyShipped) ARID
INNER JOIN (	
	SELECT LGD.[intLoadId]
		 , LGD.[intLoadDetailId]
		 , LGD.[intSCompanyLocationId] 
		 , LGL.[intPurchaseSale]
		 , LGL.[strLoadNumber]
	FROM tblLGLoadDetail LGD WITH (NOLOCK) 
	INNER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGD.[intLoadId] = LGL.[intLoadId] 
) LG ON LG.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN (
	SELECT[intInvoiceDetailLotId]
		, [intInvoiceDetailId]
		, [dblQuantityShipped]
		, [intLotId]
	FROM tblARInvoiceDetailLot ARIDL		
) ARIDL	ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN (
	SELECT IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0	  
) ICIT ON ICIT.[intTransactionId] = LG.[intLoadId] 
	  AND ICIT.[intTransactionDetailId] = LG.[intLoadDetailId] 
	  AND ICIT.[strTransactionId] = LG.[strLoadNumber]
	  AND ICIT.[intItemId] = ARID.[intItemId]
	  AND ICIT.[intLotId] = ARIDL.[intLotId]
LEFT JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.intChildItemLinkId  
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
WHERE ARID.[intSourceId] = 2

UNION ALL

--LOADSHIPMENT LOTTED (FINAL INVOICE)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICS.intChildItemLinkId
FROM 
(SELECT 
	ARPID.intInvoiceId
	, ARPID.intLoadDetailId
	, ARPID.intInvoiceDetailId
	, INVD.intItemId
	, INVD.intInventoryShipmentItemId
	, ARPID.dtmPostDate
	, ARPID.dtmShipDate 
	, ARPID.strTransactionType
	, INVD.dblPrice
	, ARPID.intCurrencyId
	, ARPID.strInvoiceNumber
	, INVD.intCurrencyExchangeRateTypeId
	, INVD.dblCurrencyExchangeRate
	, ARPID.intSourceId
FROM tblARInvoiceDetail INVD
INNER JOIN #ARPostInvoiceDetail ARPID
ON INVD.intInvoiceDetailId = ARPID.intOriginalInvoiceDetailId
AND INVD.dblQtyShipped <> ARPID.dblQtyShipped) ARID
INNER JOIN (	
	SELECT LGD.[intLoadId]
		 , LGD.[intLoadDetailId]
		 , LGD.[intSCompanyLocationId] 
		 , LGL.[intPurchaseSale]
		 , LGL.[strLoadNumber]
	FROM tblLGLoadDetail LGD WITH (NOLOCK) 
	INNER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGD.[intLoadId] = LGL.[intLoadId] 
) LG ON LG.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN (
	SELECT[intInvoiceDetailLotId]
		, [intInvoiceDetailId]
		, [dblQuantityShipped]
		, [intLotId]
	FROM tblARInvoiceDetailLot ARIDL		
) ARIDL	ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN (
	SELECT IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0	  
) ICIT ON ICIT.[intTransactionId] = LG.[intLoadId] 
	  AND ICIT.[intTransactionDetailId] = LG.[intLoadDetailId] 
	  AND ICIT.[strTransactionId] = LG.[strLoadNumber]
	  AND ICIT.[intItemId] = ARID.[intItemId]
	  AND ICIT.[intLotId] = ARIDL.[intLotId]
LEFT JOIN (	
	SELECT ICIS.[intInventoryShipmentId]		
		 , ICIS.[strShipmentNumber]		
		 , ICISI.[intInventoryShipmentItemId]
		 , ICISI.intChildItemLinkId  
	FROM tblICInventoryShipmentItem ICISI WITH (NOLOCK)  
	INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
) ICS ON ICS.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
WHERE ARID.[intSourceId] = 2

UPDATE A 
SET intLinkedItemId = B.intItemId
FROM #ARItemsForInTransitCosting A
JOIN tblICInventoryShipmentItem B ON A.intLinkedItem = B.intParentItemLinkId
WHERE A.intLinkedItem IS NOT NULL

SELECT * FROM #ARItemsForInTransitCosting

RETURN 1
