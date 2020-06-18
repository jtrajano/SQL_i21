CREATE VIEW [dbo].[vyuICGetInventoryShipmentInvoiceItems]
AS 

SELECT	Shipment.intInventoryShipmentId
		,ShipmentItem.intInventoryShipmentItemId
		,Shipment.strShipmentNumber
		,Shipment.dtmShipDate
		,Shipment.intEntityCustomerId
		,strLocationName = fromLocation.strLocationName
		,strDestination = toLocation.strLocationName
		,strOrderType = ot.strOrderType COLLATE Latin1_General_CI_AS
		,Shipment.strBOLNumber
		,i.strItemNo
		,strItemDescription = i.strDescription
		,Shipment.intCurrencyId
		,strCurrency = currency.strCurrency 
		,intItemUOMId = ShipmentItem.intItemUOMId
		,strItemUOM = ItemUOMName.strUnitMeasure
		,dblShipmentCost = ShipmentAndInvoicedItems.ShipmentCost
		,dblShipmentQty = ShipmentAndInvoicedItems.QtyShipped
		,dblInvoiceQty = ShipmentAndInvoicedItems.QtyInvoiced
		,dblInTransitQty = ShipmentAndInvoicedItems.OpenQty
		,dblShipmentItemTotal = ShipmentAndInvoicedItems.ShipmentItemTotal
		,dblInvoiceItemTotal = ShipmentAndInvoicedItems.InvoiceItemTotal
		,dblItemsReceivable = ShipmentAndInvoicedItems.dblItemsReceivable
		,dtmLastInvoiceDate = topInvoice.dtmDate
		,strAllVouchers = CAST( ISNULL(allLinkedInvoiceId.strInvoiceIds, 'New Invoice') AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS
		,strFilterString = CAST(filterString.strFilterString AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS
FROM	tblICInventoryShipment Shipment 
		INNER JOIN tblICInventoryShipmentItem ShipmentItem
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		INNER JOIN tblICItem i 
			ON i.intItemId = ShipmentItem.intItemId

		INNER JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure ItemUOMName
				ON ItemUOM.intUnitMeasureId = ItemUOMName.intUnitMeasureId
		)
			ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId

		LEFT JOIN tblSMFreightTerms FreightTerm
			ON Shipment.intFreightTermId = FreightTerm.intFreightTermId 

		LEFT JOIN tblSMCompanyLocation fromLocation
			ON fromLocation.intCompanyLocationId = Shipment.intShipFromLocationId

		LEFT JOIN tblEMEntityLocation toLocation
			ON toLocation.intEntityLocationId = Shipment.intShipToLocationId

		OUTER APPLY (
			SELECT	QtyShipped = 						
						ISNULL(NULLIF(d.dblDestinationQuantity, 0), d.dblQuantity)
					,QtyInvoiced = ISNULL(InvoicedItem.dblQuantity, 0) 
					,ShipmentCost = ShipmentBasedOnInventoryTransaction.dblShipmentCost
					,ShipmentItemTotal = 
						ISNULL(NULLIF(d.dblDestinationQuantity, 0), d.dblQuantity)
						* ShipmentBasedOnInventoryTransaction.dblShipmentCost
					,InvoiceItemTotal = ISNULL(InvoicedItem.dblQuantity, 0) * ShipmentBasedOnInventoryTransaction.dblShipmentCost
					,OpenQty = 					
						CASE 
							-- Note: Partial Invoice is no longer supported by AR. 
							-- So if a shipment has an invoice, shipment is considered to be fully-invoiced. 
							WHEN InvoicedItem.dblQuantity IS NOT NULL THEN 0 
							ELSE d.dblQuantity 
						END 
					,d.intInventoryShipmentItemId
					,dblItemsReceivable = 
						(
							ISNULL(NULLIF(d.dblDestinationQuantity, 0), d.dblQuantity)
							- ISNULL(InvoicedItem.dblQuantity, 0)
						) 
						* ShipmentBasedOnInventoryTransaction.dblShipmentCost
			FROM	tblICInventoryShipmentItem d 
					CROSS APPLY (
						SELECT	dblShipmentQty = SUM(ISNULL(-t.dblQty, 0)) 
								,dblShipmentValue = SUM(ISNULL(-t.dblQty, 0) * ISNULL(t.dblCost, 0)) 
								,dblShipmentCost = CASE WHEN SUM(ISNULL(-t.dblQty, 0)) <> 0 THEN SUM(ISNULL(-t.dblQty, 0) * ISNULL(t.dblCost, 0)) / SUM(ISNULL(-t.dblQty, 0)) ELSE 0.00 END 
						FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation il
									ON t.intItemLocationId = il.intItemLocationId
									AND il.intLocationId IS NOT NULL 
						WHERE	t.strTransactionId = Shipment.strShipmentNumber
								AND t.intTransactionId = Shipment.intInventoryShipmentId
								AND t.intTransactionDetailId = d.intInventoryShipmentItemId
								AND t.dblQty <> 0 
								AND ISNULL(t.ysnIsUnposted, 0) = 0			
					) ShipmentBasedOnInventoryTransaction
					OUTER APPLY (
						SELECT	dblQuantity = SUM(ISNULL(id.dblQtyShipped, 0))
						FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
									ON i.intInvoiceId = id.intInvoiceId
						WHERE	i.ysnPosted = 1
								AND id.intInventoryShipmentItemId = d.intInventoryShipmentItemId
					) InvoicedItem 
			WHERE	d.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId

		) ShipmentAndInvoicedItems
		OUTER APPLY (
			SELECT	TOP 1 
					h.strInvoiceNumber  
					,h.intInvoiceId
					,h.dtmDate
			FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
						ON h.intInvoiceId = d.intInvoiceId
			WHERE	d.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
					AND d.intInventoryShipmentChargeId IS NULL 
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
								WHERE	d.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
										AND d.intInventoryShipmentChargeId IS NULL 
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
								WHERE	d.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
										AND d.intInventoryShipmentChargeId IS NULL 
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
