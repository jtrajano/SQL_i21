CREATE VIEW [dbo].[vyuICItemLocationTransactions]
AS

SELECT DISTINCT
	strTransaction = 'Receipt' COLLATE Latin1_General_CI_AS,
	strTransactionNo = r.strReceiptNumber,
	intTransactionId = r.intInventoryReceiptId,
	intItemLocationId = il.intItemLocationId,
	strLocationName = loc.strLocationName,
	intItemId = il.intItemId,
	dtmTransactionDate = r.dtmReceiptDate
FROM tblICInventoryReceiptItem ri
	INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	INNER JOIN tblICItemLocation il ON il.intItemId = ri.intItemId
		AND il.intLocationId = r.intLocationId
	INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId

UNION

-- Shipments
SElECT DISTINCT 
	strTransaction = 'Shipment' COLLATE Latin1_General_CI_AS,
	strTransactionNo = s.strShipmentNumber,
	intTransactionId = s.intInventoryShipmentId,
	intItemLocationId = il.intItemLocationId,
	strLocationName = loc.strLocationName,
	intItemId = il.intItemId,
	dtmTransactionDate = s.dtmShipDate
FROM tblICInventoryShipment s
	INNER JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
	INNER JOIN tblICItemLocation il ON il.intItemId = si.intItemId
		AND il.intLocationId = s.intShipFromLocationId
	INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId

UNION

-- Transfers
SELECT DISTINCT 
	strTransaction = 'Transfer' COLLATE Latin1_General_CI_AS,
	strTransactionNo = t.strTransferNo,
	intTransactionId = t.intInventoryTransferId,
	intItemLocationId = il.intItemLocationId,
	strLocationName = loc.strLocationName,
	intItemId = il.intItemId,
	dtmTransactionDate = t.dtmTransferDate
FROM tblICInventoryTransfer t
	INNER JOIN tblICInventoryTransferDetail td ON td.intInventoryTransferId = t.intInventoryTransferId
	INNER JOIN tblICItemLocation il ON il.intItemId = td.intItemId
		AND (il.intLocationId = t.intFromLocationId OR il.intLocationId = t.intToLocationId)
	INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId

UNION

-- Adjustments
SELECT DISTINCT
	strTransaction = 'Adjustment' COLLATE Latin1_General_CI_AS,
	strTransactionNo = a.strAdjustmentNo,
	intTransactionId = a.intInventoryAdjustmentId,
	intItemLocationId = il.intItemLocationId,
	strLocationName = loc.strLocationName,
	intItemId = il.intItemId,
	dtmTransactionDate = a.dtmAdjustmentDate
FROM tblICInventoryAdjustment a
	INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intInventoryAdjustmentId = a.intInventoryAdjustmentId
	INNER JOIN tblICItemLocation il ON il.intItemId = ad.intItemId
		AND il.intLocationId = a.intLocationId
	INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId

UNION

-- Inv. Count
SELECT DISTINCT 
	strTransaction = 'Count' COLLATE Latin1_General_CI_AS,
	strTransactionNo = c.strCountNo,
	intTransactionId = c.intInventoryCountId,
	intItemLocationId = il.intItemLocationId,
	strLocationName = loc.strLocationName,
	intItemId = il.intItemId,
	dtmTransactionDate = c.dtmCountDate
FROM tblICInventoryCount c
	INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
	INNER JOIN tblICItemLocation il ON il.intItemId = cd.intItemId
		AND il.intLocationId = c.intLocationId
	INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId
