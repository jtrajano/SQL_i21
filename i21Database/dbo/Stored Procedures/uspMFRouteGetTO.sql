﻿CREATE PROCEDURE uspMFRouteGetTO (
	@intRouteOrderId INT
	,@strTransferOrderNumber NVARCHAR(50)
	,@intLocationId INT
	)
AS
SELECT TD.intInventoryTransferDetailId
	,T.intInventoryTransferId
	,T.strTransferNo
	,sl.strName strStorageUnit
	,subl.strSubLocationName strStorageLocation
	,TD.intInventoryTransferDetailId AS intTaskId
	,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), TD.dblQuantity)) + ' ' + um.strUnitMeasure + '<br />' + CASE 
		WHEN sl.strName IS NULL
			THEN ''
		ELSE 'S-UNIT : ' + sl.strName + '<br />'
		END + CASE 
		WHEN strSubLocationName IS NULL
			THEN ''
		ELSE 'S-LOC : ' + strSubLocationName
		END AS strTask
	,@intRouteOrderId AS intRouteOrderId
FROM dbo.tblICInventoryTransfer T
JOIN dbo.tblICInventoryTransferDetail TD ON TD.intInventoryTransferId = T.intInventoryTransferId
JOIN dbo.tblICItem i ON i.intItemId = TD.intItemId
JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = TD.intItemUOMId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subl ON subl.intCompanyLocationSubLocationId = TD.intFromSubLocationId
LEFT JOIN dbo.tblICStorageLocation sl ON sl.intStorageLocationId = TD.intFromStorageLocationId
WHERE T.strTransferNo = @strTransferOrderNumber
	AND T.intFromLocationId = @intLocationId
	AND T.intStatusId = 1
	AND NOT EXISTS (
		SELECT 1
		FROM tblMFRouteOrderDetail ROD
		WHERE ROD.intInventoryTransferDetailId = TD.intInventoryTransferDetailId
			AND ROD.ysnProcessed = 0
		)
ORDER BY intInventoryTransferDetailId
