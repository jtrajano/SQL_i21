CREATE VIEW [dbo].[vyuARProvisionalInvoiceDocumentDetail]
AS

SELECT
	 [strDocumentId]						= ARSI.[strShippedItemId]
	,[strDocumentDetailId]					= 'icis:' + CAST(ARSI.[intInventoryShipmentItemId] AS NVARCHAR(250))
	,[intShipmentId]						= NULL
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[intSalesOrderDetailId]				= ARSI.[intSalesOrderDetailId]
	,[intInventoryShipmentId]				= ARSI.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]			= ARSI.[intInventoryShipmentItemId]
	,[intContractHeaderId]					= NULL
	,[strContractNumber]					= NULL 
	,[intContractDetailId]					= NULL 
	,[intContractSeq]						= NULL 
	,[intItemId]							= ARSI.[intItemId]
	,[strItemNo]							= ARSI.[strItemNo]
	,[strItemDescription]					= ARSI.[strItemDescription]
	,[intItemUOMId]							= ARSI.[intItemUOMId]
	,[strUnitMeasure]						= ARSI.[strUnitMeasure]
	,[intShipmentItemUOMId]					= ARSI.[intShipmentItemUOMId]
	,[strShipmentUnitMeasure]				= ARSI.[strShipmentUnitMeasure]
	,[dblQtyShipped]						= ARSI.[dblQtyShipped]
	,[dblQtyOrdered]						= ARSI.[dblQtyOrdered]
	,[dblShipmentQuantity]					= ARSI.[dblShipmentQuantity]	
	,[dblShipmentQtyShippedTotal]			= ARSI.[dblShipmentQtyShippedTotal]
	,[dblQtyRemaining]						= ARSI.[dblQtyRemaining]
	,[dblDiscount]							= ARSI.[dblDiscount]
	,[dblPrice]								= ARSI.[dblPrice]
	,[dblShipmentUnitPrice]					= ARSI.[dblShipmentUnitPrice]
	,[dblTotalTax]							= ARSI.[dblTotalTax]
	,[dblTotal]								= ARSI.[dblTotal]
	,[intAccountId]							= ARSI.[intAccountId]
	,[intCOGSAccountId]						= ARSI.[intCOGSAccountId]
	,[intSalesAccountId]					= ARSI.[intSalesAccountId]
	,[intInventoryAccountId]				= ARSI.[intInventoryAccountId]
	,[intStorageLocationId]					= ARSI.[intStorageLocationId]
	,[strStorageLocationName]				= ARSI.[strStorageLocationName]
	,[intTaxGroupId]						= ARSI.[intTaxGroupId]
	,[strTaxGroup]							= ARSI.[strTaxGroup]
	,[dblGrossWt]							= ARSI.[dblGrossWt] 
	,[dblTareWt]							= ARSI.[dblTareWt]
	,[dblNetWt]								= ARSI.[dblNetWt]
FROM
	vyuARShippedItems ARSI
WHERE
	ARSI.[strTransactionType] = 'Inventory Shipment'

		
UNION ALL		


SELECT
	 [strDocumentId]						= ARSI.[strShippedItemId]
	,[strDocumentDetailId]					= ARSI.[strShippedItemDetailId]
	,[intShipmentId]						= ARSI.[intShipmentId]
	,[intShipmentPurchaseSalesContractId]	= ARSI.[intShipmentPurchaseSalesContractId] 
	,[intSalesOrderDetailId]				= ARSI.[intSalesOrderDetailId]
	,[intInventoryShipmentId]				= ARSI.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]			= ARSI.[intInventoryShipmentItemId]
	,[intContractHeaderId]					= ARSI.[intContractHeaderId]
	,[strContractNumber]					= ARSI.[strContractNumber] 
	,[intContractDetailId]					= ARSI.[intContractDetailId] 
	,[intContractSeq]						= ARSI.[intContractSeq] 
	,[intItemId]							= ARSI.[intItemId]
	,[strItemNo]							= ARSI.[strItemNo]
	,[strItemDescription]					= ARSI.[strItemDescription]
	,[intItemUOMId]							= ARSI.[intItemUOMId]
	,[strUnitMeasure]						= ARSI.[strUnitMeasure]
	,[intShipmentItemUOMId]					= ARSI.[intShipmentItemUOMId]
	,[strShipmentUnitMeasure]				= ARSI.[strShipmentUnitMeasure]
	,[dblQtyShipped]						= ARSI.[dblQtyShipped]
	,[dblQtyOrdered]						= ARSI.[dblQtyOrdered]
	,[dblShipmentQuantity]					= ARSI.[dblShipmentQuantity]	
	,[dblShipmentQtyShippedTotal]			= ARSI.[dblShipmentQtyShippedTotal]
	,[dblQtyRemaining]						= ARSI.[dblQtyRemaining]
	,[dblDiscount]							= ARSI.[dblDiscount]
	,[dblPrice]								= ARSI.[dblPrice]
	,[dblShipmentUnitPrice]					= ARSI.[dblShipmentUnitPrice]
	,[dblTotalTax]							= ARSI.[dblTotalTax]
	,[dblTotal]								= ARSI.[dblTotal]
	,[intAccountId]							= ARSI.[intAccountId]
	,[intCOGSAccountId]						= ARSI.[intCOGSAccountId]
	,[intSalesAccountId]					= ARSI.[intSalesAccountId]
	,[intInventoryAccountId]				= ARSI.[intInventoryAccountId]
	,[intStorageLocationId]					= ARSI.[intStorageLocationId]
	,[strStorageLocationName]				= ARSI.[strStorageLocationName]
	,[intTaxGroupId]						= ARSI.[intTaxGroupId]
	,[strTaxGroup]							= ARSI.[strTaxGroup] 
	,[dblGrossWt]							= ARSI.[dblGrossWt] 
	,[dblTareWt]							= ARSI.[dblTareWt]
	,[dblNetWt]								= ARSI.[dblNetWt]
FROM
	vyuARShippedItemDetail ARSI
	