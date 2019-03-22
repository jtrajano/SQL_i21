CREATE PROCEDURE [dbo].[uspICPopulateShipmentInvoice]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmCreated AS DATETIME = GETDATE()

-- Clean the contents of temp table. 
BEGIN 
	TRUNCATE TABLE [tblICSearchShipmentInvoice]
END 

-- Insert fresh data to the temp table. 
BEGIN 
	INSERT INTO [tblICSearchShipmentInvoice] (
		intInventoryShipmentId
		,intInventoryShipmentItemId
		,intInventoryShipmentChargeId
		,strShipmentNumber
		,dtmShipDate
		,strCustomer
		,strLocationName
		,strDestination
		,strBOLNumber
		,strOrderType
		,strItemNo
		,strItemDescription
		,dblUnitCost
		,dblShipmentQty
		,dblInTransitQty
		,dblInvoiceQty
		,dblShipmentLineTotal
		,dblInTransitTotal
		,dblInvoiceLineTotal
		,dblShipmentTax
		,dblInvoiceTax
		,dblOpenQty
		,dblItemsReceivable
		,dblTaxesReceivable
		,dtmLastInvoiceDate
		,strAllVouchers
		,strFilterString
		,dtmCreated
		,intCurrencyId
		,strCurrency
		,strItemUOM
		,intItemUOMId			
	)
	-- Insert the items: 
	SELECT	
			shipmentItem.intInventoryShipmentId
			,shipmentItem.intInventoryShipmentItemId
			,intInventoryShipmentChargeId = NULL 
			,shipmentItem.strShipmentNumber
			,shipmentItem.dtmShipDate
			,strCustomer = customer.strCustomerNumber + ' ' + entity.strName
			,shipmentItem.strLocationName
			,shipmentItem.strDestination
			,shipmentItem.strBOLNumber
			,shipmentItem.strOrderType
			,shipmentItem.strItemNo
			,shipmentItem.strItemDescription
			,dblUnitCost = shipmentItem.dblShipmentCost
			,shipmentItem.dblShipmentQty
			,shipmentItem.dblInTransitQty
			,shipmentItem.dblInvoiceQty
			,dblShipmentLineTotal = shipmentItem.dblShipmentItemTotal
			,dblInTransitTotal = shipmentItem.dblItemsReceivable
			,dblInvoiceLineTotal = shipmentItem.dblInvoiceItemTotal
			,dblShipmentTax = 0 
			,dblInvoiceTax = 0 
			,dblOpenQty = ISNULL(shipmentItem.dblShipmentQty, 0) - ISNULL(shipmentItem.dblInvoiceQty, 0) --shipmentItem.dblInTransitQty
			,dblItemsReceivable = shipmentItem.dblItemsReceivable
			,dblTaxesReceivable = 0 
			,shipmentItem.dtmLastInvoiceDate
			,shipmentItem.strAllVouchers
			,shipmentItem.strFilterString
			,dtmCreated = @dtmCreated
			,shipmentItem.intCurrencyId
			,shipmentItem.strCurrency
			,shipmentItem.strItemUOM
			,shipmentItem.intItemUOMId	
	FROM	tblARCustomer customer INNER JOIN tblEMEntity entity
				ON entity.intEntityId = customer.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryShipmentInvoiceItems items
				WHERE	items.intEntityCustomerId = customer.intEntityId
			) shipmentItem

	-- Insert the price down charges (against the receipt vendor)
	UNION ALL 
	SELECT	
			shipmentCharge.intInventoryShipmentId
			,shipmentCharge.intInventoryShipmentChargeId
			,intInventoryShipmentChargeId = NULL 
			,shipmentCharge.strShipmentNumber
			,shipmentCharge.dtmShipDate
			,strCustomer = customer.strCustomerNumber + ' ' + entity.strName
			,shipmentCharge.strLocationName
			,shipmentCharge.strDestination
			,shipmentCharge.strBOLNumber
			,shipmentCharge.strOrderType
			,shipmentCharge.strItemNo
			,shipmentCharge.strItemDescription
			,dblUnitCost = shipmentCharge.dblShipmentCost
			,shipmentCharge.dblShipmentQty
			,shipmentCharge.dblInTransitQty
			,shipmentCharge.dblInvoiceQty
			,dblShipmentLineTotal = shipmentCharge.dblShipmentChargeTotal
			,dblInTransitTotal = 0
			,dblInvoiceLineTotal = shipmentCharge.dblInvoiceItemTotal
			,dblShipmentTax = 0 
			,dblInvoiceTax = 0 
			,dblOpenQty = 0
			,dblItemsReceivable = shipmentCharge.dblItemsReceivable
			,dblTaxesReceivable = 0 
			,shipmentCharge.dtmLastInvoiceDate
			,shipmentCharge.strAllVouchers
			,shipmentCharge.strFilterString
			,dtmCreated = @dtmCreated
			,shipmentCharge.intCurrencyId
			,shipmentCharge.strCurrency
			,strItemUOM = NULL 
			,intItemUOMId = NULL 
	FROM	tblARCustomer customer INNER JOIN tblEMEntity entity
				ON entity.intEntityId = customer.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryShipmentInvoicePriceCharges items
				WHERE	items.intEntityCustomerId = customer.intEntityId
			) shipmentCharge
END 