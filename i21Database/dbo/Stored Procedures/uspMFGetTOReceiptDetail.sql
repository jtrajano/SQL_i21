CREATE PROCEDURE uspMFGetTOReceiptDetail (@intInventoryTransferDetailId INT)
AS
SELECT TD.intInventoryTransferDetailId
	,T.intInventoryTransferId
	,T.strTransferNo
	,sl.strName strStorageUnit
	,subl.strSubLocationName strStorageLocation
	,TD.intItemId
	,i.strItemNo
	,i.strDescription
	,CONVERT(NUMERIC(38, 3), TD.dblQuantity) AS dblQuantity
	,um.strUnitMeasure
	,iu.intItemUOMId
	,iu.strLongUPCCode
	,iu.strUpcCode AS strShortUpcCode
FROM dbo.tblICInventoryTransfer T
JOIN dbo.tblICInventoryTransferDetail TD ON TD.intInventoryTransferId = T.intInventoryTransferId
	AND TD.intInventoryTransferDetailId = @intInventoryTransferDetailId
JOIN dbo.tblICItem i ON i.intItemId = TD.intItemId
JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = TD.intItemUOMId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subl ON subl.intCompanyLocationSubLocationId = TD.intFromSubLocationId
LEFT JOIN dbo.tblICStorageLocation sl ON sl.intStorageLocationId = TD.intFromStorageLocationId
