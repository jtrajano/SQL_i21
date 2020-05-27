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
		,strShipmentNumber
		,dtmShipDate
		,strCustomer
		,strLocationName
		,strBOLNumber
		,strOrderType
		,strItemNo
		,strItemDescription
		,strDestination
		,dblUnitCost
		,dblShipmentQty
		,dblInTransitQty
		,dblInvoiceQty
		,dblShipmentLineTotal
		,dblInTransitTotal
		,dblInvoiceLineTotal
		,dblOpenQty
		,dtmLastInvoiceDate
		,strAllVouchers
		,dtmCreated
	)
	-- Insert the items: 
	SELECT	
			shipmentItem.intInventoryShipmentId
			,shipmentItem.strShipmentNumber
			,shipmentItem.dtmShipDate
			,strCustomer = customer.strCustomerNumber + ' ' + entity.strName
			,shipmentItem.strLocationName
			,shipmentItem.strBOLNumber
			,shipmentItem.strOrderType
			,shipmentItem.strItemNo
			,shipmentItem.strItemDescription
			,shipmentItem.strDestination
			,MAX(shipmentItem.dblShipmentCost) dblUnitCost
			,SUM(shipmentItem.dblShipmentQty) dblShipmentQty
			,SUM(shipmentItem.dblInTransitQty) dblInTransitQty
			,SUM(shipmentItem.dblInvoiceQty) dblInvoiceQty
			,dblShipmentLineTotal = SUM(shipmentItem.dblShipmentItemTotal)
			,dblInTransitTotal = SUM(shipmentItem.dblItemsReceivable)
			,dblInvoiceLineTotal = SUM(shipmentItem.dblInvoiceItemTotal)
			,dblOpenQty = SUM(ISNULL(shipmentItem.dblShipmentQty, 0)) - SUM(ISNULL(shipmentItem.dblInvoiceQty, 0)) --shipmentItem.dblInTransitQty
			,MAX(shipmentItem.dtmLastInvoiceDate) dtmLastInvoiceDate
			,strAllVouchers = invoices.strInvoiceNumbers
			,dtmCreated = @dtmCreated	
	FROM	tblARCustomer customer INNER JOIN tblEMEntity entity
				ON entity.intEntityId = customer.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryShipmentInvoiceItems items
				WHERE	items.intEntityCustomerId = customer.intEntityId
			) shipmentItem
			OUTER APPLY (
				SELECT dbo.fnICGetConcatenatedInvoiceNumbersByCustomer(shipmentItem.intEntityCustomerId, shipmentItem.intInventoryShipmentId) as strInvoiceNumbers
			) invoices
	GROUP BY shipmentItem.intInventoryShipmentId
			,shipmentItem.strShipmentNumber
			,shipmentItem.dtmShipDate
			,shipmentItem.strLocationName
			,shipmentItem.strBOLNumber
			,shipmentItem.strOrderType
			,shipmentItem.strItemNo
			,shipmentItem.strItemDescription
			,shipmentItem.strDestination
			,customer.strCustomerNumber
			,entity.strName
			,invoices.strInvoiceNumbers

	UNION ALL 
	SELECT	
			 shipmentCharge.intInventoryShipmentId
			,shipmentCharge.strShipmentNumber
			,shipmentCharge.dtmShipDate
			,strCustomer = customer.strCustomerNumber + ' ' + entity.strName
			,shipmentCharge.strLocationName
			,shipmentCharge.strBOLNumber
			,shipmentCharge.strOrderType
			,shipmentCharge.strItemNo
			,shipmentCharge.strItemDescription
			,shipmentCharge.strDestination
			,dblUnitCost = shipmentCharge.dblShipmentCost
			,shipmentCharge.dblShipmentQty
			,shipmentCharge.dblInTransitQty
			,shipmentCharge.dblInvoiceQty
			,dblShipmentLineTotal = shipmentCharge.dblShipmentChargeTotal
			,dblInTransitTotal = 0
			,dblInvoiceLineTotal = shipmentCharge.dblInvoiceItemTotal
			,dblOpenQty = 0
			,shipmentCharge.dtmLastInvoiceDate
			,shipmentCharge.strAllVouchers
			,dtmCreated = @dtmCreated
	FROM	tblARCustomer customer INNER JOIN tblEMEntity entity
				ON entity.intEntityId = customer.intEntityId
			CROSS APPLY (
				SELECT	* 
				FROM	vyuICGetInventoryShipmentInvoicePriceCharges items
				WHERE	items.intEntityCustomerId = customer.intEntityId
			) shipmentCharge

END 