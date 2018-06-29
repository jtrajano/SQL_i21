CREATE VIEW [dbo].[vyuARProvisionalInvoiceDocument]
AS

SELECT DISTINCT 
	 [strDocumentNumber]				= ARSI.[strTransactionNumber]
	,[intInventoryShipmentId]			= ARSI.[intInventoryShipmentId]
	,[intShipmentId]					= ARSI.[intShipmentId]
	,[strDocumentId]					= ARSI.[strShippedItemId]
	,[strTransactionType]				= ARSI.[strTransactionType]
	,[intEntityCustomerId]				= ARSI.[intEntityCustomerId] 
	,[intCompanyLocationId]				= ARSI.[intCompanyLocationId]
	,[strCustomerName]					= ARSI.[strCustomerName]	
	,[dtmProcessDate]					= ARSI.[dtmProcessDate]		
	,[strLocationName]					= ARSI.[strLocationName]
FROM
	vyuARShippedItems ARSI
WHERE
	[strTransactionType] IN ('Inbound Shipment', 'Load Schedule', 'Inventory Shipment')	
	AND ARSI.[strShippedItemId] IS NOT NULL