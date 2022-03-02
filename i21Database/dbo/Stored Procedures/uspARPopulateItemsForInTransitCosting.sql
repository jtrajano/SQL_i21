CREATE PROCEDURE [dbo].[uspARPopulateItemsForInTransitCosting]

AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @FOB_ORIGIN				AS INT = 1
	  , @FOB_DESTINATION		AS INT = 2
	  , @INVENTORY_INVOICE_TYPE AS INT = 33
	  , @AVERAGECOST			AS INT	= 1
	  , @ZeroDecimal			DECIMAL(18,6) = 0

SELECT TOP 1 @INVENTORY_INVOICE_TYPE = [intTransactionTypeId] 
FROM tblICInventoryTransactionType WITH (NOLOCK)
WHERE [strName] = 'Invoice'
ORDER BY intTransactionTypeId

INSERT INTO ##ARItemsForInTransitCosting WITH (TABLOCK)
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
	,[intLinkedItem]
	,[strBOLNumber]
	,[intTicketId]
    ,[intSourceEntityId]
)
--INVENTORY SHIPMENT NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ISNULL(ARID.[dblQtyShipped], ICISI.dblQuantity)), @ZeroDecimal) * (CASE WHEN ARID.strTransactionType = 'Credit Memo' THEN 1 ELSE -1 END)
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
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
CROSS APPLY (
	SELECT TOP 1 IT.* 
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
	  AND IT.[strTransactionId] = ICIS.[strShipmentNumber] 
	  AND IT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0			 
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0 
) ICIT
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ARID.[intLoadDetailId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND ARID.[strTransactionType] <> 'Credit Memo'
  AND ARIDL.[intInvoiceDetailLotId] IS NULL
	
UNION ALL

--INVENTORY SHIPMENT LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	--,[dblQty]						= - ROUND(ARIDL.[dblQuantityShipped]/AVGT.dblTotalQty, 2) * ICIT.[dblQty]
	,[dblQty]						= - (CAST(ARIDL.[dblQuantityShipped] AS NUMERIC(18, 10)) / CAST(AVGT.dblTotalQty AS NUMERIC(18, 10))) * CAST(ICIT.[dblQty] AS NUMERIC(18, 10))
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
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICIS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[intLotId] = ARIDL.[intLotId]
										 AND ICIT.[ysnIsUnposted] = 0
INNER JOIN (
	SELECT intTransactionId
		 , strTransactionId
		 , intTransactionDetailId
		 , intItemId
		 , intLotId
		 , dblTotalQty = SUM(dblQty)
	FROM tblICInventoryTransaction ICIT 
	WHERE ICIT.[ysnIsUnposted] = 0
	  AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0
	GROUP BY ICIT.[intTransactionId]
		   , ICIT.[strTransactionId]
		   , ICIT.[intTransactionDetailId]
		   , ICIT.[intItemId]
		   , ICIT.[intLotId]
) AVGT ON AVGT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
      AND AVGT.[strTransactionId] = ICIS.[strShipmentNumber] 
      AND AVGT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
      AND AVGT.[intItemId] = ARID.[intItemId]
      AND AVGT.[intLotId] = ARIDL.[intLotId]
WHERE ARID.[intLoadDetailId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ICIT.[intInTransitSourceLocationId] IS NOT NULL
  AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND ARID.[strTransactionType] <> 'Credit Memo'  
	
UNION ALL

--SCALE TICKET NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	--,[dblQty]                       = - ROUND(ARID.dblQtyShipped/ CASE WHEN ICS.ysnDestinationWeightsAndGrades = 1 THEN ISNULL(ICS.[dblDestinationQuantity], ICS.[dblQuantity]) ELSE ICS.[dblQuantity] END, 2) * ICIT.[dblQty]
	,[dblQty]                       = - (CAST(ARID.dblQtyShipped AS NUMERIC(18, 10))/CAST(CASE WHEN ICISI.ysnDestinationWeightsAndGrades = 1 
										THEN CASE WHEN ICISI.ysnDestinationWeightsAndGrades = 1 AND ICISI.dblDestinationQuantity > CTD.dblQuantity AND CTD.intPricingTypeId = 1 THEN CTD.dblQuantity 
										ELSE ISNULL(ICISI.[dblDestinationQuantity], ICISI.[dblQuantity]) END ELSE ICISI.[dblQuantity] END AS NUMERIC(18, 10))) * CAST(ICIT.[dblQty] AS NUMERIC(18, 10))
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
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblICItem ITEM ON ARID.intItemId = ITEM.intItemId
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICIS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[ysnIsUnposted] = 0
										 AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0 
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
LEFT JOIN(
	SELECT H.intPricingTypeId,D.intContractDetailId,D.dblQuantity  from tblCTContractHeader H
	INNER JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
) CTD ON CTD.intContractDetailId = ARID.intContractDetailId
WHERE ARID.[intLoadDetailId] IS NULL
  AND ARID.[intTicketId] IS NOT NULL
  AND ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND ARID.[strTransactionType] <> 'Credit Memo'
  AND ARIDL.[intInvoiceDetailLotId] IS NULL
  AND (ITEM.strLotTracking IS NULL OR ITEM.strLotTracking = 'No')

UNION ALL

--SCALE TICKET LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	--,[dblQty]						= - ROUND(ARIDL.[dblQuantityShipped]/CASE WHEN ICS.ysnDestinationWeightsAndGrades = 1 THEN ISNULL(ICS.[dblDestinationQuantity], ICS.[dblQuantity]) ELSE ICS.[dblQuantity] END, 2) * ICIT.[dblQty]
	,[dblQty]						= - (CAST(ARIDL.[dblQuantityShipped] AS NUMERIC(18, 10))/CAST(CASE WHEN ICISI.ysnDestinationWeightsAndGrades = 1 THEN ISNULL(ICISI.[dblDestinationQuantity], ICISI.[dblQuantity]) ELSE ICISI.[dblQuantity] END AS NUMERIC(18, 10))) * CAST(ICIT.[dblQty] AS NUMERIC(18, 10))
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
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
INNER JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICIS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[ysnIsUnposted] = 0
										 AND ICIT.[intLotId] = ARIDL.[intLotId]
										 AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0
INNER JOIN (
	SELECT intTransactionId
		 , strTransactionId
		 , intTransactionDetailId
		 , intItemId
		 , intLotId
		 , dblTotalQty = SUM(dblQty)
	FROM tblICInventoryTransaction ICIT 
	WHERE ICIT.[ysnIsUnposted] = 0
	  AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0
	GROUP BY ICIT.[intTransactionId]
		   , ICIT.[strTransactionId]
		   , ICIT.[intTransactionDetailId]
		   , ICIT.[intItemId]
		   , ICIT.[intLotId]
) AVGT ON AVGT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
      AND AVGT.[strTransactionId] = ICIS.[strShipmentNumber] 
      AND AVGT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
      AND AVGT.[intItemId] = ARID.[intItemId]
      AND AVGT.[intLotId] = ARIDL.[intLotId]
WHERE ARID.[intLoadDetailId] IS NULL
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
	,[dblQty]						= - ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ICIT.[intItemUOMId], CASE WHEN ARID.[strType] = 'Provisional' THEN LGD.[dblQuantity] ELSE ARID.[dblShipmentNetWt] END), @ZeroDecimal)
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
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON LGD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN tblLGLoad LG WITH (NOLOCK) ON LGD.[intLoadId] = LG.[intLoadId] 
CROSS APPLY (
	SELECT TOP 1 IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = LG.[intLoadId] 
	  AND IT.[intTransactionDetailId] = LGD.[intLoadDetailId] 
	  AND IT.[strTransactionId] = LG.[strLoadNumber] 			 
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0
) ICIT
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND (LG.[intPurchaseSale] IN (2, 3) AND ARID.[strType] = 'Provisional')
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[strTransactionType] <> 'Credit Memo'
  AND ARID.[intTicketId] IS NULL
  AND ARIDL.[intInvoiceDetailLotId] IS NULL

