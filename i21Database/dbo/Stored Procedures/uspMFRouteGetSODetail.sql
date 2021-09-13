CREATE PROCEDURE uspMFRouteGetSODetail (
	@intRouteOrderId INT
	,@intPickListDetailId INT
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
	,SD.intItemId
	,i.strItemNo
	,i.strDescription
	,CONVERT(NUMERIC(38, 3), PD.dblPickQuantity) AS dblQuantity
	,um.strUnitMeasure
	,iu.intItemUOMId
	,iu.strLongUPCCode
	,iu.strUpcCode AS strShortUpcCode
FROM dbo.tblSOSalesOrder S
JOIN dbo.tblSOSalesOrderDetail SD ON SD.intSalesOrderId = S.intSalesOrderId
JOIN dbo.tblMFPickList P ON P.intSalesOrderId = S.intSalesOrderId
JOIN dbo.tblMFPickListDetail PD ON PD.intPickListId = P.intPickListId
	AND PD.intPickListDetailId = @intPickListDetailId
LEFT JOIN dbo.tblICLot L ON L.intLotId = PD.intLotId
JOIN dbo.tblICItem i ON i.intItemId = SD.intItemId AND PD.intItemId = SD.intItemId
JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = PD.intPickUOMId AND PD.intItemUOMId =SD.intItemUOMId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityCustomerId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subl ON subl.intCompanyLocationSubLocationId = PD.intSubLocationId
LEFT JOIN dbo.tblICStorageLocation sl ON sl.intStorageLocationId = PD.intStorageLocationId
