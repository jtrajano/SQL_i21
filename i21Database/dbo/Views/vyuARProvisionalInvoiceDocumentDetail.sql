CREATE VIEW [dbo].[vyuARProvisionalInvoiceDocumentDetail]
AS

SELECT
	 [strDocumentId]						= ARSI.[strShippedItemId]  COLLATE Latin1_General_CI_AS 
	,[strDocumentDetailId]					= 'icis:' + CAST(ARSI.[intInventoryShipmentItemId] AS NVARCHAR(250))  COLLATE Latin1_General_CI_AS
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
	,[strItemNo]							= ARSI.[strItemNo]  COLLATE Latin1_General_CI_AS
	,[strItemDescription]					= ARSI.[strItemDescription]  COLLATE Latin1_General_CI_AS
	,[intItemUOMId]							= ARSI.[intItemUOMId]
	,[strUnitMeasure]						= ARSI.[strUnitMeasure]  COLLATE Latin1_General_CI_AS
	,[intShipmentItemUOMId]					= ARSI.[intShipmentItemUOMId]
	,[strShipmentUnitMeasure]				= ARSI.[strShipmentUnitMeasure]  COLLATE Latin1_General_CI_AS
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
	,[strStorageLocationName]				= ARSI.[strStorageLocationName]  COLLATE Latin1_General_CI_AS
	,[intTaxGroupId]						= ARSI.[intTaxGroupId]
	,[strTaxGroup]							= ARSI.[strTaxGroup]  COLLATE Latin1_General_CI_AS
	,[dblWeight]							= ARSI.[dblWeight]
	,[intWeightUOMId]						= ARSI.[intWeightUOMId]
	,[strWeightUnitMeasure]					= ARSI.[strWeightUnitMeasure]  COLLATE Latin1_General_CI_AS
	,[dblGrossWt]							= ARSI.[dblGrossWt] 
	,[dblTareWt]							= ARSI.[dblTareWt]
	,[dblNetWt]								= ARSI.[dblNetWt]
	,[intCurrencyExchangeRateTypeId]		= ARSI.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]			= ARSI.[strCurrencyExchangeRateType]  COLLATE Latin1_General_CI_AS
	,[intCurrencyExchangeRateId]			= ARSI.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]				= ARSI.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]						= ARSI.[intSubCurrencyId]
	,[dblSubCurrencyRate]					= ARSI.[dblSubCurrencyRate]
	,[strSubCurrency]						= ARSI.[strSubCurrency] COLLATE Latin1_General_CI_AS 
	,[intDestinationGradeId]				= ARSI.[intDestinationGradeId]
	,[strDestinationGrade]					= ARSI.[strDestinationGrade] COLLATE Latin1_General_CI_AS
	,[intDestinationWeightId]				= ARSI.[intDestinationWeightId]
	,[strDestinationWeight]					= ARSI.[strDestinationWeight] COLLATE Latin1_General_CI_AS
FROM
	vyuARShippedItems ARSI
WHERE
	ARSI.[strTransactionType] = 'Inventory Shipment'

		
UNION ALL		


SELECT
	 [strDocumentId]						= ARSID.[strShippedItemId] COLLATE Latin1_General_CI_AS
	,[strDocumentDetailId]					= CAST(ARSID.[strShippedItemDetailId] AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[intShipmentId]						= ARSID.[intShipmentId]
	,[intShipmentPurchaseSalesContractId]	= NULL 
	,[intLoadDetailId]						= ARSID.[intLoadDetailId] 
	,[intSalesOrderDetailId]				= ARSID.[intSalesOrderDetailId]
	,[intInventoryShipmentId]				= ARSID.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]			= ARSID.[intInventoryShipmentItemId]
	,[intContractHeaderId]					= ARSID.[intContractHeaderId]
	,[strContractNumber]					= ARSID.[strContractNumber] COLLATE Latin1_General_CI_AS 
	,[intContractDetailId]					= ARSID.[intContractDetailId] 
	,[intContractSeq]						= ARSID.[intContractSeq] 
	,[intItemId]							= ARSID.[intItemId]
	,[strItemNo]							= ARSID.[strItemNo] COLLATE Latin1_General_CI_AS
	,[strItemDescription]					= ARSID.[strItemDescription] COLLATE Latin1_General_CI_AS
	,[intItemUOMId]							= ARSID.[intItemUOMId]
	,[strUnitMeasure]						= ARSID.[strUnitMeasure] COLLATE Latin1_General_CI_AS
	,[intShipmentItemUOMId]					= ARSID.[intShipmentItemUOMId]
	,[strShipmentUnitMeasure]				= ARSID.[strShipmentUnitMeasure] COLLATE Latin1_General_CI_AS
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
	,[strStorageLocationName]				= ARSID.[strStorageLocationName] COLLATE Latin1_General_CI_AS
	,[intTaxGroupId]						= ARSID.[intTaxGroupId]
	,[strTaxGroup]							= CAST(ARSID.[strTaxGroup] AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,[dblWeight]							= ARSID.[dblWeight]
	,[intWeightUOMId]						= ARSID.[intWeightUOMId]
	,[strWeightUnitMeasure]					= ARSID.[strWeightUnitMeasure] COLLATE Latin1_General_CI_AS
	,[dblGrossWt]							= ARSID.[dblGrossWt] 
	,[dblTareWt]							= ARSID.[dblTareWt]
	,[dblNetWt]								= ARSID.[dblNetWt]
	,[intCurrencyExchangeRateTypeId]		= ARSID.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]			= ARSID.[strCurrencyExchangeRateType] COLLATE Latin1_General_CI_AS
	,[intCurrencyExchangeRateId]			= ARSID.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]				= ARSID.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]						= ARSID.[intSubCurrencyId]
	,[dblSubCurrencyRate]					= ARSID.[dblSubCurrencyRate]
	,[strSubCurrency]						= ARSID.[strSubCurrency] COLLATE Latin1_General_CI_AS
	,[intDestinationGradeId]				= ARSID.[intDestinationGradeId]
	,[strDestinationGrade]					= ARSID.[strDestinationGrade] COLLATE Latin1_General_CI_AS
	,[intDestinationWeightId]				= ARSID.[intDestinationWeightId]
	,[strDestinationWeight]					= ARSID.[strDestinationWeight] COLLATE Latin1_General_CI_AS
FROM
	vyuARShippedItemDetail ARSID
	