UNION ALL

--LOADSHIPMENT LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= (CAST(ARIDL.[dblQuantityShipped] AS NUMERIC(25, 13)) / CAST(AVGT.dblTotalQty AS NUMERIC(25, 13))) * ARID.[dblShipmentNetWt] * CASE WHEN ARID.[strTransactionType] IN ('Credit Memo', 'Credit Note') THEN 1 ELSE -1 END
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
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON LGD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN tblLGLoad LG WITH (NOLOCK) ON LGD.[intLoadId] = LG.[intLoadId] 
INNER JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = LG.[intLoadId] 
										 AND ICIT.[intTransactionDetailId] = LGD.[intLoadDetailId] 
										 AND ICIT.[strTransactionId] = LG.[strLoadNumber]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[intLotId] = ARIDL.[intLotId]
										 AND ICIT.[ysnIsUnposted] = 0		
										 AND ICIT.[intInTransitSourceLocationId] IS NOT NULL
INNER JOIN (
	SELECT intTransactionId
		 , strTransactionId
		 , intTransactionDetailId
		 , intItemId
		 , intLotId
		 , dblTotalQty = SUM(dblQty)
	FROM tblICInventoryTransaction ICIT 
	WHERE ICIT.[ysnIsUnposted] = 0
	  AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0
	GROUP BY ICIT.[intTransactionId]
		   , ICIT.[strTransactionId]
		   , ICIT.[intTransactionDetailId]
		   , ICIT.[intItemId]
		   , ICIT.[intLotId]
) AVGT ON AVGT.[intTransactionId] = LG.[intLoadId] 
      AND AVGT.[strTransactionId] = LG.[strLoadNumber] 
      AND AVGT.[intTransactionDetailId] = LGD.[intLoadDetailId]
      AND AVGT.[intItemId] = ARID.[intItemId]
      AND AVGT.[intLotId] = ARIDL.[intLotId]
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
  AND (LG.[intPurchaseSale] IN (2, 3) AND ARID.[strType] = 'Provisional')
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[strTransactionType] <> 'Credit Memo'

