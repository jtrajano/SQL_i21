CREATE VIEW [dbo].[vyuARProvisionalInvoiceDocument]
AS

SELECT DISTINCT 
	 [strTransactionType]				= ARSI.[strTransactionType]
	,[strDocumentNumber]				= ARSI.[strTransactionNumber]
	,[strDocumentId]					= ARSI.[strShippedItemId]
	,[intEntityCustomerId]				= ARSI.[intEntityCustomerId] 
	,[strCustomerName]					= ARSI.[strCustomerName]	
	,[dtmProcessDate]					= ARSI.[dtmProcessDate]
	,[intInventoryShipmentId]			= ARSI.[intInventoryShipmentId]
	,[intShipmentId]					= ARSI.[intShipmentId]
	,[intCompanyLocationId]				= ARSI.[intCompanyLocationId]
	,[strLocationName]					= ARSI.[strLocationName]
FROM
	vyuARShippedItems ARSI
WHERE
	[strTransactionType] = 'Inventory Shipment'
	
UNION ALL
	
SELECT
	 [strTransactionType]				= ARSI.[strTransactionType]
	,[strTransactionNumber]				= ARSI.[strTransactionNumber]
	,[strDocumentId]					= ARSI.[strShippedItemId]
	,[intEntityCustomerId]				= ARSI.[intEntityCustomerId] 
	,[strCustomerName]					= ARSI.[strCustomerName]	
	,[dtmProcessDate]					= ARSI.[dtmProcessDate]
	,[intInventoryShipmentId]			= ARSI.[intInventoryShipmentId]
	,[intShipmentId]					= ARSI.[intShipmentId]
	,[intCompanyLocationId]				= ARSI.[intCompanyLocationId]
	,[strLocationName]					= ARSI.[strLocationName]
FROM
	vyuARShippedItems ARSI
WHERE
	[strTransactionType] IN ('Inbound Shipment', 'Load Schedule')
	