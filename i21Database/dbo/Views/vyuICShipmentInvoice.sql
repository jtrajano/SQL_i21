CREATE VIEW vyuICShipmentInvoice
AS

SELECT
	  si.intInventoryShipmentItemId
	, s.strShipmentNumber
	, c.strCustomerNumber
	, strCustomerName = e.strName
	, strOrderType = ot.strOrderType
	, s.intOrderType
	, strDestination = l.strLocationName
	, s.dtmShipDate
	, s.strBOLNumber
	, i.strItemNo
	, iv.strInvoiceNumber
	, dtmDateInvoiced = iv.dtmDate
	, dblUnitCost = t.dblCost
	, dblQtyShipped = si.dblQuantity
	, dblShipmentAmount = si.dblQuantity * t.dblCost + t.dblValue
	, dblInTransitAmount = ISNULL(it.dblQty * it.dblCost + it.dblValue, 0.0)
	, dblCOGSAmount = ISNULL(-(t.dblQty) * t.dblCost + t.dblValue, 0.0)
	, dblQtyToInvoice = CASE iv.ysnPosted WHEN 0 THEN ivd.dblQtyShipped ELSE 0.0 END
	, dblQtyInvoiced = CASE iv.ysnPosted WHEN 1 THEN ivd.dblQtyShipped ELSE 0.0 END
	, intCurrencyId = currency.intCurrencyID
	, strCurrency = currency.strCurrency
FROM tblICInventoryShipment s
	LEFT JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
	LEFT JOIN tblICItem i ON i.intItemId = si.intItemId
	LEFT JOIN tblARCustomer c ON c.intEntityCustomerId = s.intEntityCustomerId
	LEFT JOIN tblEMEntity e ON e.intEntityId = c.intEntityCustomerId
	LEFT JOIN [tblEMEntityLocation] l ON l.intEntityLocationId = s.intShipToLocationId
	LEFT JOIN tblARInvoiceDetail ivd on si.intInventoryShipmentItemId = ivd.intInventoryShipmentItemId
		AND ivd.intItemId = si.intItemId
	LEFT JOIN tblARInvoice iv on ivd.intInvoiceId = iv.intInvoiceId
	LEFT JOIN tblICItemLocation il ON il.intItemId = si.intItemId
		AND s.intShipFromLocationId = il.intLocationId
	LEFT JOIN tblICInventoryTransaction t ON t.intTransactionDetailId = si.intInventoryShipmentItemId
		AND t.intItemLocationId = il.intItemLocationId
	LEFT JOIN (
		SELECT iti.intTransactionDetailId, intInTransitSourceLocationId, dblQty, dblCost, dblSalesPrice, dblValue
		FROM tblICInventoryTransaction iti
		WHERE iti.intInTransitSourceLocationId IS NOT NULL
	) it ON it.intTransactionDetailId = si.intInventoryShipmentItemId
		AND it.intInTransitSourceLocationId = il.intItemLocationId
		AND iv.ysnPosted = 0
	LEFT JOIN (
		SELECT 1 intOrderTypeId, 'Sales Contract' strOrderType
		UNION
		SELECT 2 intOrderTypeId, 'Sales Order' strOrderType
		UNION
		SELECT 3 intOrderTypeId, 'Transfer Order' strOrderType
		UNION
		SELECT 4 intOrderTypeId, 'Direct' strOrderType
	) AS ot ON ot.intOrderTypeId = s.intOrderType
	LEFT JOIN tblSMCurrency currency
		ON currency.intCurrencyID = s.intCurrencyId
WHERE s.ysnPosted = 1