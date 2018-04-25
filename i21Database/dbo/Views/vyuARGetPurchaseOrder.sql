CREATE VIEW vyuARGetPurchaseOrder
AS
SELECT PO.intPurchaseId,
	   POD.intPurchaseDetailId,
	   strPurchaseOrderNumber, 
	   intEntityVendorId,
	   strVendor = strName,
	   I.intItemId,
	   strItemNo,
	   PO.dtmDate,
	   dblOrderQuantity = dblQtyOrdered,
	   dblQtyReceived,
	   intUnitMeasureId = UOM.intUnitMeasureId,
	   UOM.strUnitMeasure,
	   stat.strStatus
FROM tblPOPurchase PO
INNER JOIN tblPOPurchaseDetail POD
	ON PO.intPurchaseId = POD.intPurchaseId
INNER JOIN tblEMEntity Vendor
	ON Vendor.intEntityId = PO.intEntityVendorId
INNER JOIN tblPOOrderStatus stat
	ON PO.intOrderStatusId = stat.intOrderStatusId
LEFT JOIN tblICItem I
	ON I.intItemId = POD.intItemId
LEFT JOIN tblICItemUOM IUOM
	ON POD.intUnitOfMeasureId = IUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM
	ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
WHERE stat.strStatus IN('Open','Partial')