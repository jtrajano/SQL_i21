CREATE VIEW [dbo].[vyuARProvisionalInvoiceDocumentDetail]
AS

SELECT
	 [strDocumentId]						= ARSI.[strShippedItemId]
	,[strDocumentDetailId]					= 'icis:' + CAST(ARSI.[intInventoryShipmentItemId] AS NVARCHAR(250))
	,[intShipmentId]						= NULL
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[intLoadDetailId]						= ARSI.[intLoadDetailId] 
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
	,[intStorageLocationId]					= ARSI.[intStorageLocationId]
	,[strStorageLocationName]				= ARSI.[strStorageLocationName]
	,[intTaxGroupId]						= ARSI.[intTaxGroupId]
	,[strTaxGroup]							= ARSI.[strTaxGroup]
	,[dblWeight]							= ARSI.[dblWeight]
	,[intWeightUOMId]						= ARSI.[intWeightUOMId]
	,[strWeightUnitMeasure]					= ARSI.[strWeightUnitMeasure]
	,[dblGrossWt]							= ARSI.[dblGrossWt] 
	,[dblTareWt]							= ARSI.[dblTareWt]
	,[dblNetWt]								= ARSI.[dblNetWt]
FROM
	vyuARShippedItems ARSI
WHERE
	ARSI.[strTransactionType] = 'Inventory Shipment'

		
UNION ALL		


SELECT
	 [strDocumentId]						= ARSID.[strShippedItemId]
	,[strDocumentDetailId]					= CAST(ARSID.[strShippedItemDetailId] AS NVARCHAR(250))
	,[intShipmentId]						= ARSID.[intShipmentId]
	,[intShipmentPurchaseSalesContractId]	= NULL 
	,[intLoadDetailId]						= ARSID.[intLoadDetailId] 
	,[intSalesOrderDetailId]				= ARSID.[intSalesOrderDetailId]
	,[intInventoryShipmentId]				= ARSID.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]			= ARSID.[intInventoryShipmentItemId]
	,[intContractHeaderId]					= ARSID.[intContractHeaderId]
	,[strContractNumber]					= ARSID.[strContractNumber] 
	,[intContractDetailId]					= ARSID.[intContractDetailId] 
	,[intContractSeq]						= ARSID.[intContractSeq] 
	,[intItemId]							= ARSID.[intItemId]
	,[strItemNo]							= ARSID.[strItemNo]
	,[strItemDescription]					= ARSID.[strItemDescription]
	,[intItemUOMId]							= ARSID.[intItemUOMId]
	,[strUnitMeasure]						= ARSID.[strUnitMeasure]
	,[intShipmentItemUOMId]					= ARSID.[intShipmentItemUOMId]
	,[strShipmentUnitMeasure]				= ARSID.[strShipmentUnitMeasure]
	,[dblQtyShipped]						= ARSID.[dblQtyShipped]
	,[dblQtyOrdered]						= ARSID.[dblQtyOrdered]
	,[dblShipmentQuantity]					= ARSID.[dblShipmentQuantity]	
	,[dblShipmentQtyShippedTotal]			= ARSID.[dblShipmentQtyShippedTotal]
	,[dblQtyRemaining]						= ARSID.[dblQtyRemaining]
	,[dblDiscount]							= ARSID.[dblDiscount]
	,[dblPrice]								= ARSID.[dblPrice]
	,[dblShipmentUnitPrice]					= ARSID.[dblShipmentUnitPrice]
	,[dblTotalTax]							= ARSID.[dblTotalTax]
	,[dblTotal]								= ARSID.[dblTotal]
	,[intStorageLocationId]					= ARSID.[intStorageLocationId]
	,[strStorageLocationName]				= ARSID.[strStorageLocationName]
	,[intTaxGroupId]						= ARSID.[intTaxGroupId]
	,[strTaxGroup]							= CAST(ARSID.[strTaxGroup] AS NVARCHAR(250))
	,[dblWeight]							= ARSID.[dblWeight]
	,[intWeightUOMId]						= ARSID.[intWeightUOMId]
	,[strWeightUnitMeasure]					= ARSID.[strWeightUnitMeasure]
	,[dblGrossWt]							= ARSID.[dblGrossWt] 
	,[dblTareWt]							= ARSID.[dblTareWt]
	,[dblNetWt]								= ARSID.[dblNetWt]
FROM
	vyuARShippedItemDetail ARSID
	