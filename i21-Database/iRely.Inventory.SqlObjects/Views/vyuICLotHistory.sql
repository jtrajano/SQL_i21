CREATE VIEW [dbo].[vyuICLotHistory]
AS

SELECT lot.strLotNumber, lot.intLotId, plot.strLotNumber AS strParentLotNumber, lum.strUnitMeasure AS strLotUOM, lot.dblWeightPerQty, lot.dtmExpiryDate,
	e.strName AS strEntityName, e.intEntityId,
	tt.strName AS strTransactionType, t.intTransactionId, t.strTransactionId, t.dtmDate, t.dblQty, t.dblCost, lot.dblQty * lot.dblLastCost * im.dblUnitQty AS dblAmount, lot.dblWeight,
	loc.strLocationName, t.intLocationId, sloc.strName AS strStorageLocationName, t.intStorageLocationId
FROM tblICInventoryLotTransaction t
	LEFT OUTER JOIN tblICInventoryTransactionType tt ON tt.intTransactionTypeId = t.intTransactionTypeId
	LEFT OUTER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = t.intLocationId
	LEFT OUTER JOIN tblICStorageLocation sloc ON sloc.intStorageLocationId = t.intStorageLocationId
	LEFT OUTER JOIN tblICLot lot ON lot.intLotId = t.intLotId
	LEFT OUTER JOIN tblICLot plot ON plot.intLotId = lot.intParentLotId
	LEFT OUTER JOIN tblICItemUOM im ON im.intItemId = lot.intItemId
		AND im.intItemUOMId = lot.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure lum ON lum.intUnitMeasureId = lot.intItemUOMId
	LEFT JOIN tblICInventoryReceipt receipt ON receipt.intInventoryReceiptId = t.intTransactionId
		AND receipt.strReceiptNumber = t.strTransactionId
		AND tt.intTransactionTypeId = 4
	LEFT JOIN tblICInventoryShipment shipment ON shipment.intInventoryShipmentId = t.intTransactionId
		AND shipment.strShipmentNumber = t.strTransactionId
		AND tt.intTransactionTypeId = 5
	LEFT JOIN tblARInvoice invoice ON invoice.intInvoiceId = t.intTransactionId
		AND invoice.strInvoiceNumber = t.strTransactionId
	LEFT JOIN tblAPBill bill ON bill.intBillId = t.intTransactionId
		AND bill.strBillId = t.strTransactionId
	LEFT JOIN tblEMEntity e ON e.intEntityId = COALESCE(receipt.intEntityVendorId, shipment.intEntityCustomerId, invoice.intEntityCustomerId, bill.intEntityVendorId) 