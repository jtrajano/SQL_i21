CREATE VIEW [dbo].[vyuICGetInventoryShipmentInvoicePriceCharges]
AS 

SELECT	Shipment.intInventoryShipmentId
		,ShipmentCharge.intInventoryShipmentChargeId
		,Shipment.strShipmentNumber
		,Shipment.dtmShipDate
		,intEntityCustomerId = Shipment.intEntityCustomerId 
		,strLocationName = fromLocation.strLocationName
		,strDestination = toLocation.strLocationName
		,strOrderType = ot.strOrderType
		,Shipment.strBOLNumber
		,i.strItemNo
		,strItemDescription = i.strDescription
		,Shipment.intCurrencyId
		,strCurrency = currency.strCurrency 
		,dblShipmentCost = ShipmentAndInvoiceCharges.ShipmentCost
		,dblShipmentQty = ShipmentAndInvoiceCharges.QtyShipped
		,dblInvoiceQty = ShipmentAndInvoiceCharges.QtyInvoiced
		,dblInTransitQty = ShipmentAndInvoiceCharges.OpenQty
		,dblShipmentChargeTotal = ShipmentAndInvoiceCharges.ShipmentChargeTotal
		,dblInvoiceItemTotal = ShipmentAndInvoiceCharges.InvoiceItemTotal
		,dblItemsReceivable = ShipmentAndInvoiceCharges.dblItemsReceivable
		,dtmLastInvoiceDate = topInvoice.dtmDate
		,strAllVouchers = CAST( ISNULL(allLinkedInvoiceId.strInvoiceIds, 'New Invoice') AS NVARCHAR(MAX)) 
		,strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) 
		
FROM	tblICInventoryShipment Shipment 
		INNER JOIN tblICInventoryShipmentCharge ShipmentCharge
			ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
		INNER JOIN tblICItem i 
			ON i.intItemId = ShipmentCharge.intChargeId

		LEFT JOIN tblSMCompanyLocation fromLocation
			ON fromLocation.intCompanyLocationId = Shipment.intShipFromLocationId

		LEFT JOIN tblEMEntityLocation toLocation
			ON toLocation.intEntityLocationId = Shipment.intShipToLocationId

		OUTER APPLY (
			SELECT	QtyShipped = 1
					,QtyInvoiced = ISNULL(InvoicedItem.dblQuantity, 0) 
					,ShipmentCost = d.dblAmount
					,ShipmentChargeTotal = 1 * d.dblAmount
					,InvoiceItemTotal = InvoicedItem.dblLineTotal 
					,OpenQty = 1 - ISNULL(InvoicedItem.dblQuantity, 0) 
					,d.intInventoryShipmentChargeId
					,dblItemsReceivable = (1 - ISNULL(InvoicedItem.dblQuantity, 0)) * d.dblAmount
			FROM	tblICInventoryShipmentCharge d 
					OUTER APPLY (
						SELECT	dblQuantity = SUM(ISNULL(id.dblQtyShipped, 0))
								,dblLineTotal = SUM(ISNULL(id.dblTotal, 0)) 
						FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
									ON i.intInvoiceId = id.intInvoiceId
						WHERE	i.ysnPosted = 1
								AND id.intInventoryShipmentChargeId = d.intInventoryShipmentChargeId
					) InvoicedItem 
			WHERE	d.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId

		) ShipmentAndInvoiceCharges
		OUTER APPLY (
			SELECT	TOP 1 
					h.strInvoiceNumber  
					,h.intInvoiceId
					,h.dtmDate
			FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
						ON h.intInvoiceId = d.intInvoiceId
			WHERE	d.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
					AND h.ysnPosted = 1
			ORDER BY h.intInvoiceId DESC 
		) topInvoice
		OUTER APPLY (
			SELECT strFilterString = 
				LTRIM(
					STUFF(
							' ' + (
								SELECT  CONVERT(NVARCHAR(50), h.intInvoiceId) + '|^|'
								FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
											ON h.intInvoiceId = d.intInvoiceId
								WHERE	d.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
										AND h.ysnPosted = 1
								GROUP BY h.intInvoiceId
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					)
				)
		) filterString 
		OUTER APPLY (
			SELECT strInvoiceIds = 
				LTRIM(
					STUFF(
							(
								SELECT  ', ' + h.strInvoiceNumber
								FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
											ON h.intInvoiceId = d.intInvoiceId
								WHERE	d.intInventoryShipmentChargeId = ShipmentCharge.intInventoryShipmentChargeId
										AND h.ysnPosted = 1
								GROUP BY h.strInvoiceNumber
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					)
				)
		) allLinkedInvoiceId  

		LEFT JOIN tblSMCurrency currency
			ON currency.intCurrencyID = Shipment.intCurrencyId

		LEFT JOIN (
			SELECT 1 intOrderTypeId, 'Sales Contract' strOrderType
			UNION
			SELECT 2 intOrderTypeId, 'Sales Order' strOrderType
			UNION
			SELECT 3 intOrderTypeId, 'Transfer Order' strOrderType
			UNION
			SELECT 4 intOrderTypeId, 'Direct' strOrderType
		) AS ot 
			ON ot.intOrderTypeId = Shipment.intOrderType


WHERE	Shipment.ysnPosted = 1
		AND ShipmentCharge.ysnPrice = 1