UNION ALL

--LOADSHIPMENT RETURN NON-LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ICIT.[intItemUOMId], ARID.[dblShipmentNetWt]), @ZeroDecimal) --ICIT.[dblQty]
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
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON LGD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN tblLGLoad LG WITH (NOLOCK) ON LGD.[intLoadId] = LG.[intLoadId] 
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
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
	AND (LG.[intPurchaseSale] IN (2, 3) AND ARID.[strType] = 'Provisional')
	AND ARID.[intInventoryShipmentItemId] IS NULL
	AND ARID.[strTransactionType] = 'Credit Memo'
    AND ARID.[intTicketId] IS NULL
    AND ARIDL.[intInvoiceDetailLotId] IS NULL

UNION ALL

--LOADSHIPMENT RETURN LOTTED
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= CASE WHEN ARID.[strTransactionType] IN ('Credit Memo', 'Credit Note') THEN ICIT.[dblQty] ELSE -ICIT.[dblQty] END
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
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON LGD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN tblLGLoad LG WITH (NOLOCK) ON LGD.[intLoadId] = LG.[intLoadId] 
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
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ARRETURN.[intInvoiceId] 
										 AND ICIT.[intTransactionDetailId] = ARRETURN.[intInvoiceDetailId]
										 AND ICIT.[strTransactionId] = ARRETURN.[strInvoiceNumber]
										 AND ICIT.[intItemId] = ARRETURN.[intItemId]
										 AND ICIT.[intLotId] = ARRETURN.[intLotId]
										 AND ICIT.[ysnIsUnposted] = 0		
										 AND ICIT.[intInTransitSourceLocationId] IS NOT NULL	 
WHERE ((ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0) OR (ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1))
	AND (LG.[intPurchaseSale] IN (2, 3) AND ARID.[strType] = 'Provisional')
	AND ARID.[intInventoryShipmentItemId] IS NULL
	AND ARID.[strTransactionType] = 'Credit Memo'

UNION ALL

