CREATE PROCEDURE uspMFGetPODetail (@intPurchaseDetailId INT)
AS
SELECT PD.intPurchaseDetailId
	,P.intPurchaseId
	,P.strPurchaseOrderNumber
	,PD.intItemId
	,i.strItemNo
	,i.strDescription
	,CONVERT(NUMERIC(38, 3), dblQtyOrdered - dblQtyReceived) AS dblQuantity
	,um.strUnitMeasure
	,iu.intItemUOMId
	,iu.strLongUPCCode
	,iu.strUpcCode AS strShortUpcCode
FROM dbo.tblPOPurchase P
JOIN dbo.tblPOPurchaseDetail PD ON PD.intPurchaseId = P.intPurchaseId
	AND PD.intPurchaseDetailId = @intPurchaseDetailId
JOIN dbo.tblICItem i ON i.intItemId = PD.intItemId
JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = PD.intUnitOfMeasureId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
JOIN dbo.tblEMEntity E ON E.intEntityId = P.intEntityVendorId
