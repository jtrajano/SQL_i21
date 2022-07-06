CREATE PROCEDURE uspMFRouteGetSO (
	@intRouteOrderId INT
	,@intSalesOrderDetailId INT
	,@strPickListNo NVARCHAR(50)
	,@intLocationId INT
	)
AS
SELECT PD.intPickListDetailId
	,PD.intPickListId
	,SD.intSalesOrderDetailId
	,S.intSalesOrderId
	,S.strSalesOrderNumber
	,P.strPickListNo
	,sl.strName strStorageUnit
	,subl.strSubLocationName strStorageLocation
	,PD.intPickListDetailId AS intTaskId
	,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), PD.dblPickQuantity)) + ' ' + um.strUnitMeasure + '<br />' + CASE 
		WHEN L.strLotNumber IS NULL
			THEN ''
		ELSE 'Lot : ' + L.strLotNumber + '<br />'
		END + CASE 
		WHEN sl.strName IS NULL
			THEN ''
		ELSE 'S-UNIT : ' + sl.strName + '<br />'
		END + CASE 
		WHEN strSubLocationName IS NULL
			THEN ''
		ELSE 'S-LOC : ' + strSubLocationName
		END AS strTask
	,@intRouteOrderId AS intRouteOrderId
FROM dbo.tblSOSalesOrder S
JOIN dbo.tblSOSalesOrderDetail SD ON SD.intSalesOrderId = S.intSalesOrderId
	AND SD.intSalesOrderDetailId = @intSalesOrderDetailId
JOIN dbo.tblMFPickList P ON P.intSalesOrderId = S.intSalesOrderId
JOIN dbo.tblMFPickListDetail PD ON PD.intPickListId = P.intPickListId
LEFT JOIN tblICLot L ON L.intLotId = PD.intLotId
JOIN dbo.tblICItem i ON i.intItemId = SD.intItemId AND PD.intItemId =SD.intItemId
JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = PD.intPickUOMId AND PD.intItemUOMId =SD.intItemUOMId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityCustomerId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subl ON subl.intCompanyLocationSubLocationId = PD.intSubLocationId
LEFT JOIN dbo.tblICStorageLocation sl ON sl.intStorageLocationId = PD.intStorageLocationId
WHERE P.strPickListNo = @strPickListNo
	AND S.intCompanyLocationId = @intLocationId
	AND dblQtyOrdered - dblQtyShipped > 0
	AND NOT EXISTS (
		SELECT 1
		FROM tblMFRouteOrderDetail ROD
		WHERE ROD.intPickListDetailId = PD.intPickListDetailId
			AND ROD.ysnProcessed = 0
		)
ORDER BY intPickListDetailId
