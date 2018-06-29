CREATE VIEW [dbo].[vyuSMGlobalSearch] WITH SCHEMABINDING
AS
SELECT ROW_NUMBER() over(order by Id) as intGSIndexId, strNamespace, strDisplayTitle, strValueField, strValueData, strDisplayData, strTag, strSearchCommand
FROM
(	
	--ENTITY--
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Vendor' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityVendor' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Vendor'
	union	
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Customer' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityCustomer' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Customer'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Salesperson' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntitySalesperson' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Salesperson'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'FuturesBroker' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityFuturesBroker' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'FuturesBroker'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'ForwardingAgent' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityForwardingAgent' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'ForwardingAgent'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Terminal' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityTerminal' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Terminal'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'ShippingLine' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityShippingLine' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'ShippingLine'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Trucker' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityTrucker' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Trucker'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'ShipVia' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityShipVia' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'ShipVia'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Insurer' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityInsurer' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Insurer'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Employee' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityEmployee' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Employee'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Producer' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityProducer' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'Producer'
	union
	select 
		'EM' + CONVERT(NVARCHAR,entity.[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'User' as strDisplayTitle,			
		'intEntityId' as strValueField,
		CONVERT(NVARCHAR(10),entity.[intEntityId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strName],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strEntityNo],'')) as strTag,
		'searchEntityUser' as strSearchCommand
	from [dbo].tblEMEntity as entity join [dbo].[tblEMEntityType] as entityType 
	on entity.intEntityId = entityType.intEntityId and entityType.strType = 'User'
	union

	--Purchase Orders--
	select 
		'AP' + CONVERT(NVARCHAR,po.[intPurchaseId]) as Id,
		'AccountsPayable.view.PurchaseOrder' as strNamespace,
		'Purchase Order' as strDisplayTitle,			
		'intPurchaseId' as strValueField,
		CONVERT(NVARCHAR(10), po.[intPurchaseId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strPurchaseOrderNumber],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strPurchaseOrderNumber],'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblPOPurchase] as po
	union

	--Vouchers--
	select 
		'AP' + CONVERT(NVARCHAR,v.[intBillId]) as Id,
		'AccountsPayable.view.Voucher' as strNamespace,
		'Voucher' as strDisplayTitle,			
		'intBillId' as strValueField,
		CONVERT(NVARCHAR(10), v.intBillId) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strBillId,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strBillId,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblAPBill] as v
	union

	--Sales Order--
	select 
		'AR' + CONVERT(NVARCHAR, so.[intSalesOrderId]) as Id,
		'AccountsReceivable.view.SalesOrder' as strNamespace,
		'Sales Order' as strDisplayTitle,			
		'intSalesOrderId' as strValueField,
		CONVERT(NVARCHAR(10), so.[intSalesOrderId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strSalesOrderNumber,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strSalesOrderNumber,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblSOSalesOrder] as so
	union

	--Invoice--
	select 
		'AR' + CONVERT(NVARCHAR, invoice.[intInvoiceId]) as Id,
		'AccountsReceivable.view.Invoice' as strNamespace,
		'Invoice' as strDisplayTitle,			
		'intInvoiceId' as strValueField,
		CONVERT(NVARCHAR(10), invoice.[intInvoiceId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strInvoiceNumber,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strInvoiceNumber,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblARInvoice] as invoice
	union

	--Contract--
	select 
		'CT' + CONVERT(NVARCHAR, ct.[intContractHeaderId]) as Id,
		'ContractManagement.view.Contract' as strNamespace,
		'Contract' as strDisplayTitle,			
		'intContractHeaderId' as strValueField,
		CONVERT(NVARCHAR(10), ct.[intContractHeaderId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strContractNumber,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strContractNumber,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblCTContractHeader] as ct
	union

	--Inventory Receipt--
	select 
		'IC' + CONVERT(NVARCHAR, ir.[intInventoryReceiptId]) as Id,
		'Inventory.view.InventoryReceipt' as strNamespace,
		'Inventory Receipt' as strDisplayTitle,			
		'intInventoryReceiptId' as strValueField,
		CONVERT(NVARCHAR(10), ir.[intInventoryReceiptId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strReceiptNumber,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strReceiptNumber,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblICInventoryReceipt] as ir
	union

	--Inventory Shipment--
	select 
		'IC' + CONVERT(NVARCHAR, [intInventoryShipmentId]) as Id,
		'Inventory.view.InventoryShipment' as strNamespace,
		'Inventory Shipment' as strDisplayTitle,			
		'intInventoryReceiptId' as strValueField,
		CONVERT(NVARCHAR(10), [intInventoryShipmentId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strShipmentNumber,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strShipmentNumber,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblICInventoryShipment]
	union

	--Inventory Adjustment--
	select 
		'IC' + CONVERT(NVARCHAR, [intInventoryAdjustmentId]) as Id,
		'Inventory.view.InventoryAdjustment' as strNamespace,
		'Inventory Adjustment' as strDisplayTitle,			
		'intInventoryAdjustmentId' as strValueField,
		CONVERT(NVARCHAR(10), [intInventoryAdjustmentId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL(strAdjustmentNo,'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL(strAdjustmentNo,'')) as strTag,
		'' as strSearchCommand
	from [dbo].[tblICInventoryAdjustment]
	union

	--Items--
	select 
		'IC' + CONVERT(NVARCHAR,[intItemId]) as Id,
		'Inventory.view.Item' as strNamespace,
		'Item' as strDisplayTitle,			
		'intItemId' as strValueField,
		CONVERT(NVARCHAR(10),[intItemId]) as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strItemNo],'')) as strDisplayData,			
		CONVERT(NVARCHAR(MAX), ISNULL([strItemNo],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strType],'')) + ', ' + 
		CONVERT(NVARCHAR(MAX), ISNULL([strDescription],''))   as strTag,
		'' as strSearchCommand
	from [dbo].[tblICItem] as item

	--Master Menu--
	union
	select 
		'SM' + CONVERT(NVARCHAR, mm.[intMenuID]) as Id,
		CASE WHEN (CHARINDEX('searchCommand', strCommand, 0) > 0) THEN 
		SUBSTRING(strCommand,0, CHARINDEX('?searchCommand=', strCommand, 0)) ELSE
		strCommand END as strNamespace,
		'Master Menu' as strDisplayTitle,			
		'' as strValueField,
		strCommand as strValueData,
		CONVERT(NVARCHAR(MAX), ISNULL([strMenuName],'')) as strDisplayData,
		CONVERT(NVARCHAR(MAX), ISNULL([strMenuName],'')) as strTag,		
		CASE WHEN (CHARINDEX('searchCommand', strCommand, 0) > 0) THEN 
		REPLACE(SUBSTRING(strCommand, CHARINDEX('searchCommand=', strCommand, 0), LEN(strCommand)) COLLATE Latin1_General_BIN,'searchCommand=','') ELSE
		'' END as strSearchCommand
	from [dbo].[tblSMMasterMenu] as mm where strType = 'Screen'

		
)
as viewResult