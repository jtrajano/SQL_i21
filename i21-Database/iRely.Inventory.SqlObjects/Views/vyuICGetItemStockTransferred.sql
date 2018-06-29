CREATE VIEW [vyuICGetItemStockTransferred]
AS
SELECT
	trd.intItemId,
	i.strItemNo,
	dblTransferNet = trd.dblNet, 
	dblTransferGross = trd.dblGross, 
	dblTransferTare = trd.dblTare, 
	intTransferGrossUOMId = trd.intGrossNetUOMId,
	dblTransferQty = trd.dblQuantity,
	intTransferItemUOMId = trd.intItemUOMId,
	dblReceiptNet = ri.dblNet,
	dblReceiptGross = ri.dblGross,
	intReceiptGrossUOMId = ri.intWeightUOMId,
	dblReceiptQty = ri.dblOpenReceive,
	intReceiptItemUOMId = ri.intUnitMeasureId,
	tr.intInventoryTransferId,
	tr.strTransferNo,
	tr.ysnShipmentRequired,
	tr.intFromLocationId,
	tr.intToLocationId,
	i.strLotTracking,
	ysnReceiptPosted = r.ysnPosted,
	ysnTransferPosted = r.ysnPosted,
	tr.intStatusId,
	s.strStatus,
	r.intInventoryReceiptId,
	ri.intInventoryReceiptItemId
FROM tblICInventoryTransfer tr
	INNER JOIN tblICInventoryTransferDetail trd ON trd.intInventoryTransferId = tr.intInventoryTransferId
	INNER JOIN tblICInventoryReceipt r ON r.strReceiptType = 'Transfer Order'
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		AND ri.intOrderId = tr.intInventoryTransferId
	INNER JOIN tblICItem i ON i.intItemId = trd.intItemId
	INNER JOIN tblICStatus s ON s.intStatusId = tr.intStatusId