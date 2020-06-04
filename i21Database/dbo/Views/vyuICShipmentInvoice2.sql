CREATE VIEW vyuICShipmentInvoice2
AS

SELECT	t.intInventoryShipmentId
		,t.intInventoryShipmentItemId
		,t.intInventoryShipmentChargeId
		,t.strShipmentNumber
		,t.dtmShipDate
		,t.strCustomer
		,t.strLocationName
		,ship.intShipFromLocationId
		,t.strDestination
		,t.strBOLNumber
		,t.strOrderType
		,t.strItemNo
		,t.strItemDescription
		,dblUnitCost = ROUND(t.dblUnitCost, 2)
		,dblShipmentQty = ROUND(t.dblShipmentQty, 2) 
		,dblInTransitQty = ROUND(t.dblInTransitQty, 2)
		,dblInvoiceQty = ROUND(t.dblInvoiceQty, 2) 
		,dblShipmentLineTotal = ROUND(t.dblShipmentLineTotal, 2) 
		,dblInTransitTotal = ROUND(t.dblInTransitTotal, 2) 
		,dblInvoiceLineTotal = ROUND(t.dblInvoiceLineTotal, 2)
		,dblShipmentTax = ROUND(t.dblShipmentTax, 2)
		,dblInvoiceTax = ROUND(t.dblInvoiceTax, 2)
		,dblOpenQty = ROUND(t.dblOpenQty, 2) 
		,dblItemsReceivable = ROUND(t.dblItemsReceivable, 2) 
		,dblTaxesReceivable = ROUND(t.dblTaxesReceivable, 2)
		,t.dtmLastInvoiceDate
		,t.strAllVouchers
		,t.strFilterString
		,t.dtmCreated
		,t.intCurrencyId
		,t.strCurrency
		,t.strItemUOM
		,t.intItemUOMId
FROM	[tblICSearchShipmentInvoice] t
	LEFT OUTER JOIN tblICInventoryShipment ship ON ship.intInventoryShipmentId = t.intInventoryShipmentId