--LOADSHIPMENT NON-LOTTED (PROVISIONAL INVOICE REVERSAL)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ICIT.[intItemUOMId], LG.[dblQuantity]), @ZeroDecimal)
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
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM (
	SELECT ARPID.intInvoiceId
		, INVD.intLoadDetailId
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
		, INVD.intLotId
		, INVD.intItemUOMId
		, INVD.intTicketId
		, ARPID.ysnFromProvisional
		, ARPID.ysnProvisionalWithGL
		, ARPID.intItemWeightUOMId
		, INVD.dblShipmentNetWt
		, ARPID.strType
		, ARPID.strBOLNumber
		, ARPID.intEntityCustomerId
	FROM tblARInvoiceDetail INVD
	INNER JOIN ##ARPostInvoiceDetail ARPID ON INVD.intInvoiceDetailId = ARPID.intOriginalInvoiceDetailId
										  AND INVD.dblShipmentNetWt <> ARPID.dblShipmentNetWt
) ARID
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON LGD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN tblLGLoad LG WITH (NOLOCK) ON LGD.[intLoadId] = LG.[intLoadId] 
CROSS APPLY (
	SELECT TOP 1 IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = LG.[intLoadId] 
	  AND IT.[intTransactionDetailId] = LGD.[intLoadDetailId] 
	  AND IT.[strTransactionId] = LG.[strLoadNumber] 			 
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0		
	  AND IT.[intInTransitSourceLocationId] IS NOT NULL
) ICIT
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ARID.[intSourceId] = 2
  AND ARID.[ysnFromProvisional] = 1 
  AND ARID.[ysnProvisionalWithGL] = 1
  AND ARID.[strTransactionType] IN ('Invoice', 'Credit Memo')
  AND (LG.[intPurchaseSale] IN (2, 3) AND ARID.[strType] = 'Provisional')
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ARIDL.[intInvoiceDetailLotId] IS NULL

UNION ALL

--LOADSHIPMENT NON-LOTTED (FINAL INVOICE)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -ISNULL(CASE WHEN ARID.[dblShipmentNetWt] > ARID.[dblShipmentNetWtProvisional] THEN LG.[dblQuantity] ELSE [dbo].[fnCalculateQtyBetweenUOM](ARID.[intItemWeightUOMId], ARID.[intOrderUOMId], ARID.[dblShipmentNetWt]) END, @ZeroDecimal)
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
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM (
	SELECT ARPID.intInvoiceId
		, INVD.intLoadDetailId
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
		, INVD.intLotId
		, INVD.intItemUOMId
		, INVD.intTicketId
		, ARPID.ysnFromProvisional
		, ARPID.ysnProvisionalWithGL
		, INVD.intItemWeightUOMId
		, ARPID.dblShipmentNetWt
		, dblShipmentNetWtProvisional = INVD.dblShipmentNetWt
		, INVD.intOrderUOMId
		, ARPID.strType
		, ARPID.strBOLNumber 
		, ARPID.intEntityCustomerId
	FROM tblARInvoiceDetail INVD
	INNER JOIN ##ARPostInvoiceDetail ARPID
	ON INVD.intInvoiceDetailId = ARPID.intOriginalInvoiceDetailId
	AND INVD.dblShipmentNetWt <> ARPID.dblShipmentNetWt
) ARID
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON LGD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN tblLGLoad LG WITH (NOLOCK) ON LGD.[intLoadId] = LG.[intLoadId] 
CROSS APPLY (
	SELECT TOP 1 IT.* 				
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = LG.[intLoadId] 
	  AND IT.[intTransactionDetailId] = LGD.[intLoadDetailId] 
	  AND IT.[strTransactionId] = LG.[strLoadNumber] 			 
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0		
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0
) ICIT
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ARID.[intSourceId] = 2
  AND ARID.[ysnFromProvisional] = 1 
  AND ARID.[ysnProvisionalWithGL] = 1
  AND ARID.[strTransactionType] IN ('Invoice', 'Credit Memo')
  AND (LG.[intPurchaseSale] IN (2, 3) AND ARID.[strType] = 'Provisional')
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ARIDL.[intInvoiceDetailLotId] IS NULL

UNION ALL

