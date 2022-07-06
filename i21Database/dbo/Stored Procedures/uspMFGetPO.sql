CREATE PROCEDURE uspMFGetPO (
	@strPurchaseOrderNumber NVARCHAR(50)
	,@intLocationId INT
	)
AS
SELECT PD.intPurchaseDetailId
	,P.intPurchaseId
	,P.strPurchaseOrderNumber
	,sl.strName strStorageUnit
	,subl.strSubLocationName strStorageLocation
	,PD.intPurchaseDetailId AS intTaskId
	,'ITEM # : ' + i.strItemNo + '<br />' + i.strDescription + '<br />' + 'QTY : ' + LTRIM(CONVERT(NUMERIC(38, 3), dblQtyOrdered - dblQtyReceived)) + ' ' + um.strUnitMeasure + '<br />' + CASE 
		WHEN sl.strName IS NULL
			THEN ''
		ELSE 'S-UNIT : ' + sl.strName + '<br />'
		END + CASE 
		WHEN strSubLocationName IS NULL
			THEN ''
		ELSE 'S-LOC : ' + strSubLocationName
		END AS strTask
FROM dbo.tblPOPurchase P
JOIN dbo.tblPOPurchaseDetail PD ON PD.intPurchaseId = P.intPurchaseId
JOIN dbo.tblICItem i ON i.intItemId = PD.intItemId
JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = PD.intUnitOfMeasureId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
JOIN dbo.tblEMEntity E ON E.intEntityId = P.intEntityVendorId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subl ON subl.intCompanyLocationSubLocationId = PD.intSubLocationId
LEFT JOIN dbo.tblICStorageLocation sl ON sl.intStorageLocationId = PD.intStorageLocationId
WHERE P.strPurchaseOrderNumber = @strPurchaseOrderNumber
	AND P.intLocationId = @intLocationId
	AND dblQtyOrdered - dblQtyReceived > 0
	AND NOT EXISTS (
		SELECT 1
		FROM tblMFPODetail POD
		WHERE POD.intPurchaseDetailId = PD.intPurchaseDetailId
			AND POD.ysnProcessed = 0
		)
ORDER BY intPurchaseDetailId