--INVENTORY SHIPMENT NON-LOTTED (PROVISIONAL INVOICE REVERSAL)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ISNULL(ARID.[dblQtyShipped], ICISI.dblQuantity)), @ZeroDecimal)
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
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM (
	SELECT INVD.intInvoiceId
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
		, INVD.dblQtyShipped
		, INVD.intLotId
		, INVD.intItemUOMId
		, INVD.intTicketId
		, ARPID.ysnFromProvisional
		, ARPID.ysnProvisionalWithGL
		, ARPID.strBOLNumber 
		, ARPID.intEntityCustomerId
	FROM tblARInvoiceDetail INVD
	INNER JOIN ##ARPostInvoiceDetail ARPID ON INVD.intInvoiceDetailId = ARPID.intOriginalInvoiceDetailId
										  AND INVD.dblQtyShipped <> ARPID.dblQtyShipped
) ARID
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
CROSS APPLY (
	SELECT TOP 1 IT.* 
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
	  AND IT.[strTransactionId] = ICIS.[strShipmentNumber] 
	  AND IT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0			 
	  AND ISNULL(IT.[intInTransitSourceLocationId], 0) <> 0 
) ICIT
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ARID.[intLoadDetailId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ARID.[intSourceId] = 2
  AND ARID.[ysnFromProvisional] = 1 
  AND ARID.[ysnProvisionalWithGL] = 1
  AND ARID.[strTransactionType]  IN ('Invoice', 'Credit Memo')
  AND ARIDL.[intInvoiceDetailLotId] IS NULL

UNION ALL

--INVENTORY SHIPMENT NON-LOTTED (FINAL INVOICE)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], CASE WHEN ARID.[dblQtyShipped] > ARID.[dblQtyShippedProvisional] THEN ISNULL(ARID.[dblQtyShippedProvisional], ICISI.dblQuantity) ELSE ISNULL(ARID.[dblQtyShipped], ICISI.dblQuantity) END), @ZeroDecimal)
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
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM (
	SELECT INVD.intInvoiceId
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
		 , ARPID.dblQtyShipped
		 , dblQtyShippedProvisional = INVD.dblQtyShipped
		 , INVD.intLotId
		 , INVD.intItemUOMId
		 , INVD.intTicketId
		 , ARPID.ysnFromProvisional
		 , ARPID.ysnProvisionalWithGL
		 , ARPID.strBOLNumber 
		 , ARPID.intEntityCustomerId
	FROM tblARInvoiceDetail INVD
	INNER JOIN ##ARPostInvoiceDetail ARPID ON INVD.intInvoiceDetailId = ARPID.intOriginalInvoiceDetailId
	AND INVD.dblQtyShipped <> ARPID.dblQtyShipped
) ARID
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId] 
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
CROSS APPLY (
	SELECT TOP 1 IT.* 
	FROM tblICInventoryTransaction IT 
	WHERE IT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
	  AND IT.[strTransactionId] = ICIS.[strShipmentNumber] 
	  AND IT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
	  AND IT.[intItemId] = ARID.[intItemId]
	  AND IT.[ysnIsUnposted] = 0			 
	  AND IT.[intInTransitSourceLocationId] IS NOT NULL
) ICIT
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
WHERE ARID.[intLoadDetailId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ARID.[intSourceId] = 2
  AND ARID.[ysnFromProvisional] = 1 
  AND ARID.[ysnProvisionalWithGL] = 1
  AND ARID.[strTransactionType] IN ('Invoice', 'Credit Memo')
  AND ARIDL.[intInvoiceDetailLotId] IS NULL

UNION ALL

--INVENTORY SHIPMENT LOTTED (PROVISIONAL INVOICE REVERSAL)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= (CAST(ARIDLP.[dblQuantityShipped] AS NUMERIC(25, 13)) / CAST(AVGT.dblTotalQty AS NUMERIC(25, 13))) * ICIT.[dblQty]
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
	,[intLotId]						= NULL
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN tblARInvoiceDetailLot ARIDLP ON ARIDLP.[intInvoiceDetailId] = ARID.[intOriginalInvoiceDetailId]
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICIS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[intLotId] = ARIDL.[intLotId]
										 AND ICIT.[ysnIsUnposted] = 0
INNER JOIN (
	SELECT intTransactionId
		 , strTransactionId
		 , intTransactionDetailId
		 , intItemId
		 , intLotId
		 , dblTotalQty = SUM(dblQty)
	FROM tblICInventoryTransaction ICIT 
	WHERE ICIT.[ysnIsUnposted] = 0
	  AND ISNULL(ICIT.[intInTransitSourceLocationId], 0) <> 0
	GROUP BY ICIT.[intTransactionId]
		   , ICIT.[strTransactionId]
		   , ICIT.[intTransactionDetailId]
		   , ICIT.[intItemId]
		   , ICIT.[intLotId]
) AVGT ON AVGT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
      AND AVGT.[strTransactionId] = ICIS.[strShipmentNumber] 
      AND AVGT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
      AND AVGT.[intItemId] = ARID.[intItemId]
      AND AVGT.[intLotId] = ARIDL.[intLotId]
WHERE ARID.[intLoadDetailId] IS NULL
  AND ARID.[intTicketId] IS NULL
  AND ICIT.[intInTransitSourceLocationId] IS NOT NULL
  AND ARID.[intSourceId] = 2
  AND ARID.[ysnFromProvisional] = 1 
  AND ARID.[ysnProvisionalWithGL] = 1
  AND ARID.[strTransactionType]  IN ('Invoice', 'Credit Memo')
  AND ARIDLP.[dblQuantityShipped] <> ARIDL.[dblQuantityShipped]

UNION ALL

--INVENTORY SHIPMENT LOTTED (FINAL INVOICE)
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -(CAST((CASE WHEN ARIDL.[dblQuantityShipped] > ARIDLP.[dblQuantityShipped] THEN ARIDLP.[dblQuantityShipped] ELSE ARIDL.[dblQuantityShipped] END) AS NUMERIC(25, 13)) / CAST(AVGT.dblTotalQty AS NUMERIC(25, 13))) * ICIT.[dblQty]
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
	,[intLotId]						= NULL
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICISI.intChildItemLinkId
	,[strBOLNumber]					= ARID.strBOLNumber
	,[intTicketId]					= ARID.intTicketId
	,[intSourceEntityId]		    = ARID.intEntityCustomerId
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblARInvoiceDetailLot ARIDL ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN tblARInvoiceDetailLot ARIDLP ON ARIDLP.[intInvoiceDetailId] = ARID.[intOriginalInvoiceDetailId]
INNER JOIN tblICInventoryShipmentItem ICISI WITH (NOLOCK) ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
INNER JOIN tblICInventoryShipment ICIS WITH (NOLOCK) ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
INNER JOIN tblICInventoryTransaction ICIT ON ICIT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
										 AND ICIT.[strTransactionId] = ICIS.[strShipmentNumber] 
										 AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
										 AND ICIT.[intItemId] = ARID.[intItemId]
										 AND ICIT.[intLotId] = ARIDL.[intLotId]
										 AND ICIT.[ysnIsUnposted] = 0
INNER JOIN (
	SELECT intTransactionId
		 , strTransactionId
		 , intTransactionDetailId
		 , intItemId
		 , intLotId
		 , dblTotalQty = SUM(dblQty)
	FROM tblICInventoryTransaction ICIT 
	WHERE ICIT.[ysnIsUnposted] = 0
	  AND ICIT.[intInTransitSourceLocationId] IS NOT NULL
	GROUP BY ICIT.[intTransactionId]
		   , ICIT.[strTransactionId]
		   , ICIT.[intTransactionDetailId]
		   , ICIT.[intItemId]
		   , ICIT.[intLotId]
) AVGT ON AVGT.[intTransactionId] = ICIS.[intInventoryShipmentId] 
      AND AVGT.[strTransactionId] = ICIS.[strShipmentNumber] 
      AND AVGT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
      AND AVGT.[intItemId] = ARID.[intItemId]
      AND AVGT.[intLotId] = ARIDL.[intLotId]
WHERE ARID.[intLoadDetailId] IS NULL
	AND ARID.[intTicketId] IS NULL
	AND ICIT.[intInTransitSourceLocationId] IS NOT NULL
	AND ARID.[intSourceId] = 2
	AND ARID.[ysnFromProvisional] = 1 
	AND ARID.[ysnProvisionalWithGL] = 1
	AND ARID.[strTransactionType]  IN ('Invoice', 'Credit Memo')
	AND ARIDLP.[dblQuantityShipped] <> ARIDL.[dblQuantityShipped]

UPDATE A 
SET intLinkedItemId = B.intItemId
FROM ##ARItemsForInTransitCosting A
INNER JOIN tblICInventoryShipmentItem B ON A.intLinkedItem = B.intParentItemLinkId
WHERE A.intLinkedItem IS NOT NULL

RETURN 1